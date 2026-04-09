-- cms.S3_Download_Tracking
-- Tracks every S3 download task submitted by cms.usp_FullLoad_CMS.
-- One row per file per run.  Used during the archive phase to resolve the
-- correct rds_upload_to_s3 task_id without relying on a bare TOP (1) query.

IF NOT EXISTS (
    SELECT 1
    FROM   INFORMATION_SCHEMA.TABLES
    WHERE  TABLE_SCHEMA = 'cms'
      AND  TABLE_NAME   = 'S3_Download_Tracking'
)
BEGIN
    CREATE TABLE cms.S3_Download_Tracking (
        tracking_id   INT            IDENTITY(1,1) NOT NULL
                          CONSTRAINT PK_cms_S3_Download_Tracking PRIMARY KEY,

        -- Run identifier – same NEWID() value used as @ProcessId in the SP.
        run_id        VARCHAR(36)    NOT NULL,

        -- The bare filename (e.g. 'Dining.csv').
        file_name     NVARCHAR(260)  NOT NULL,

        -- Source S3 ARN used for the download  (maps to S3_object_arn in rds_fn_task_status).
        s3_path       NVARCHAR(500)  NOT NULL,

        -- Destination local path on the RDS host.
        local_path    NVARCHAR(500)  NOT NULL,

        -- Target table that will be loaded from this file (e.g. 'cms.Dining').
        target_table  NVARCHAR(128)  NULL,

        -- RDS task_id returned by rds_fn_task_status after the download is submitted.
        task_id       INT            NULL,

        -- Final lifecycle value (CREATED / IN_PROGRESS / SUCCESS / ERROR …).
        lifecycle     NVARCHAR(50)   NULL,

        -- Free-text status / error detail from rds_fn_task_status.task_info.
        task_info     NVARCHAR(MAX)  NULL,

        -- Timestamps.
        submitted_at  DATETIME       NOT NULL  DEFAULT GETDATE(),
        last_updated  DATETIME       NULL,
        completed_at  DATETIME       NULL
    );

    -- Index used by the archive polling query:
    --   WHERE s3_path = @s3Arn  AND  local_path = @localPath
    --   ORDER BY last_updated DESC
    CREATE NONCLUSTERED INDEX IX_cms_S3_Download_Tracking_s3_local
        ON cms.S3_Download_Tracking (s3_path, local_path, last_updated DESC)
        INCLUDE (task_id, run_id, lifecycle);

END;
GO

