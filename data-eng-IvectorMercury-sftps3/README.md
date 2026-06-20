# data-eng-IvectorMercury-sftps3

This repository component manages the Data Engineering AWS Transfer Family SFTP service for Ivector and Mercury Hub partner file transfers. It provisions the SFTP server, a Lambda-backed custom identity provider, scoped IAM access to existing S3 landing prefixes, and a Lambda function that normalizes uploaded object names.

The component is part of the `ten-infrastructure` Terraform repository and is intended to be deployed through the standard pull request workflow. Terraform plans are run by CI, and apply runs automatically after merge.

## What It Manages

- One AWS Transfer Family server using the `SFTP` protocol
- A Lambda-backed custom identity provider for AWS Transfer Family
- Three Transfer users stored in Secrets Manager and resolved by the custom identity provider
- IAM roles and S3 access policies for each Transfer user, scoped to its folder prefix or logical directory mappings
- SSH public keys for all users, plus optional passwords for users that need password auth
- A Python 3.11 Lambda function, `data-eng-file-rename`, that strips trailing non-letter suffixes from uploaded filenames
- S3 bucket notifications on existing landing prefixes that invoke the rename Lambda
- No S3 buckets are created by this component

Existing S3 buckets are referenced by IAM policy, Transfer home directories, and Lambda configuration:

| Workspace | Bucket | Prefixes |
|---|---|---|
| `staging` | `bi-staging.tenproduct.com` | `CA_BOA_Reports/`, `ivector/`, `mercuryhub/` |
| `prod` | `bi-prod.tenproduct.com` | `CA_BOA_Reports/`, `ivector/`, `mercuryhub/` |

## Repository Layout

| Path | Purpose |
|---|---|
| `config.tf` | Terraform backend, provider versions, AWS provider configuration, and default tags |
| `locals.tf` | Workspace-specific account IDs, bucket names, prefixes, and resource names |
| `main.tf` | AWS Transfer Family, IAM, Lambda, and S3 notification resources |
| `variables.tf` | CICD role, Transfer usernames, and SSH public key inputs |
| `outputs.tf` | SFTP endpoint and managed username outputs |
| `scripts/lambda_s3_rename.py` | Lambda handler used to normalize uploaded S3 object names |
| `IVECTOR_ACCESS_README.md` | User-facing Ivector SFTP access notes |
| `PETRU_ACCESS_README.md` | User-facing Petru SFTP access notes |

## State Backend

Terraform state is stored remotely in S3:

- Bucket: `tengroup-terraform-state`
- Key: `data-eng-IvectorMercury-sftps3/terraform.tfstate`
- Region: `eu-west-1`

The backend role is used only for reading and writing Terraform state. 
Resource creation itself uses the AWS provider configuration and the `cicd_role` variable.

## Environments

This component is configured for:

- `staging`
- `prod`

Apply changes to one environment per PR.

## Variables

| Name | Description | Default |
|---|---|---|
| `cicd_role` | The name of the CICD role to assume | `cicd-tf-apply` |
| `ivector_user_name` | AWS Transfer username for the ivector user | `ivector-user` |
| `ivector_user_ssh_public_key` | SSH public key for the ivector user | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKBC3U+rkQL4EUHIkXjXU/j1XVZFoYJlNM1IdDFGE7G tinashejambo@tengroup.com` |
| `ivector_user_password` | Optional password for the ivector user | `null` |
| `mercury_hub_user_name` | AWS Transfer username for the mercury_hub user | `mercury_hub` |
| `mercury_hub_user_ssh_public_key` | SSH public key for the mercury_hub user | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKBC3U+rkQL4EUHIkXjXU/j1XVZFoYJlNM1IdDFGE7G tinashejambo@tengroup.com` |
| `mercury_hub_user_password` | Optional password for the mercury_hub user | `null` |
| `petru_user_name` | AWS Transfer username for the petru user | `petru` |
| `petru_user_ssh_public_key` | SSH public key for the petru user | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrlXV42zgHhIMrZjmF+wOQehI0di4Gkm1mCMUDLS8j1 PetruDima@tengroup.com` |
| `petru_user_password` | Optional override for the petru user password; if unset Terraform generates one | `null` |

## Authentication Inputs

The existing `ivector` and `mercury_hub` users default to the same SSH public key in this repository. The `petru` user defaults to the SSH public key defined in `variables.tf`.

Override SSH keys at plan/apply time if you need different keys, for example with:

- `TF_VAR_ivector_user_ssh_public_key`
- `TF_VAR_mercury_hub_user_ssh_public_key`
- `TF_VAR_petru_user_ssh_public_key`

Terraform passes these values to the AWS Transfer Family SSH key resources:

- `aws_secretsmanager_secret_version.transfer_user["ivector-user"]`
- `aws_secretsmanager_secret_version.transfer_user["mercury_hub"]`
- `aws_secretsmanager_secret_version.transfer_user["petru"]`

To enable password auth for a user, set the matching `*_user_password` variable during plan/apply. If `petru_user_password` is left unset, Terraform generates a random password and stores it in the user's secret. The custom identity provider reads each user's secret from Secrets Manager and returns either SSH public keys or password-backed access metadata to AWS Transfer Family.

## S3 Access Scope

Each Transfer user is restricted to its configured folder prefix rather than the whole bucket.

- `ivector` user: `ivector/`
- `mercury_hub` user: `mercuryhub/`
- `petru` user: logical directories `/ivector` and `/mercuryhub`, mapped to those same prefixes

## File Rename Lambda

The `data-eng-file-rename-${terraform.workspace}` Lambda is packaged from `scripts/lambda_s3_rename.py` and invoked by S3 object-created notifications for the configured `*/incoming/` prefixes.

For each uploaded object, the Lambda:

- Verifies that the object key starts with one of the configured landing prefixes
- Preserves the `incoming` directory, nested upload directory, and file extension
- Removes trailing non-letter suffixes from the filename stem
- Copies the object to the cleaned key and deletes the original key

The Lambda has S3 object permissions only for the watched landing prefixes and CloudWatch Logs permissions through `AWSLambdaBasicExecutionRole`.

## Outputs

- `sftp_server_endpoint`
- `ivector_sftp_user`
- `mercury_hub_sftp_user`
- `petru_sftp_user`

## User Access

Users can connect to the SFTP server from a terminal with either SSH key or password auth, depending on what is configured for that user.

SSH key example:

```bash
sftp -i /path/to/ssh/key username@s-1dffcacbad984457b.server.transfer.eu-west-1.amazonaws.com
```

Inside the SFTP session:

- Run `lpwd` to see the current local directory
- Run `lcd /path/to/files` to move to the local directory that contains the files to upload
- Run `put filename` to upload a file

It is usually easiest to open the terminal in the directory that already contains the files you want to upload.

## Notes

- The backend `assume_role` configuration is for state access only.
- The provider `assume_role` configuration is for managing infrastructure in the workspace account.
- This component does not create S3 buckets; it references existing bucket names via locals.
- The backend key and provider session name use `IvectorMercury`; rename the component directory separately if you want the filesystem path to match.
