output "ec2_public_ip" {
  description = "Public IP address of the MLOps EC2 instance"
  value       = aws_instance.mlops.public_ip
}

output "api_url" {
  description = "Public URL of the FastAPI application"
  value       = "http://${aws_instance.mlops.public_ip}:8000"
}

output "health_url" {
  description = "Public health-check URL"
  value       = "http://${aws_instance.mlops.public_ip}:8000/health"
}
