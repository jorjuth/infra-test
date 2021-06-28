
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  az_count = length(data.aws_availability_zones.available.names)
}

resource "aws_vpc" "this" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = var.tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    var.tags,
    {
      "Name" = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${var.vpc_type} VPC"
    }
  )
}

resource "aws_flow_log" "this" {
  count = terraform.workspace == "prod" && var.log_bucket_arn != "" ? 1 : 0

  log_destination      = var.log_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
}

# DEFAULT SG
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
}

# DEFAULT ROUTE TABLE
resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${var.vpc_type} default table"
    }
  )
}

#
# Subnets
#
resource "aws_subnet" "endpoints" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.multi_az_cidr_shift, count.index)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${count.index} ${data.aws_availability_zones.available.names[count.index]} ${var.project_name} ${var.vpc_type} VPC Endpoints"
    }
  )
}

resource "aws_subnet" "rds" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.multi_az_cidr_shift, count.index + local.az_count)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${count.index + local.az_count} ${data.aws_availability_zones.available.names[count.index]} ${var.project_name} ${var.vpc_type} RDS"
    }
  )
}

resource "aws_subnet" "app" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.multi_az_cidr_shift, count.index + 2 * local.az_count)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${count.index + 2 * local.az_count} ${data.aws_availability_zones.available.names[count.index]} ${var.project_name} ${var.vpc_type} Applications"
    }
  )
}

resource "aws_subnet" "dmz" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.multi_az_cidr_shift, count.index + 3 * local.az_count)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${count.index + 3 * local.az_count} ${data.aws_availability_zones.available.names[count.index]} ${var.project_name} ${var.vpc_type} DMZ"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${var.vpc_type} Internet Gateway"
    }
  )
}

#
# Route tables
#
resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${var.vpc_type} Route table Internet"
    }
  )
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.internet.id
  gateway_id     = aws_internet_gateway.igw.id

  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rds" {
  count = local.az_count

  subnet_id      = aws_subnet.rds[count.index].id
  route_table_id = aws_default_route_table.this.id
}

resource "aws_route_table_association" "endpoints" {
  count = local.az_count

  subnet_id      = aws_subnet.endpoints[count.index].id
  route_table_id = aws_default_route_table.this.id
}

resource "aws_route_table_association" "app" {
  count = local.az_count

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_default_route_table.this.id
}

resource "aws_route_table_association" "dmz" {
  count = local.az_count

  subnet_id      = aws_subnet.dmz[count.index].id
  route_table_id = aws_route_table.internet.id
}

# Gateway endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${var.vpc_type} S3"
    }
  )
}

resource "aws_vpc_endpoint_route_table_association" "s3_default" {
  route_table_id  = aws_vpc.this.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_internet" {
  route_table_id  = aws_route_table.internet.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${var.vpc_type} DynamoDB"
    }
  )
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_default" {
  route_table_id  = aws_vpc.this.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_internet" {
  route_table_id  = aws_route_table.internet.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}
