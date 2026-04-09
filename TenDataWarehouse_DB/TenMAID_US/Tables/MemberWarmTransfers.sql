CREATE TABLE [TenMAID_US].[MemberWarmTransfers] (
    [CreatedBy]            INT      NULL,
    [DateCreated]          DATETIME NULL,
    [DateModified]         DATETIME NULL,
    [MemberID]             INT      NULL,
    [MemberWarmTransferID] INT      NOT NULL,
    [ModifiedBy]           INT      NULL,
    [TransferTypeID]       INT      NULL,
    [WarmTransferID]       INT      NULL,
    CONSTRAINT [PK_TenMAID_US_MemberWarmTransfers] PRIMARY KEY CLUSTERED ([MemberWarmTransferID] ASC)
);

