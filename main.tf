############################
### Create load balancer ###
############################
resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  name               = "${var.name}-loadbalancer"
  description        = var.lb_description
  vip_subnet_id      = var.lb_vip_subnet_id
  security_group_ids = var.lb_security_group_ids
  admin_state_up     = "true"
}

###################
### Create pool ###
###################
resource "openstack_lb_pool_v2" "lb_pool" {
  for_each = var.listeners

  description     = var.lb_description
  name            = lookup(each.value, "lb_pool_name", format("%s-%s-%s", var.name, each.key, "lb_pool"))
  protocol        = lookup(each.value, "lb_pool_protocol", var.def_values.lb_pool_protocol)
  lb_method       = lookup(each.value, "lb_pool_method", var.def_values.lb_pool_method)
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer.id

  dynamic "persistence" {
    for_each = contains(keys(each.value), "lb_sess_persistence") ? list(each.value["lb_sess_persistence"]) : []
    content {
      type        = persistence.value
      cookie_name = lookup(each.value, "lb_sess_persistence_cookie_name", var.def_values.lb_sess_persistence_cookie_name)
    }
  }
}

#######################
### Create listener ###
#######################
resource "openstack_lb_listener_v2" "listener" {
  for_each = var.listeners

  description      = var.lb_description
  name             = lookup(each.value, "listener_name", format("%s-%s-%s", var.name, each.key, "listener"))
  protocol         = lookup(each.value, "listener_protocol", var.def_values.listener_protocol)
  protocol_port    = lookup(each.value, "listener_protocol_port", var.def_values.listener_protocol_port)
  connection_limit = lookup(each.value, "listener_connection_limit", var.def_values.listener_connection_limit)
  admin_state_up   = "true"
  loadbalancer_id  = openstack_lb_loadbalancer_v2.loadbalancer.id
  default_pool_id  = openstack_lb_pool_v2.lb_pool[each.key].id
  # default_tls_container_ref = var.certificate != "" ? join(",", openstack_keymanager_container_v1.tls.*.container_ref) : ""
}

######################
### Create monitor ###
######################
# monitor has different parameters to http* and tcp
# Create non TCP monitor
resource "openstack_lb_monitor_v2" "lb_monitor" {
  for_each = { for k, r in var.listeners : k => r if r["lb_pool_protocol"] != "TCP" }

  pool_id          = openstack_lb_pool_v2.lb_pool[each.key].id
  name             = lookup(each.value, "monitor_name", format("%s-%s-%s", var.name, each.key, "lb_monitor"))
  type             = lookup(each.value, "lb_pool_protocol", var.def_values.lb_pool_protocol)
  url_path         = lookup(each.value, "monitor_url_path", var.def_values.monitor_url_path)
  expected_codes   = lookup(each.value, "monitor_expected_codes", var.def_values.monitor_expected_codes)
  delay            = lookup(each.value, "monitor_delay", var.def_values.monitor_delay)
  timeout          = lookup(each.value, "monitor_timeout", var.def_values.monitor_timeout)
  max_retries      = lookup(each.value, "monitor_max_retries", var.def_values.monitor_max_retries)
  max_retries_down = lookup(each.value, "monitor_max_retries_down", var.def_values.monitor_max_retries_down)
}

# Create TCP monitor
resource "openstack_lb_monitor_v2" "lb_monitor_tcp" {
  for_each = { for k, r in var.listeners : k => r if r["lb_pool_protocol"] == "TCP" }

  pool_id          = openstack_lb_pool_v2.lb_pool[each.key].id
  name             = lookup(each.value, "monitor_name", format("%s-%s-%s", var.name, each.key, "lb_monitor"))
  type             = lookup(each.value, "lb_pool_protocol", var.def_values.lb_pool_protocol)
  delay            = lookup(each.value, "monitor_delay", var.def_values.monitor_delay)
  timeout          = lookup(each.value, "monitor_timeout", var.def_values.monitor_timeout)
  max_retries      = lookup(each.value, "monitor_max_retries", var.def_values.monitor_max_retries)
  max_retries_down = lookup(each.value, "monitor_max_retries_down", var.def_values.monitor_max_retries_down)
}

###########################
### Add members to pool ###
###########################
resource "openstack_lb_members_v2" "members" {
  for_each = var.listeners

  pool_id = openstack_lb_pool_v2.lb_pool[each.key].id

  dynamic "member" {
    # If member_name is specified, it creates a map name: ip, otherwise ip: ip
    for_each = contains(keys(each.value), "member_name") ? zipmap(each.value.member_name, each.value.member_address) : zipmap(each.value.member_address, each.value.member_address)
    content {
      name          = member.key
      address       = member.value
      subnet_id     = each.value.member_subnet_id
      protocol_port = lookup(each.value, "member_port", var.def_values.member_port)
    }
  }
}

############
#### SSL ###
############
## Certificate
#resource "openstack_keymanager_secret_v1" "certificate" {
#  count                = var.certificate != "" ? 1 : 0
#  name                 = "${var.name}-certificate"
#  payload              = file(var.certificate)
#  secret_type          = "certificate"
#  payload_content_type = "text/plain"
#}
#
## Private key
#resource "openstack_keymanager_secret_v1" "private_key" {
#  count                = var.private_key != "" ? 1 : 0
#  name                 = "${var.name}-private_key"
#  payload              = file(var.private_key)
#  secret_type          = "private"
#  payload_content_type = "text/plain"
#}
#
## Certificate intermediate
#resource "openstack_keymanager_secret_v1" "intermediate" {
#  count                = var.certificate_intermediate != "" ? 1 : 0
#  name                 = "${var.name}-intermediate"
#  payload              = file(var.certificate_intermediate)
#  secret_type          = "certificate"
#  payload_content_type = "text/plain"
#}
#
#resource "openstack_keymanager_container_v1" "tls" {
#  count = var.certificate != "" ? 1 : 0
#  name  = "${var.name}-tls"
#  type  = "certificate"
#
#  secret_refs {
#    name       = "certificate"
#    secret_ref = join(",", openstack_keymanager_secret_v1.certificate.*.secret_ref)
#  }
#
#  secret_refs {
#    name       = "private_key"
#    secret_ref = join(",", openstack_keymanager_secret_v1.private_key.*.secret_ref)
#  }
#
#  # Add intermediates if specified
#  dynamic "secret_refs" {
#    for_each = compact([var.certificate_intermediate])
#    content {
#      name       = "intermediates"
#      secret_ref = join(",", openstack_keymanager_secret_v1.intermediate.*.secret_ref)
#    }
#  }
#}

