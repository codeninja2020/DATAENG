CREATE TABLE [TenMAID_US].[Tbl_MasterCorporateGroup] (
    [AccountManager]   INT            NULL,
    [ClientName]       NVARCHAR (200) NULL,
    [CorporateGroupId] INT            NOT NULL,
    [CreatedBy]        INT            NULL,
    [CreatedDate]      DATETIME       NULL,
    [GroupName]        NVARCHAR (200) NULL,
    [Region]           INT            NULL,
    [UpdatedBy]        INT            NULL,
    [UpdatedDate]      DATETIME       NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MasterCorporateGroup] PRIMARY KEY CLUSTERED ([CorporateGroupId] ASC)
);

