CREATE TABLE [TenMAID_US].[Tbl_VendorContactDetails] (
    [ContactID]       INT            NOT NULL,
    [ContactMethodID] INT            NOT NULL,
    [CreatedBy]       INT            NULL,
    [DateCreated]     DATETIME       NULL,
    [DateUpdated]     DATETIME       NULL,
    [Details]         NVARCHAR (500) NULL,
    [PrimaryContact]  BIT            NULL,
    [UpdatedBy]       INT            NULL,
    [Value]           NVARCHAR (255) NOT NULL,
    [VendorID]        INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorContactDetails] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

