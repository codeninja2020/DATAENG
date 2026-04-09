CREATE TABLE [TenMAID_Global].[MemberGroup] (
    [CorporateSchemeID] INT            NULL,
    [Description]       NVARCHAR (200) NULL,
    [FolderName]        NVARCHAR (100) NULL,
    [MemberGroupID]     INT            NOT NULL,
    [Name]              NVARCHAR (200) NULL,
    [ServiceLevelID]    INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberGroup] PRIMARY KEY CLUSTERED ([MemberGroupID] ASC)
);

