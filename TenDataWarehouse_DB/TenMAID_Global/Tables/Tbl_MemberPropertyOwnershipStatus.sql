CREATE TABLE [TenMAID_Global].[Tbl_MemberPropertyOwnershipStatus] (
    [OwnershipID]     INT            NOT NULL,
    [OwnershipStatus] NVARCHAR (100) NULL,
    [IsActive]        BIT            NULL,
    CONSTRAINT [PK_Tbl_MemberPropertyOwnershipStatus] PRIMARY KEY CLUSTERED ([OwnershipID] ASC)
);

