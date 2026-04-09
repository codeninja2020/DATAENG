CREATE TABLE [TenMAID_Global].[Tbl_MemberAttractionDetails_Staging] (
    [AttractionID]         INT             NOT NULL,
    [MemberID]             INT             NULL,
    [AttractionDetails]    NVARCHAR (2000) NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberAttractionDetails_Staging] PRIMARY KEY CLUSTERED ([AttractionID] ASC)
);

