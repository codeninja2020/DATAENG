# CICD role name used by the AWS provider assume_role block.
variable "cicd_role" {
  description = "The name of the CICD role to assume"
  type        = string
  default     = "cicd-tf-apply"
}

# AWS Transfer Family username for the Ivector SFTP account.
variable "ivector_user_name" {
  description = "AWS Transfer Family username for the ivector SFTP user"
  type        = string
  default     = "ivector-user"
}

# SSH public key registered on the Ivector Transfer Family user.
variable "ivector_user_ssh_public_key" {
  description = "SSH public key for the ivector AWS Transfer Family user"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKBC3U+rkQL4EUHIkXjXU/j1XVZFoYJlNM1IdDFGE7G tinashejambo@tengroup.com"
  sensitive   = true
}

variable "ivector_user_password" {
  description = "Optional password for the ivector AWS Transfer Family user when password auth is enabled"
  type        = string
  default     = null
  sensitive   = true
}

# AWS Transfer Family username for the Mercury Hub SFTP account.
variable "mercury_hub_user_name" {
  description = "AWS Transfer Family username for the mercury_hub SFTP user"
  type        = string
  default     = "mercury_hub"
}

# SSH public key registered on the Mercury Hub Transfer Family user.
variable "mercury_hub_user_ssh_public_key" {
  description = "SSH public key for the mercury_hub AWS Transfer Family user"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKBC3U+rkQL4EUHIkXjXU/j1XVZFoYJlNM1IdDFGE7G tinashejambo@tengroup.com"
  sensitive   = true
}

variable "mercury_hub_user_password" {
  description = "Optional password for the mercury_hub AWS Transfer Family user when password auth is enabled"
  type        = string
  default     = null
  sensitive   = true
}

# AWS Transfer Family username for the Petru SFTP account.
variable "petru_user_name" {
  description = "AWS Transfer Family username for the petru SFTP user"
  type        = string
  default     = "petru"
}

# SSH public key registered on the Petru Transfer Family user.
variable "petru_user_ssh_public_key" {
  description = "SSH public key for the petru AWS Transfer Family user"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5b5GdPbBftjXhyVCFP6pis/USnqcZeTDYulsZ6QO9kZmatNYv7myGWA7jGhmkaY3zI2UhYZj8IvLQdIjt2KPfFF+FDjAjrTbFURevMiruYovQRn6TURw5XIOw2HTkoT8rxr4yui0AZmMGbXnmNEX4pU3XSZF8J0JS9beqQcVg6LSGH40lKa0UdQsViaFzb58cxJB8GsIX8q5bC/lDILLuiYkOaWK7l6f0nTkbF5sa+XgJ6m9+4Hkp4XzAtTOhKZWCr603fXiul89rzDwM/BcFngO2GSHKFprz//0YrbxaG5Y0CVdOpKoA+uwmuCu4ZCU5o8ZoW3jGN2x6y4j7Qxg3 isdev@Ten-TestWeb"
  sensitive   = true
}

variable "petru_user_password" {
  description = "Optional password for the petru AWS Transfer Family user when password auth is enabled"
  type        = string
  default     = null
  sensitive   = true
}
