CREATE TABLE [TenMAID_US].[Tbl_VendorAddresses_Staging] (
    [AddressTypeID]        INT            NULL,
    [City]                 INT            NULL,
    [CountryID]            INT            NULL,
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [Details]              NVARCHAR (500) NULL,
    [HouseName]            NVARCHAR (100) NULL,
    [HouseNumber]          NVARCHAR (100) NULL,
    [IsPrimary]            BIT            NULL,
    [PostCode]             NVARCHAR (50)  NULL,
    [State]                NVARCHAR (100) NULL,
    [Street1]              NVARCHAR (100) NULL,
    [Street2]              NVARCHAR (100) NULL,
    [UpdatedBy]            INT            NULL,
    [VendorAddressID]      INT            NOT NULL,
    [VendorID]             INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorAddresses_Staging] PRIMARY KEY CLUSTERED ([VendorAddressID] ASC)
);

