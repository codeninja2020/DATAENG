CREATE TABLE [TenMAID_Global].[Tbl_MemberGeneralSaleDetails_Staging] (
    [GeneralSaleID]        INT             NOT NULL,
    [MemberID]             INT             NULL,
    [GeneralSaleDetails]   NVARCHAR (2000) NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberGeneralSaleDetails_Staging] PRIMARY KEY CLUSTERED ([GeneralSaleID] ASC)
);

