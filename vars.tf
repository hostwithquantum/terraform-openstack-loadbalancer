###########
# General #
###########
variable "name" {
  description = "Name to prefix all resources created on OpenStack"
  type        = string
}

################
# Loadbalancer #
################
variable "lb_description" {
  description = "Human-readable description for the Loadbalancer"
  type        = string
  default     = ""
}

variable "lb_vip_subnet_id" {
  description = "The network on which to allocate the Loadbalancer's address"
  type        = string
}

variable "lb_security_group_ids" {
  description = "A list of security group IDs to apply to the loadbalancer"
  type        = list(string)
  default     = []
}

variable "listeners" {
  type = any
}

variable "def_values" {
  type = object({
    listener_protocol               = string
    listener_protocol_port          = string
    listener_connection_limit       = string
    lb_pool_protocol                = string
    lb_pool_method                  = string
    lb_sess_persistence             = string
    lb_sess_persistence_cookie_name = string
    monitor_url_path                = string
    monitor_expected_codes          = string
    monitor_delay                   = string
    monitor_timeout                 = string
    monitor_max_retries             = string
    monitor_max_retries_down        = string
    member_address                  = list(string)
    member_name                     = list(string)
    member_subnet_id                = string
    member_port                     = string
  })
  default = {
    listener_protocol               = "HTTP"
    listener_protocol_port          = "80"
    listener_connection_limit       = "-1"
    lb_pool_protocol                = "HTTP"
    lb_pool_method                  = "ROUND_ROBIN"
    lb_sess_persistence             = null
    lb_sess_persistence_cookie_name = null
    monitor_url_path                = "/"
    monitor_expected_codes          = "200"
    monitor_delay                   = "20"
    monitor_timeout                 = "10"
    monitor_max_retries             = "5"
    monitor_max_retries_down        = "3"
    member_address                  = []
    member_name                     = []
    member_subnet_id                = ""
    member_port                     = "80"
  }
}


#############
## Listener #
#############
#variable "listeners" {
#  description = "The protocol - can either be TCP, HTTP, HTTPS or TERMINATED_HTTPS"
#  default     = []
#  type        = any
#}
#variable "pools" {
#  description = "The protocol - can either be TCP, HTTP, HTTPS or TERMINATED_HTTPS"
#  default     = []
#  type        = any
#}
#
#variable "listener_protocol" {
#  description = "The protocol - can either be TCP, HTTP, HTTPS or TERMINATED_HTTPS"
#  type        = string
#  default     = "HTTP"
#}
#
#variable "listener_protocol_port" {
#  description = "The port on which to listen for client traffic"
#  type        = string
#  default     = "80"
#}
#
#variable "listener_connection_limit" {
#  description = "The maximum number of connections allowed for the Listener"
#  type        = string
#  default     = "-1"
#}
#
#####################
## Loadbalance pool #
#####################
#variable "lb_pool_method" {
#  description = "The load balancing algorithm to distribute traffic to the pool's members. Must be one of ROUND_ROBIN, LEAST_CONNECTIONS, or SOURCE_IP"
#  type        = string
#  default     = "ROUND_ROBIN"
#}
#
#variable "lb_pool_protocol" {
#  description = "The protocol - can either be TCP, HTTP, HTTPS or PROXY"
#  type        = string
#  default     = "HTTP"
#}
#
#
############
## Monitor #
############
#variable "monitor_url_path" {
#  description = "Required for HTTP(S) types. URI path that will be accessed if monitor type is HTTP or HTTPS"
#  type        = string
#  default     = "/"
#}
#
#variable "monitor_expected_codes" {
#  description = "Required for HTTP(S) types. Expected HTTP codes for a passing HTTP(S) monitor. You can either specify a single status like 200, or a range like 200-202"
#  type        = string
#  default     = "200"
#}
#
#variable "monitor_delay" {
#  description = "The time, in seconds, between sending probes to members"
#  type        = string
#  default     = "20"
#}
#
#variable "monitor_timeout" {
#  description = "Maximum number of seconds for a monitor to wait for a ping reply before it times out"
#  type        = string
#  default     = "10"
#}
#
#variable "monitor_max_retries" {
#  description = "Number of permissible ping failures before changing the member's status to INACTIVE. Must be a number between 1 and 10"
#  type        = string
#  default     = "5"
#}
#
###########
## Member #
###########
#variable "member_port" {
#  description = "The port on which to listen for client traffic"
#  type        = string
#  default     = "80"
#}
#
#variable "member_address" {
#  description = "The IP addresses of the member to receive traffic from the load balancer"
#  type        = list(string)
#}
#
#variable "member_subnet_id" {
#  description = "The subnet in which to access the member"
#  type        = string
#  default     = ""
#}
#
########
## SSL #
########
#variable "certificate" {
#  description = "The certificate data to be stored. (file_name)"
#  type        = string
#  default     = ""
#}
#
#variable "private_key" {
#  description = "The private key data to be stored. (file_name)"
#  type        = string
#  default     = ""
#}
#
#variable "certificate_intermediate" {
#  description = "The intermediate certificate data to be stored. (file_name)"
#  type        = string
#  default     = ""
#}
