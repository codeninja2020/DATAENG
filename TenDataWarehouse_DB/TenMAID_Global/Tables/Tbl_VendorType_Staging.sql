CREATE TABLE [TenMAID_Global].[Tbl_VendorType_Staging] (
    [CreatedBy]            INT          NULL,
    [DateCreated]          DATETIME     NULL,
    [DateUpdated]          DATETIME     NULL,
    [TypeID]               INT          NULL,
    [UpdatedBy]            INT          NULL,
    [VendorID]             INT          NULL,
    [VendorTypeID]         INT          NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_VendorType_Staging] PRIMARY KEY CLUSTERED ([VendorTypeID] ASC)
);

