# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "project_services" {
  type        = "list"
  description = "Google Cloud APIs to enable for the GCP project"

  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "dns.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
  ]
}

variable "cluster_subnet_ranges" {
  type        = "map"
  description = "A map of index to a comma separated list of `region,nodes-subnet,pods-subnet,services-subnet` string. Designed for GKE, but generic enough for other use cases."

  #default = {
  #  # index = "region,nodes-subnet,pods-subnet,services-subnet"
  #  # Note: If creating for GKE cluster, then consider the following:
  #  # https://cloud.google.com/kubernetes-engine/docs/how-to/ip-aliases#considerations_for_cluster_sizing
  #  "0" = "us-central1,10.16.0.0/20,10.17.0.0/12,10.18.0.0/16"
  #}
  default = {
    "nodes"    = "10.16.0.0/20"
    "pods"     = "10.17.0.0/12"
    "services" = "10.18.0.0/16"
  }
}

variable "cluster_subnets" {
  type        = "map"
  description = "A map of index to a comma separated list of `subnet name,secondary ip range[0],secondary ip range[1]` string. Designed for GKE, but generic enough for other use cases."

  default = {
    "nodes" = "pods,services"
  }
}

variable "create_static_ip_address" {
  default     = false
  description = "Create / reserve a regional external static IP address for the network"
}

variable "static_ip_region" {
  default = "us-central1"
}

variable "dns_zones" {
  type        = "map"
  description = "Add DNS zones that will be used for this environment"

  # Example: {"prod-internal-zone" = "prod.cdw-skunk.works."}
  default = {}
}

variable "dns_records" {
  description = "Add DNS A-records pointing to our static IP address"
  type        = "map"

  # Example: {"prod-internal-zone" = "*.prod.cdw-skunk.works."}
  default = {}
}
