CREATE TABLE [TenMAID_US].[MemberAddresses_Staging] (
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
    [SYS_CHANGE_OPERATION]   NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]     BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_MemberAddresses_Staging] PRIMARY KEY CLUSTERED ([MemberAddressID] ASC)
);

