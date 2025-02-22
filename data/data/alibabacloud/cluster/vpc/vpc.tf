
locals {
  description = "Created By OpenShift Installer"
  prefix      = var.cluster_id
  newbits     = max(4, 20 - tonumber(split("/", var.vpc_cidr_block)[1]))
  vpc_id      = var.vpc_id == "" ? alicloud_vpc.vpc.0.id : var.vpc_id
  vswitch_ids = length(var.vswitch_ids) == 0 ? alicloud_vswitch.vswitches.*.id : var.vswitch_ids
}

data "alicloud_vswitches" "vswitches" {
  ids = local.vswitch_ids
}

resource "alicloud_vpc" "vpc" {
  count = var.vpc_id == "" ? 1 : 0

  resource_group_id = var.resource_group_id
  vpc_name          = "${local.prefix}-vpc"
  cidr_block        = var.vpc_cidr_block
  description       = local.description
  tags = merge(
    {
      "Name" = "${local.prefix}-vpc"
    },
    var.tags,
  )
}

resource "alicloud_vswitch" "vswitches" {
  count = length(var.vswitch_ids) == 0 ? length(var.zone_ids) : 0

  vswitch_name = "${local.prefix}-vswitch-${var.zone_ids[count.index]}"
  description  = local.description
  vpc_id       = local.vpc_id
  cidr_block   = cidrsubnet(var.vpc_cidr_block, local.newbits, count.index)
  zone_id      = var.zone_ids[count.index]
  tags = merge(
    {
      "Name" = "${local.prefix}-vswitch-${var.zone_ids[count.index]}"
    },
    var.tags,
  )
}

resource "alicloud_vswitch" "vswitch_nat_gateway" {
  vswitch_name = "${local.prefix}-vswitch-nat-gateway"
  description  = local.description
  vpc_id       = local.vpc_id
  cidr_block   = cidrsubnet(var.vpc_cidr_block, local.newbits, local.newbits)
  zone_id      = var.nat_gateway_zone_id
  tags = merge(
    {
      "Name" = "${local.prefix}-vswitch-nat-gateway"
    },
    var.tags,
  )
}
