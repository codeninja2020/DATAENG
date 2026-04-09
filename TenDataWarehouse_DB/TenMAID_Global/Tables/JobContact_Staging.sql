CREATE TABLE [TenMAID_Global].[JobContact_Staging] (
    [JobContactID]         INT            NOT NULL,
    [Name]                 NVARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_JobContact_Staging] PRIMARY KEY CLUSTERED ([JobContactID] ASC)
);

