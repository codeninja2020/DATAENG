CREATE TABLE [TenMAID_US].[Tbl_VendorExtraInfo] (
    [ControlID]   INT          NULL,
    [CreatedBy]   INT          NULL,
    [DateCreated] DATETIME     NULL,
    [DateUpdated] DATETIME     NULL,
    [FieldID]     INT          NOT NULL,
    [ID]          INT          NOT NULL,
    [LangID]      NVARCHAR (5) NOT NULL,
    [UpdatedBy]   INT          NULL,
    [VendorID]    INT          NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorExtraInfo] PRIMARY KEY CLUSTERED ([ID] ASC)
);

