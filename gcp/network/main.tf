# ------------------------------------------------------------------------------
# GOOGLE CLOUD PROJECT
# ------------------------------------------------------------------------------

resource "google_project_service" "services" {
  count = "${length(var.project_services)}"

  disable_on_destroy = false

  service = "${element(var.project_services, count.index)}"

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# ------------------------------------------------------------------------------
# VPC NETWORK, SUBNETS, FIREWALL RULES
# ------------------------------------------------------------------------------

resource "google_compute_network" "network" {
  depends_on = ["google_project_service.services"]

  name                    = "network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  count = "${length(var.cluster_subnets)}"

  # element(list, index) - Returns a single element from a list at the given
  # index. If the index is greater than the number of elements, this function
  # will wrap using a standard mod algorithm. This function only works on flat
  # lists.
  #
  # keys(map) - Returns a lexically sorted list of map keys.
  name = "${element(keys(var.cluster_subnets), count.index)}"

  network = "${google_compute_network.network.self_link}"

  # lookup(map, key, [default]) - Performs a dynamic lookup into a map
  # variable. The map parameter should be another variable, such as var.amis.
  # If key does not exist in map, the interpolation will fail unless you
  # specify a third argument, default, which should be a string value to return
  # if no key is found in map. This function only works on flat maps and will
  # return an error for maps that include nested lists or maps.
  ip_cidr_range = "${lookup(var.cluster_subnet_ranges, element(keys(var.cluster_subnets), count.index))}"

  # split(delim, string) - Splits the string previously created by join back
  # into a list. This is useful for pushing lists through module outputs since
  # they currently only support string values. Depending on the use, the string
  # this is being performed within may need to be wrapped in brackets to
  # indicate that the output is actually a list, e.g. a_resource_param
  # = ["${split(",", var.CSV_STRING)}"]. Example: split(",",
  # module.amod.server_ids)
  region = "${lookup(var.cluster_subnet_regions, element(keys(var.cluster_subnets), count.index))}"

  private_ip_google_access = true

  secondary_ip_range = [
    {
      range_name = "${element(split(",", lookup(var.cluster_subnets, element(keys(var.cluster_subnets), count.index))), 0)}"

      ip_cidr_range = "${lookup(var.cluster_subnet_ranges, element(split(",", lookup(var.cluster_subnets, element(keys(var.cluster_subnets), count.index))), 0)  )}"
    },
    {
      range_name = "${element(split(",", lookup(var.cluster_subnets, element(keys(var.cluster_subnets), count.index))), 1)}"

      ip_cidr_range = "${lookup(var.cluster_subnet_ranges, element(split(",", lookup(var.cluster_subnets, element(keys(var.cluster_subnets), count.index))), 1)  )}"
    },
  ]
}

# ------------------------------------------------------------------------------
# EXTERNAL IP ADDRESS
# ------------------------------------------------------------------------------

resource "google_compute_address" "ingress_controller_ip" {
  count      = "${var.create_static_ip_address ? 1 : 0}"
  depends_on = ["google_project_service.services"]

  name         = "ingress-controller-ip"
  region       = "${var.static_ip_region}"
  address_type = "EXTERNAL"
}

# ------------------------------------------------------------------------------
# DNS ZONES AND RECORDS
# ------------------------------------------------------------------------------

resource "google_dns_managed_zone" "dns_zones" {
  count      = "${length(var.dns_zones) > 0 ? length(var.dns_zones) : 0}"
  depends_on = ["google_project_service.services"]

  name     = "${element(keys(var.dns_zones), count.index)}"
  dns_name = "${element(values(var.dns_zones), count.index)}"
}

resource "google_dns_record_set" "dns_records" {
  depends_on = ["google_dns_managed_zone.dns_zones"]

  count = "${length(var.dns_zones) > 0 &&
              length(var.dns_records) > 0 && var.create_static_ip_address
              ? length(var.dns_records) : 0}"

  type = "A"
  ttl  = 3600

  managed_zone = "${element(keys(var.dns_records),
                    count.index)}"

  name = "${element(values(var.dns_records),
                      count.index)}"

  rrdatas = ["${google_compute_address.ingress_controller_ip.0.address}"]
}
