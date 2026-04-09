CREATE TABLE [TenMAID_US].[MemberGroup_Staging] (
    [CorporateSchemeID]    INT            NULL,
    [Description]          NVARCHAR (200) NULL,
    [FolderName]           NVARCHAR (100) NULL,
    [MemberGroupID]        INT            NOT NULL,
    [Name]                 NVARCHAR (200) NULL,
    [ServiceLevelID]       INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_MemberGroup_Staging] PRIMARY KEY CLUSTERED ([MemberGroupID] ASC)
);

