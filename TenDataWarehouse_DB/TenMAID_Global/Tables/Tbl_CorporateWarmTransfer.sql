CREATE TABLE [TenMAID_Global].[Tbl_CorporateWarmTransfer] (
    [CorpWarmTransID]      INT  NOT NULL,
    [SchemeID]             INT  NULL,
    [WarmTransferID]       INT  NULL,
    [ProcedureDescription] TEXT NULL,
    CONSTRAINT [PK_Tbl_CorporateWarmTransfer] PRIMARY KEY CLUSTERED ([CorpWarmTransID] ASC) WITH (FILLFACTOR = 90)
);

