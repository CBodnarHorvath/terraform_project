output "public_ip" {
  value       = aws_instance.techsecops-exercise.public_ip
  description = "The public IP address of the web server"
}
output "public_ip" {
  description = "Contains the public IP address"
  value       = aws_eip.default.public_ip
}