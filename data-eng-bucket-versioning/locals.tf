locals {
  account_id = {
    qa      = "236130610212"
    staging = "759286849978"
    prod    = "171408413795"
  }

  bucket_name = "bi-${terraform.workspace}.tenproduct.com"
}
