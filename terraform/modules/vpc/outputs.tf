
output "vpc" {
  value = {
    id         = aws_vpc.this.id
    cidr_block = aws_vpc.this.cidr_block
  }
}

output "s3_vpc_endpoint" {
  value = {
    pl = aws_vpc_endpoint.s3.prefix_list_id,
    id = aws_vpc_endpoint.s3.id
  }
}

output "subnet_app" {
  value = [
    for sub in aws_subnet.app :
    { id = sub.id, cidr_block = sub.cidr_block }
  ]
}

output "subnet_dmz" {
  value = [
    for sub in aws_subnet.dmz :
    { id = sub.id, cidr_block = sub.cidr_block }
  ]
}

output "subnet_rds" {
  value = [
    for sub in aws_subnet.rds :
    { id = sub.id, cidr_block = sub.cidr_block }
  ]
}

output "subnet_endpoints" {
  value = aws_subnet.endpoints.*.id
}
