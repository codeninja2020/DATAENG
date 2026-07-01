# DATAENG — Data Engineering & ETL Infrastructure

A comprehensive data engineering repository containing ETL pipelines, data warehouse automation, and cloud infrastructure configurations for the TenProduct ecosystem.

## 🏗️ Project Structure

### Languages & Composition
- **T-SQL** (69.1%) — Data warehouse procedures, DDL, and bulk load scripts
- **Python** (21.1%) — ETL orchestration and data processing scripts
- **HCL** (6.4%) — Terraform infrastructure-as-code for AWS
- **Jupyter Notebook** (1.8%) — Data exploration and analysis
- **HTML / RTF** (1.6%) — Documentation and configuration files

---

## 📁 Main Components

### 1. **Django_Import** — SSIS & SQL-based ETL
A production SSIS 2019 project that imports Django web application data (PostgreSQL exports) into the TenDataWarehouse SQL Server database.

**Key Details:**
- **Source**: Pipe-delimited CSV files from S3 (`bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV`)
- **Destination**: `[django].*` schema in TenDataWarehouse (LDCSQLPD23)
- **38 Load Packages**: One per data entity (articles, dining, entertainment, travel, members, etc.)
- **Parallel Execution**: All packages run concurrently via orchestrator
- **Orchestrators**: 
  - `Control.dtsx` — Main coordinator (S3 download → parallel load → S3 archive)
  - `Control_MemberProfile.dtsx` — Dedicated processor for high-volume member profiles
- **Template Pattern**: All packages cloned from `_Load TEMPLATE.dtsx`

👉 [Full Django_Import Documentation](Django_Import/README.md)

---

### 2. **Django S3 Loader** — T-SQL Alternative to SSIS
A modern SQL Server stored procedure (`dhango_agent_jobscript13.sql`) that replaces legacy SSIS packages with native T-SQL.

**Key Details:**
- **Procedure**: `django.usp_Download_And_Load_S3_Files`
- **RDS Helper Procs**: Uses `msdb.dbo.rds_download_from_s3`, `rds_fn_task_status`, `rds_delete_from_filesystem`
- **Features**:
  - Automatic schema & table creation (with type inference from headers)
  - Asynchronous S3 download with task polling
  - Bulk insert with `TRY_CONVERT` type safety
  - Audit tracking tables: `S3_Download_Tracking`, `S3_Load_Tracking`
- **Use Case**: Deploy on RDS instances; works offline with local CSV copies

👉 [Full Django S3 Loader Documentation](README.md#django-s3-loader) *(See above file)*

---

### 3. **Airflow** — AWS Managed Workflows for Apache Airflow (MWAA)
Local development environment and orchestration setup for Apache Airflow using Docker.

**Key Details:**
- **Base**: AWS MWAA local-runner (replicates production MWAA environment)
- **Components**:
  - DAG examples: Lambda integration, Redshift data queries, TaskFlow API
  - Docker setup: Includes bootstrap, startup scripts, and constraints
  - Plugins directory for custom operators
  - Requirements management for Python dependencies
- **Running Locally**:
  ```bash
  ./mwaa-local-env build-image
  ./mwaa-local-env start
  # Access: http://localhost:8080 (admin / test)
  ```

👉 [Full Airflow Documentation](Airflow/README.md)

---

### 4. **Infrastructure as Code** — Terraform (HCL)
Cloud infrastructure definitions for AWS resources supporting the data platform.

**Typical Contents:**
- Networking: VPCs, security groups, route tables
- Compute: EC2 instances, Lambda functions
- Storage: S3 buckets, configuration and versioning
- Databases: RDS instances for SQL Server
- Orchestration: State files and module organization

---

### 5. **Python Scripts & Notebooks**
- ETL transformation logic
- Data validation and quality checks
- Analytics and exploratory data analysis (Jupyter notebooks)

---

## 🚀 Quick Start

### Prerequisites
- **For SSIS**: SQL Server Integration Services 2019+, SSDT
- **For T-SQL**: SQL Server 2016+ (RDS or on-premise)
- **For Airflow**: Docker Desktop, Python 3.8+
- **For Terraform**: Terraform CLI, AWS CLI, valid AWS credentials
- **For Python**: Python 3.8+, pip, dependencies in requirements files

### Running Django Import (SSIS)
1. Open `Django_Import/Control.dtsx` in SQL Server Data Tools (SSDT)
2. Configure connection managers:
   - `DestinationServer_OLEDB` → LDCSQLPD23 / TenDataWarehouse
   - AWS CLI path and S3 credentials
3. Execute `Control.dtsx` to orchestrate all 38 packages

### Running Django S3 Loader (T-SQL)
1. Connect to TenDataWarehouse on your RDS instance
2. Execute `dhango_agent_jobscript13.sql`
3. Run the procedure:
   ```sql
   EXEC django.usp_Download_And_Load_S3_Files;
   ```
4. Monitor tables:
   ```sql
   SELECT * FROM django.S3_Download_Tracking ORDER BY id DESC;
   SELECT * FROM django.S3_Load_Tracking ORDER BY id DESC;
   ```

### Running Airflow Locally
```bash
cd Airflow
./mwaa-local-env build-image     # Build Docker image (~10 mins)
./mwaa-local-env start            # Start Airflow UI and PostgreSQL
# Browse to http://localhost:8080
# Add DAGs to dags/ folder; they auto-reload
./mwaa-local-env stop             # Graceful shutdown
```

---

## 📊 Data Domains

The Django_Import project handles 5 major data domains (39 entities total):

| Domain | Entity Count | Examples |
|--------|--------------|----------|
| **Dining** | 5 | Restaurants, cuisines, celebrity chefs, hot tables, bookings |
| **Entertainment** | 7 | Events, artists, bookings, performances, ticket types, venues, delivery |
| **Travel** | 4 | Hotels, airports, airport groups, car hire depots |
| **Members** | 8 | Profiles, details, benefits, events, bookings, dates, tags |
| **Content / Config** | 7 | Articles, brands, email templates, jobs, partners, sites, tags |
| **Location** | 3 | Cities, countries, location tags |
| **Junction Tables** | 4 | Benefit–sites, benefit–tags, event–tags, entertainment–tags |

---

## 🔄 Data Flow

```
┌─────────────────────────────────────┐
│    S3 (bi-prod.tenproduct.com)      │
│  BE_DJANGO_POSTGRES_CSV/{entity}.csv│
└────────────────┬────────────────────┘
                 │
         ┌───────▼────────┐
         │ Download       │
         │ (SSIS/T-SQL)   │
         └───────┬────────┘
                 │
     ┌───────────▼───────────┐
     │   Local Staging       │
     │   S:\TenDataWarehouse │
     │   Dependencies\…      │
     └───────────┬───────────┘
                 │
     ┌───────────▼──────────────┐
     │  Truncate & Transform    │
     │  (SSIS / T-SQL)          │
     │  - Add audit columns     │
     │  - Type conversion       │
     │  - Parallel processing   │
     └───────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │  TenDataWarehouse         │
    │  [django].* Tables        │
    │  (LDCSQLPD23)             │
    └────────────┬──────────────┘
                 │
        ┌────────▼─────────┐
        │ Archive to S3    │
        │ (Archive folder) │
        └──────────────────┘
```

---

## 🛠️ Maintenance & Monitoring

### SSIS Packages
- **Job Scheduling**: SQL Agent jobs or SQL Server Integration Services Catalog
- **Logging**: Event logs in SSIS Catalog; check `dbo.ssis_log` tables
- **Troubleshooting**:
  - Flat file encoding issues → verify UTF-8 and pipe delimiter (`|`)
  - Connection failures → test DestinationServer_OLEDB connectivity
  - Type mismatches → inspect CSV headers and verify `TRY_CONVERT` logic

### T-SQL Procedures
- **Task Monitoring**: Query `django.S3_Download_Tracking` and `django.S3_Load_Tracking`
- **Error Handling**: Stored procedure wraps operations in `TRY_CATCH` blocks
- **Retry Logic**: Built-in polling for async RDS S3 downloads

### Airflow DAGs
- **Logs**: `./logs/` directory in local runner
- **Scheduler**: Check DAG parsing for syntax errors
- **Connections**: Configure AWS credentials via Airflow UI or `.env` file

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| [Django_Import/README.md](Django_Import/README.md) | Complete SSIS project guide, all 39 packages, architecture, alt. implementations |
| [Airflow/README.md](Airflow/README.md) | Local MWAA setup, DAG examples, troubleshooting |
| `dhango_agent_jobscript13.sql` | T-SQL replacement for SSIS (in repo root) |

---

## 🤝 Contributing

- Document any new ETL packages or DAGs
- Follow naming conventions: `{source}_{target}`, e.g., `django_load_articles`
- Add audit columns (`inserted_on`, `processid`) to all bulk loads
- Test with both small sample sets and full data volumes
- Include error handling and retry logic for production deployments

---

## 📝 License & Notes

- Repo contains production data pipeline configurations
- Sensitive credentials (S3 paths, SQL Server names) are environment-specific
- Always test in non-production environments before deploying to TenDataWarehouse

---

## 🔗 Key Endpoints & Resources

- **S3 Bucket**: `s3://bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV/`
- **SQL Server**: `LDCSQLPD23` (TenDataWarehouse)
- **AWS MWAA Docs**: https://docs.aws.amazon.com/mwaa/
- **SSIS Best Practices**: https://docs.microsoft.com/en-us/sql/integration-services/
- **Apache Airflow Docs**: https://airflow.apache.org/docs/

---

**Last Updated**: February 2026  
**Repository**: codeninja2020/DATAENG
