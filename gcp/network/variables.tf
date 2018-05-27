# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "project_services" {
  type        = "list"
  description = "Google Cloud APIs to enable for the GCP project."

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

# ------------------------------------------------------------------------------
# SUBNET VARIABLES
# ------------------------------------------------------------------------------

variable "cluster_subnets" {
  type        = "map"
  description = "A map of subnet names to their list of secondary ip range names."

  default = {
    "nodes" = "pods,services"
  }
}

variable "cluster_subnet_ranges" {
  type        = "map"
  description = "A map of names to cidr ranges. In the context of GCP, these named ranges are applicable to both subnets and their secondary ip ranges. IOW, the names could represent either a subnet or one of its secondary ip ranges (see cluster_subnets)"

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

variable "cluster_subnet_regions" {
  type        = "map"
  description = "A map of names to GCP regions where they will be located."

  default = {
    "nodes" = "us-central1"
  }
}

variable "create_static_ip_address" {
  default     = false
  description = "Create / reserve a regional external static IP address for the network."
}

variable "static_ip_region" {
  default = "us-central1"
}

variable "dns_zones" {
  type        = "map"
  description = "Add DNS zones that will be used for this environment."

  # Example: {"prod-internal-zone" = "prod.cdw-skunk.works."}
  default = {}
}

variable "dns_records" {
  description = "Add DNS A-records pointing to our static IP address."
  type        = "map"

  # Example: {"prod-internal-zone" = "*.prod.cdw-skunk.works."}
  default = {}
}
