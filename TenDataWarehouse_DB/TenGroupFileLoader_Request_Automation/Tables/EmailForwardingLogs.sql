CREATE TABLE [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs] (
    [Message_ID]            INT             NOT NULL,
    [StartProcessingTime]   DATETIME        NULL,
    [FinishProcessingTime]  DATETIME        NULL,
    [ProcessingSuccessful]  BIT             NULL,
    [CreatedNewRequest]     BIT             NULL,
    [LinkedToRequestNumber] INT             NULL,
    [LinkedToMemberID]      INT             NULL,
    [FromEmailAddress]      NVARCHAR (512)  NULL,
    [Subject]               NVARCHAR (1024) NULL,
    [MailboxAddress]        NVARCHAR (512)  NULL,
    [SchemeId]              INT             NULL,
    UNIQUE NONCLUSTERED ([Message_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCIX_TenGroupFileLoader_Request_Automation_EmailForwardingLogs]
    ON [TenGroupFileLoader_Request_Automation].[EmailForwardingLogs];

