CREATE TABLE [TenMAID_Global].[EmployeeAddresses] (
    [City]                  NVARCHAR (50) NULL,
    [EmployeeAddressID]     INT           NOT NULL,
    [EmployeeAddressTypeID] INT           NULL,
    [EmployeeID]            INT           NULL,
    [HouseName]             NVARCHAR (50) NULL,
    [HouseNumber]           NVARCHAR (50) NULL,
    [ISO_CountryID]         NCHAR (2)     NULL,
    [IsPrimary]             BIT           NULL,
    [PostCode]              NVARCHAR (50) NULL,
    [State]                 NVARCHAR (50) NULL,
    [Street1]               NVARCHAR (50) NULL,
    [Street2]               NVARCHAR (50) NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeAddresses] PRIMARY KEY CLUSTERED ([EmployeeAddressID] ASC)
);

