CREATE TABLE [TenMAID_Global].[MemberWarmTransfers_Staging] (
    [CreatedBy]            INT             NULL,
    [DateCreated]          DATETIME        NULL,
    [DateModified]         DATETIME        NULL,
    [MemberID]             INT             NULL,
    [MemberWarmTransferID] INT             NOT NULL,
    [ModifiedBy]           INT             NULL,
    [TransferTypeID]       INT             NULL,
    [WarmTransferID]       INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    [Notes]                NVARCHAR (2000) NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberWarmTransfers_Staging] PRIMARY KEY CLUSTERED ([MemberWarmTransferID] ASC)
);

