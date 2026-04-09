CREATE TABLE [TenMAID_Global].[Tbl_CorporateWarmTransfer_Staging] (
    [CorpWarmTransID]      INT          NOT NULL,
    [SchemeID]             INT          NULL,
    [WarmTransferID]       INT          NULL,
    [ProcedureDescription] TEXT         NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_Tbl_CorporateWarmTransfer_Staging] PRIMARY KEY CLUSTERED ([CorpWarmTransID] ASC) WITH (FILLFACTOR = 90)
);

