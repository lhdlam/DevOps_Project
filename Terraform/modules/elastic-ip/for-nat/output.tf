output "eip" {
  value = aws_eip.nat_eip
  description = "NAT elastic ip"
}
