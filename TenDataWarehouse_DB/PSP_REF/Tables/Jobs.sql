CREATE TABLE [PSP_REF].[Jobs] (
    [gateway_id]     NVARCHAR (255) NULL,
    [gateway_status] NVARCHAR (255) NULL,
    [jobid]          NVARCHAR (255) NULL,
    [module]         NVARCHAR (255) NULL,
    [productid]      NVARCHAR (255) NULL,
    [inserted_on]    DATETIME       NOT NULL,
    [processid]      VARCHAR (255)  NULL
);

