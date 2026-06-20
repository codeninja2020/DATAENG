output "sftp_server_endpoint" {
  description = "AWS Transfer Family server endpoint"
  value       = aws_transfer_server.ivector.endpoint
}

output "ivector_sftp_user" {
  description = "ivector AWS Transfer Family user name"
  value       = var.ivector_user_name
}

output "mercury_hub_sftp_user" {
  description = "mercury_hub AWS Transfer Family user name"
  value       = var.mercury_hub_user_name
}

output "petru_sftp_user" {
  description = "petru AWS Transfer Family user name"
  value       = var.petru_user_name
}
