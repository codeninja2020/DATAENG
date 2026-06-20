# Data Engineering Data Quality

This component manages AWS Glue Data Quality rules for Data Engineering datasets.

## TENMAID_UAT Members

The `RPIN Dataquality check` ruleset targets the `dbo.Members` table catalogued by the
`ten-data-eng-hsbc-datafeed` crawler as `tenmaid_uat_tenmaid_uat_dbo_members` in the `tenmaid_uat`
Glue Catalog database. The source location is `TENMAID_UAT.dbo.Members`. It requires `Reference1`
to be non-null for members whose `SchemeID` is `2388` or `2378`.

The component also creates a CloudWatch alarm that sends notifications to the data engineering
Slack SNS topic when the Glue Data Quality failure metric is raised for this ruleset.

After each Glue Data Quality evaluation, the Python Shell job retrieves the rule results and builds
a Pandas DataFrame containing the ruleset, score, evaluated rule, outcome, message, and metrics.
The job logs this frame and fails when any rule outcome is not `PASS`.

The component reuses the HSBC datafeed's:

- Glue Data Catalog database and crawler table;
- Glue VPC network connection;
- Glue JDBC connection;
- existing Secrets Manager JDBC credential secret.

Only the `qa` workspace is enabled. If the crawler generated a different table name, set
`glue_catalog_table_name` to the table name shown in the AWS Glue Data Catalog.
