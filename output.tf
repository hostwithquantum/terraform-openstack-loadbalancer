output "loadbalancer_id" {
  description = "Load balancer ID"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.id
}

output "loadbalancer_ip" {
  description = "Load balancer IP address"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.vip_address
}

output "loadbalancer_vip_port_id" {
  description = "The Port ID of the Load Balancer IP"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

output "loadbalancer_name" {
  description = "Human-readable name for the Loadbalancer"
  value       = openstack_lb_loadbalancer_v2.loadbalancer.name
}

output "listener_id" {
  description = "Listener ID"
  value = {
    for i in openstack_lb_listener_v2.listener :
    i.name => i.id
  }
}

output "listener_protocol" {
  description = "Listener protocol"
  value = {
    for i in openstack_lb_listener_v2.listener :
    i.name => i.protocol
  }
}

output "listener_protocol_port" {
  description = "The port on which to listen for client traffic"
  value = {
    for i in openstack_lb_listener_v2.listener :
    i.name => i.protocol_port
  }
}

output "lb_pool_id" {
  description = "Load balancer pool ID"
  value = {
    for i in openstack_lb_pool_v2.lb_pool :
    i.name => i.id
  }
}

output "member_address" {
  description = "The IP address of the member to receive traffic from the load balancer"
  value = {
    for i in openstack_lb_members_v2.members :
    i.pool_id => i.member
  }
}
#output "member_port" {
#  description = "The port on which to listen for client traffic"
#  value = join(",",
#    distinct([for member in openstack_lb_member_v2.member : member.protocol_port])
#  )
#}
#
#output "member_address" {
#  description = "The IP address of the member to receive traffic from the load balancer"
#  value = join(",",
#    [for member in openstack_lb_member_v2.member :
#    member.address]
#  )
#}
