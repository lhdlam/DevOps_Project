output "peering_id" {
  value       = aws_vpc_peering_connection.this[*].id
  description = "Peering id"
}

output "peering_status" {
  value       = aws_vpc_peering_connection.this[*].accept_status
  description = "Peering status"
}
