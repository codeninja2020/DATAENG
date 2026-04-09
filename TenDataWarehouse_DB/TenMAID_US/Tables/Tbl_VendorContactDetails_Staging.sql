CREATE TABLE [TenMAID_US].[Tbl_VendorContactDetails_Staging] (
    [ContactID]            INT            NOT NULL,
    [ContactMethodID]      INT            NULL,
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [Details]              NVARCHAR (500) NULL,
    [PrimaryContact]       BIT            NULL,
    [UpdatedBy]            INT            NULL,
    [Value]                NVARCHAR (255) NULL,
    [VendorID]             INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorContactDetails_Staging] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);

