CREATE TABLE [TenMAID_Global].[Tbl_MemberGeneralSaleDetails] (
    [GeneralSaleID]      INT             NOT NULL,
    [MemberID]           INT             NULL,
    [GeneralSaleDetails] NVARCHAR (2000) NULL,
    [DateCreated]        DATETIME        NULL,
    [DateUpdated]        DATETIME        NULL,
    [CreatedBy]          INT             NULL,
    [UpdatedBy]          INT             NULL,
    CONSTRAINT [PK_Tbl_MemberGeneralSaleDetails] PRIMARY KEY CLUSTERED ([GeneralSaleID] ASC)
);

