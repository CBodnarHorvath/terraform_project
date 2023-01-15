output "public_ip" {
  value       = aws_instance.techsecops-exercise.public_ip
  description = "The public IP address of the web server"
}
output "elastic_ip" {
  value       = aws_instance.myeip.public_ip
  description = "The elastic IP address of the web server"
}