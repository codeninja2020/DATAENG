CREATE TABLE [TenMAID_Global].[MemberWarmTransfers] (
    [CreatedBy]            INT             NULL,
    [DateCreated]          DATETIME        NULL,
    [DateModified]         DATETIME        NULL,
    [MemberID]             INT             NULL,
    [MemberWarmTransferID] INT             NOT NULL,
    [ModifiedBy]           INT             NULL,
    [TransferTypeID]       INT             NULL,
    [WarmTransferID]       INT             NULL,
    [Notes]                NVARCHAR (2000) NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberWarmTransfers] PRIMARY KEY CLUSTERED ([MemberWarmTransferID] ASC)
);

