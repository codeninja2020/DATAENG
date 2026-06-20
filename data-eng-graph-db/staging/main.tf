# -----------------------------------------------------------------------------
# Shared Inputs
# -----------------------------------------------------------------------------

# Loads shared staging environment outputs such as VPC, subnet, DNS, and EKS values.
module "environment" {
  source      = "../../modules/environment"
  environment = local.environment
}

# KMS alias used to encrypt Neptune and ECR resources.
data "aws_kms_alias" "neptune" {
  name = "alias/neptune-key"
}

# Reads the staging EKS remote state so Kubernetes and IRSA resources target the existing cluster.
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "tengroup-terraform-state"
    key    = "env:/staging/eks/terraform.tfstate"
    region = "eu-west-1"
    assume_role = {
      role_arn     = "arn:aws:iam::133824686826:role/terraform-state-rw"
      session_name = "terraform-state"
    }
  }
}

# Authentication token source for the Kubernetes provider.
data "aws_eks_cluster_auth" "main" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

# EKS OIDC provider used by IRSA trust policies.
data "aws_iam_openid_connect_provider" "eks" {
  url = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
}

# -----------------------------------------------------------------------------
# ECR
# -----------------------------------------------------------------------------

# Stores immutable graph-db application images built by CI.
resource "aws_ecr_repository" "graph_db" {
  name                 = "graph-db"
  image_tag_mutability = "IMMUTABLE"

  # Scan images when they are pushed so vulnerabilities are visible before deploy.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Reuse the Neptune KMS key so image storage is encrypted at rest.
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_alias.neptune.target_key_arn
  }
}

# Removes stale ECR images to keep repository storage bounded.
resource "aws_ecr_lifecycle_policy" "graph_db" {
  repository = aws_ecr_repository.graph_db.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep the 20 most recent tagged images"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Graph DB IAM
# -----------------------------------------------------------------------------

# Allows the graph-db Kubernetes service account to assume an AWS role through EKS OIDC.
data "aws_iam_policy_document" "graph_db_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:graph-db:graph-db"]
    }

    # Require the STS audience used by IRSA.
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM role annotated onto the graph-db Kubernetes service account.
resource "aws_iam_role" "graph_db" {
  name               = "data-eng-graph-db-staging"
  assume_role_policy = data.aws_iam_policy_document.graph_db_assume.json
}

# Grants the application access to the Neptune DB resource for this account.
resource "aws_iam_role_policy" "graph_db_neptune" {
  name = "neptune-access"
  role = aws_iam_role.graph_db.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "neptune-db:*"
      Resource = "arn:aws:neptune-db:${local.region}:${local.aws_account_id}:${aws_neptune_cluster.neptune.cluster_resource_id}/*"
    }]
  })
}

# -----------------------------------------------------------------------------
# Neptune Cluster
# -----------------------------------------------------------------------------

# Security group attached to the Neptune cluster.
resource "aws_security_group" "neptune_cluster" {
  name        = "data-eng-graph-db-cluster-staging"
  description = "Neptune cluster access"
  vpc_id      = module.environment.vpc_id

  # Allow outbound traffic for managed service operations.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allows EKS application pods to connect to Neptune on the Gremlin/SPARQL HTTPS port.
resource "aws_security_group_rule" "neptune_from_eks" {
  type                     = "ingress"
  from_port                = 8182
  to_port                  = 8182
  protocol                 = "tcp"
  source_security_group_id = module.environment.eks_apps_security_group_id
  security_group_id        = aws_security_group.neptune_cluster.id
}

# Allows the SageMaker notebook to connect to Neptune for administration and testing.
resource "aws_security_group_rule" "neptune_from_notebook" {
  type                     = "ingress"
  from_port                = 8182
  to_port                  = 8182
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.neptune_notebook.id
  security_group_id        = aws_security_group.neptune_cluster.id
}

# Places Neptune in the private subnets from the shared environment module.
resource "aws_neptune_subnet_group" "neptune" {
  name       = local.subnet_group_name
  subnet_ids = module.environment.private_subnet_ids
}

# Cluster-level Neptune parameters.
resource "aws_neptune_cluster_parameter_group" "neptune" {
  family = "neptune1.3"
  name   = "data-eng-graph-db-staging"

  # Enable audit logging for database activity visibility.
  parameter {
    name  = "neptune_enable_audit_log"
    value = "1"
  }
}

# Instance-level Neptune parameter group.
resource "aws_neptune_parameter_group" "neptune" {
  family = "neptune1.3"
  name   = "data-eng-graph-db-staging-instance"
}

# Managed Neptune cluster for the graph-db service.
resource "aws_neptune_cluster" "neptune" {
  cluster_identifier           = local.cluster_identifier
  engine                       = "neptune"
  engine_version               = local.engine_version
  backup_retention_period      = local.backup_retention
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "mon:04:00-mon:05:00"
  skip_final_snapshot          = local.skip_final_snapshot
  # Terraform requires this name when final snapshots are enabled.
  final_snapshot_identifier            = "${local.cluster_identifier}-final"
  deletion_protection                  = local.deletion_protection
  apply_immediately                    = local.apply_immediately
  iam_database_authentication_enabled  = local.iam_auth_enabled
  storage_encrypted                    = true
  kms_key_arn                          = data.aws_kms_alias.neptune.target_key_arn
  neptune_subnet_group_name            = aws_neptune_subnet_group.neptune.name
  neptune_cluster_parameter_group_name = aws_neptune_cluster_parameter_group.neptune.name
  vpc_security_group_ids               = [aws_security_group.neptune_cluster.id]
  port                                 = 8182
}

# Neptune instances that serve the cluster.
resource "aws_neptune_cluster_instance" "neptune" {
  count                        = local.instances
  identifier                   = "${local.cluster_identifier}-${count.index}"
  cluster_identifier           = aws_neptune_cluster.neptune.id
  engine                       = "neptune"
  instance_class               = local.instance_type
  apply_immediately            = local.apply_immediately
  auto_minor_version_upgrade   = true
  neptune_parameter_group_name = aws_neptune_parameter_group.neptune.name
}

# Private DNS record for writer traffic.
resource "aws_route53_record" "neptune_writer" {
  zone_id    = module.environment.dns_private_zone_id
  name       = "graph-db.eks-staging.tensrv.com"
  type       = "CNAME"
  ttl        = "60"
  records    = [aws_neptune_cluster.neptune.endpoint]
  depends_on = [aws_neptune_cluster_instance.neptune]
}

# Private DNS record for reader traffic.
resource "aws_route53_record" "neptune_reader" {
  zone_id    = module.environment.dns_private_zone_id
  name       = "graph-db-reader.eks-staging.tensrv.com"
  type       = "CNAME"
  ttl        = "60"
  records    = [aws_neptune_cluster.neptune.reader_endpoint]
  depends_on = [aws_neptune_cluster_instance.neptune]
}

# -----------------------------------------------------------------------------
# Neptune Notebook
# -----------------------------------------------------------------------------

# Security group for the SageMaker notebook used to administer Neptune.
resource "aws_security_group" "neptune_notebook" {
  name        = "data-eng-graph-db-notebook-staging"
  description = "Neptune notebook outbound access"
  vpc_id      = module.environment.vpc_id

  # Permit notebook sessions to reach the Neptune cluster endpoint.
  egress {
    description     = "Neptune cluster"
    from_port       = 8182
    to_port         = 8182
    protocol        = "tcp"
    security_groups = [aws_security_group.neptune_cluster.id]
  }

  # Permit AWS API calls and package installation from the notebook.
  egress {
    description = "HTTPS for AWS APIs and package installs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Execution role trusted by SageMaker notebook instances.
resource "aws_iam_role" "neptune_notebook" {
  name = "data-eng-graph-db-notebook-staging"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
    }]
  })
}

# Allows notebook users to inspect and manage Neptune resources.
resource "aws_iam_role_policy_attachment" "neptune_notebook_neptune" {
  role       = aws_iam_role.neptune_notebook.name
  policy_arn = "arn:aws:iam::aws:policy/NeptuneFullAccess"
}

# Allows SageMaker notebook lifecycle and runtime operations.
resource "aws_iam_role_policy_attachment" "neptune_notebook_sagemaker" {
  role       = aws_iam_role.neptune_notebook.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Allows read-only access to S3 data from the notebook.
resource "aws_iam_role_policy_attachment" "neptune_notebook_s3" {
  role       = aws_iam_role.neptune_notebook.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Configures notebook startup scripts with the current Neptune endpoint.
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "neptune" {
  name      = "data-eng-graph-db-notebook-staging"
  on_create = base64encode(file("${path.module}/scripts/notebook_on_create.sh"))
  on_start = base64encode(templatefile("${path.module}/scripts/notebook_on_start.sh.tpl", {
    neptune_endpoint = aws_neptune_cluster.neptune.endpoint
    aws_region       = local.region
  }))
}

# SageMaker notebook instance deployed into a private subnet.
resource "aws_sagemaker_notebook_instance" "neptune" {
  name                   = local.notebook_name
  role_arn               = aws_iam_role.neptune_notebook.arn
  instance_type          = local.notebook_instance_type
  lifecycle_config_name  = aws_sagemaker_notebook_instance_lifecycle_configuration.neptune.name
  subnet_id              = module.environment.private_subnet_ids[0]
  security_groups        = [aws_security_group.neptune_notebook.id]
  direct_internet_access = "Disabled"

  # Wait for Neptune instances so startup scripts can resolve the endpoint.
  depends_on = [aws_neptune_cluster_instance.neptune]
}

# -----------------------------------------------------------------------------
# Kubernetes Application
# -----------------------------------------------------------------------------

# Namespace that isolates graph-db Kubernetes resources.
resource "kubernetes_namespace" "graph_db" {
  metadata {
    name = "graph-db"
  }
}

# Stores MSSQL connection details consumed by the graph-db deployment.
resource "kubernetes_secret" "graph_db_mssql" {
  metadata {
    name      = "graph-db-mssql"
    namespace = kubernetes_namespace.graph_db.metadata[0].name
  }

  type = "Opaque"

  data = {
    MSSQL_HOST     = var.mssql_host
    MSSQL_USER     = var.mssql_user
    MSSQL_PASSWORD = var.mssql_password
  }
}

# Service account annotated for IRSA so pods can assume the graph-db IAM role.
resource "kubernetes_service_account" "graph_db" {
  metadata {
    name      = "graph-db"
    namespace = kubernetes_namespace.graph_db.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.graph_db.arn
    }
  }
}

# Runs the graph-db application in EKS.
resource "kubernetes_deployment" "graph_db" {
  metadata {
    name      = "graph-db"
    namespace = kubernetes_namespace.graph_db.metadata[0].name
    labels = {
      app = "graph-db"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "graph-db"
      }
    }

    template {
      metadata {
        labels = {
          app = "graph-db"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.graph_db.metadata[0].name

        container {
          name  = "graph-db"
          image = var.image

          # Use the private writer DNS record created above.
          env {
            name  = "NEPTUNE_ENDPOINT"
            value = aws_route53_record.neptune_writer.name
          }

          env {
            name  = "NEPTUNE_PORT"
            value = "8182"
          }

          env {
            name  = "AWS_REGION"
            value = local.region
          }

          env {
            name  = "MSSQL_DATABASE"
            value = "TENMAID_UAT"
          }

          # Load MSSQL credentials from the Kubernetes secret.
          env_from {
            secret_ref {
              name = kubernetes_secret.graph_db_mssql.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              memory = "1Gi"
            }
          }
        }
      }
    }
  }

  # Ensure the database exists before starting the application workload.
  depends_on = [aws_neptune_cluster_instance.neptune]
}

# Internal ClusterIP service for graph-db pods.
resource "kubernetes_service" "graph_db" {
  metadata {
    name      = "graph-db"
    namespace = kubernetes_namespace.graph_db.metadata[0].name
  }

  spec {
    selector = {
      app = "graph-db"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}
