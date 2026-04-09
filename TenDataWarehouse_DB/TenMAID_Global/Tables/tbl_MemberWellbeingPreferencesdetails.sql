CREATE TABLE [TenMAID_Global].[tbl_MemberWellbeingPreferencesdetails] (
    [WellbeingID]      INT             NOT NULL,
    [MemberID]         INT             NULL,
    [Wellbeingdetails] NVARCHAR (2000) NULL,
    [DateCreated]      DATETIME        NULL,
    [DateUpdated]      DATETIME        NULL,
    [CreatedBy]        INT             NULL,
    [UpdatedBy]        INT             NULL,
    CONSTRAINT [PK_tbl_MemberWellbeingPreferencesdetails] PRIMARY KEY CLUSTERED ([WellbeingID] ASC)
);

