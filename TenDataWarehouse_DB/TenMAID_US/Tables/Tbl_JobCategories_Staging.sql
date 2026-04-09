CREATE TABLE [TenMAID_US].[Tbl_JobCategories_Staging] (
    [CategoryID]           INT           NOT NULL,
    [CreatedOn]            SMALLDATETIME NULL,
    [IsDefault]            BIT           NULL,
    [JobID]                INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_JobCategories_Staging] PRIMARY KEY CLUSTERED ([JobID] ASC, [CategoryID] ASC)
);

