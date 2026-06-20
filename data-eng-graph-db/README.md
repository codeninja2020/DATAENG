# data-eng-graph-db

Graph database infrastructure for the Data Engineering team. Provisions an **AWS Neptune** cluster on EKS and a companion **SageMaker Notebook** for interactive graph exploration, plus a Python application that syncs member data from SQL Server into Neptune.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  EKS (staging)                                                   │
│                                                                  │
│  ┌────────────────────────────────┐                             │
│  │  Namespace: graph-db           │                             │
│  │                                │                             │
│  │  graph-db (Deployment)         │──── IRSA ────► IAM Role    │
│  │  ├─ reads Members from MSSQL  │                  │           │
│  │  └─ upserts to Neptune         │                  ▼           │
│  │       via Gremlin + SigV4      │            neptune-db:*     │
│  └────────────────────────────────┘                             │
└──────────────────────────────────────────────────────────────────┘
          │  port 8182
          ▼
┌──────────────────────────────────────────────────────────────────┐
│  AWS Neptune Cluster (data-eng-graph-db-staging-eu-west-1)       │
│  Engine: neptune 1.3.3.0 │ Instance: db.t3.medium (×1)          │
│  Encrypted: KMS alias/neptune-key │ IAM auth: enabled           │
│                                                                  │
│  Writer CNAME: graph-db.eks-staging.tensrv.com                   │
│  Reader CNAME: graph-db-reader.eks-staging.tensrv.com            │
└──────────────────────────────────────────────────────────────────┘
          ▲  port 8182
          │
┌─────────────────────────────────┐
│  SageMaker Notebook (ml.t3.medium) │
│  graph_notebook library          │
│  No direct internet access       │
└─────────────────────────────────┘
```

---

## Components

### Terraform (`staging/`)

| File | Description |
|---|---|
| `config.tf` | Provider config (AWS `6.46.0`, Kubernetes `2.37.1`), S3 backend, CICD role assumption, default resource tags |
| `locals.tf` | Environment-specific values (instance type, engine version, retention, flags) |
| `variables.tf` | Input variables — container image URI and MSSQL credentials |
| `main.tf` | Environment module inputs, EKS remote state, ECR, Neptune, IAM, Kubernetes, DNS, and SageMaker Notebook resources |
| `outputs.tf` | Component outputs |
| `scripts/notebook_on_create.sh` | SageMaker Notebook lifecycle script that installs `graph-notebook` |
| `scripts/notebook_on_start.sh.tpl` | SageMaker Notebook startup template that writes the Neptune connection config |

### Python Application (`app/`)

| File | Description |
|---|---|
| `main.py` | Entry point — ensures Neptune indexes, iterates over MSSQL batches, calls writer |
| `reader.py` | Reads `Members` table from SQL Server in pages of 500 rows via `pyodbc` |
| `writer.py` | Upserts nodes/relationships to Neptune via Gremlin over HTTPS with SigV4 signing |
| `Dockerfile` | Python 3.11-slim + ODBC Driver 18 for SQL Server |
| `requirements.txt` | `pyodbc`, `requests`, `requests-aws4auth`, `boto3` |

---

## Graph Data Model

The graph is written to Neptune with Gremlin. The application upserts one `Member`
vertex per source member row, then links it to `Programme` and `Location`
vertices when the source data contains those values.

```groovy
// Member vertex
g.V().has('Member', 'memberId', memberId).
  fold().
  coalesce(
    unfold(),
    addV('Member').property('memberId', memberId)
  )

// Programme enrollment edge
g.V().has('Member', 'memberId', memberId).as('member').
  V().has('Programme', 'schemeId', schemeId).as('programme').
  coalesce(
    __.select('member').outE('ENROLLED_IN').where(inV().as('programme')),
    __.select('member').addE('ENROLLED_IN').to('programme')
  )

// Location edge
g.V().has('Member', 'memberId', memberId).as('member').
  V().has('Location', 'city', city).as('location').
  coalesce(
    __.select('member').outE('LOCATED_IN').where(inV().as('location')),
    __.select('member').addE('LOCATED_IN').to('location')
  )
```

| Node | Key property | Description |
|---|---|---|
| `Member` | `memberId` | Ten member record (name, DOB, email, mobile, references, etc.) |
| `Programme` | `schemeId` | Loyalty/rewards scheme a member is enrolled in |
| `Location` | `city` | Geographic location of a member |

All writes use `coalesce(unfold, addV/addE)` (upsert semantics) — reruns are idempotent.

---

## Infrastructure Details

### Neptune Cluster

| Parameter | Value |
|---|---|
| Engine | Neptune 1.3.3.0 |
| Instance | `db.t3.medium` (1 instance) |
| Port | 8182 |
| Encryption | KMS (`alias/neptune-key`) |
| IAM auth | Enabled |
| Backup retention | 7 days |
| Backup window | 02:00–03:00 UTC |
| Maintenance window | Monday 04:00–05:00 UTC |
| Deletion protection | Enabled |

### Networking

Neptune is placed in **private subnets** and protected by a dedicated security group. Ingress on port 8182 is allowed only from:
- The EKS apps security group (application traffic)
- The SageMaker Notebook security group (interactive exploration)

The SageMaker Notebook has **no direct internet access** — egress is restricted to port 8182 (Neptune) and port 443 (AWS APIs and package installs).

### DNS (Private Hosted Zone)

| Record | Points to |
|---|---|
| `graph-db.eks-staging.tensrv.com` | Neptune writer endpoint |
| `graph-db-reader.eks-staging.tensrv.com` | Neptune reader endpoint |

### IAM

| Role | Used by | Permissions |
|---|---|---|
| `data-eng-graph-db-staging` | EKS pod (via IRSA) | `neptune-db:*` on the cluster |
| `data-eng-graph-db-notebook-staging` | SageMaker Notebook | `NeptuneFullAccess`, `AmazonSageMakerFullAccess`, `AmazonS3ReadOnlyAccess` |

---

## Environments

| Environment | Workspace | AWS Account |
|---|---|---|
| staging | `staging` | `759286849978` |

Only `staging` is currently configured. Follow the standard rollout process (`qa` → `staging` → `prod`) when adding new environments.

---

## Variables

| Variable | Description | Sensitive |
|---|---|---|
| `image` | Container image URI (e.g. `759286849978.dkr.ecr.eu-west-1.amazonaws.com/graph-db:latest`) | No |
| `mssql_host` | SQL Server hostname or IP for `TENMAID_UAT` | No |
| `mssql_user` | SQL Server login username | No |
| `mssql_password` | SQL Server login password | **Yes** |

---

## Application Environment Variables

Set automatically by the Kubernetes Deployment or the Secret:

| Variable | Source | Description |
|---|---|---|
| `NEPTUNE_ENDPOINT` | Terraform | Neptune writer CNAME |
| `NEPTUNE_PORT` | Terraform | `8182` |
| `AWS_REGION` | Terraform | `eu-west-1` |
| `MSSQL_DATABASE` | Terraform | `TENMAID_UAT` |
| `MSSQL_HOST` | Kubernetes Secret | SQL Server host |
| `MSSQL_USER` | Kubernetes Secret | SQL Server user |
| `MSSQL_PASSWORD` | Kubernetes Secret | SQL Server password |
| `MSSQL_TABLE` | Optional (default: `Members`) | Source table name |

---

## SageMaker Notebook

The notebook instance (`data-eng-graph-db-notebook-staging`, `ml.t3.medium`) is pre-configured with the [`graph_notebook`](https://github.com/aws/graph-notebook) library and connected to the Neptune writer endpoint. It uses **Gremlin** for all graph queries.

**Lifecycle scripts:**
- `notebook_on_create.sh` — installs `graph-notebook` and its Jupyter extensions.
- `notebook_on_start.sh.tpl` — writes `graph_notebook_config.json` pointing to the Neptune endpoint with IAM auth.

---

## CI/CD

GitHub Actions runs `terraform plan` on every PR and posts the output as a comment. On merge, `terraform apply` runs automatically.

The component is registered with CI via `.component_config.yml`:

```yaml
environments:
  - staging
```

State is stored in:
```
s3://tengroup-terraform-state/data-eng-graph-db/staging/terraform.tfstate
```

---

## Useful Gremlin Queries

```groovy
// Count all vertices by label
g.V().groupCount().by(T.label)

// Find a member by ID
g.V().has('Member', 'memberId', 123456)

// Show all programmes a member is enrolled in
g.V().has('Member', 'memberId', 123456).out('ENROLLED_IN')

// Members in a given city
g.V().has('Location', 'city', 'London').in('LOCATED_IN').valueMap('firstName', 'surname')
```
