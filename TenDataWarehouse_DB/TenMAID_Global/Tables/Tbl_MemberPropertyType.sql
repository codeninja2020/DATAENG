CREATE TABLE [TenMAID_Global].[Tbl_MemberPropertyType] (
    [PropertyID]   INT            NOT NULL,
    [PropertyType] NVARCHAR (100) NULL,
    [IsActive]     BIT            NULL,
    CONSTRAINT [PK_Tbl_MemberPropertyType] PRIMARY KEY CLUSTERED ([PropertyID] ASC)
);

