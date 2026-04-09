CREATE TABLE [TenMAID_Global].[Tbl_VendorExtraInfo_Staging] (
    [ControlID]            INT          NULL,
    [CreatedBy]            INT          NULL,
    [DateCreated]          DATETIME     NULL,
    [DateUpdated]          DATETIME     NULL,
    [FieldID]              INT          NULL,
    [ID]                   INT          NOT NULL,
    [LangID]               NVARCHAR (5) NULL,
    [UpdatedBy]            INT          NULL,
    [VendorID]             INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_VendorExtraInfo_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

