CREATE TABLE [TenMAID_Global].[Tbl_MasterCorporateGroup_Staging] (
    [AccountManager]       INT            NULL,
    [ClientName]           NVARCHAR (200) NULL,
    [CorporateGroupId]     INT            NOT NULL,
    [CreatedBy]            INT            NULL,
    [CreatedDate]          DATETIME       NULL,
    [GroupName]            NVARCHAR (200) NULL,
    [Region]               INT            NULL,
    [UpdatedBy]            INT            NULL,
    [UpdatedDate]          DATETIME       NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MasterCorporateGroup_Staging] PRIMARY KEY CLUSTERED ([CorporateGroupId] ASC)
);

