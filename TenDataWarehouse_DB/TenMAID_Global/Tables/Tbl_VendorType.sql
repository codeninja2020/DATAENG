CREATE TABLE [TenMAID_Global].[Tbl_VendorType] (
    [CreatedBy]    INT      NULL,
    [DateCreated]  DATETIME NULL,
    [DateUpdated]  DATETIME NULL,
    [TypeID]       INT      NOT NULL,
    [UpdatedBy]    INT      NULL,
    [VendorID]     INT      NOT NULL,
    [VendorTypeID] INT      NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_VendorType] PRIMARY KEY CLUSTERED ([VendorTypeID] ASC)
);

