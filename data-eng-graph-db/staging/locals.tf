locals {
  region             = "eu-west-1"
  environment        = "staging"
  cluster_identifier = "data-eng-graph-db-staging-eu-west-1"
  subnet_group_name  = "data-eng-graph-db-staging"
  notebook_name      = "data-eng-graph-db-notebook-staging"

  instance_type       = "db.t3.medium"
  instances           = 1
  engine_version      = "1.3.3.0"
  backup_retention    = 7
  skip_final_snapshot = true
  deletion_protection = true
  iam_auth_enabled    = true
  apply_immediately   = false

  notebook_instance_type = "ml.t3.medium"
}
