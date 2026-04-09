CREATE TABLE [TenMAID_Global].[MemberAddresses] (
    [City]                   NVARCHAR (100) NULL,
    [CreatedBy]              INT            NULL,
    [DateCreated]            DATETIME       NULL,
    [DateUpdated]            DATETIME       NULL,
    [Details]                NVARCHAR (500) NULL,
    [ForeignMemberAddressID] INT            NULL,
    [HouseName]              NVARCHAR (100) NULL,
    [HouseNumber]            NVARCHAR (100) NULL,
    [ISO_CountryID]          NCHAR (2)      NULL,
    [IsPrimary]              BIT            NULL,
    [MemberAddressID]        INT            NOT NULL,
    [MemberAddressTypeID]    INT            NULL,
    [MemberID]               INT            NULL,
    [PostCode]               NVARCHAR (50)  NULL,
    [State]                  NVARCHAR (100) NULL,
    [Street1]                NVARCHAR (200) NULL,
    [Street2]                NVARCHAR (100) NULL,
    [UpdatedBy]              INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberAddresses] PRIMARY KEY CLUSTERED ([MemberAddressID] ASC)
);

