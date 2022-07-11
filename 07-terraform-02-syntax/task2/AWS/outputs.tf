output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "region_name" {
  value       = data.aws_region.current.name
  description = "The region name of the main server instance."
}

output "instance_ip_addr" {
  value       = aws_instance.app_server.private_ip
  description = "The private IP address of the main server instance."
}

output "subnet_id" {
  value       = aws_subnet.my_subnet.id
  description = "The subnet ID of the main server instance."
}