CREATE TABLE [TenMAID_Global].[tbl_MemberWellbeingPreferencesdetails_Staging] (
    [WellbeingID]          INT             NOT NULL,
    [MemberID]             INT             NULL,
    [Wellbeingdetails]     NVARCHAR (2000) NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_tbl_MemberWellbeingPreferencesdetails_Staging] PRIMARY KEY CLUSTERED ([WellbeingID] ASC)
);

