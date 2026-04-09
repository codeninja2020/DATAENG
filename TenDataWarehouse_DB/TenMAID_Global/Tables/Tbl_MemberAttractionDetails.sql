CREATE TABLE [TenMAID_Global].[Tbl_MemberAttractionDetails] (
    [AttractionID]      INT             NOT NULL,
    [MemberID]          INT             NULL,
    [AttractionDetails] NVARCHAR (2000) NULL,
    [DateCreated]       DATETIME        NULL,
    [DateUpdated]       DATETIME        NULL,
    [CreatedBy]         INT             NULL,
    [UpdatedBy]         INT             NULL,
    CONSTRAINT [PK_Tbl_MemberAttractionDetails] PRIMARY KEY CLUSTERED ([AttractionID] ASC)
);

