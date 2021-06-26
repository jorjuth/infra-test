
output "cluster_endpoints" {
  value = [aws_rds_cluster.this.endpoint, aws_rds_cluster.this.reader_endpoint]
}

output "instance_endpoints" {
  value = aws_rds_cluster_instance.this.*.endpoint
}

output "sg_rds_id" {
  value = aws_security_group.this.id
}

output "rds_credentials" {
  value = {
    hostname = aws_rds_cluster.this.endpoint
    login    = aws_rds_cluster.this.master_username
    pass     = aws_rds_cluster.this.master_password
  }
  sensitive = true
}

output "cluster_arns" {
  value = aws_rds_cluster.this.arn
}

output "cluster_ids" {
  value = aws_rds_cluster.this.id
}

output "instance_arns" {
  value = aws_rds_cluster_instance.this.*.arn
}
