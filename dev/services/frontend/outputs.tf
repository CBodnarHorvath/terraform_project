output "ec2_ip" {
  value       = aws_instance.techsecops-exercise.public_ip
  description = "The public IP address of the web server"
}