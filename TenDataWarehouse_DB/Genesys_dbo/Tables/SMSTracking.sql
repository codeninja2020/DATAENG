CREATE TABLE [Genesys_dbo].[SMSTracking] (
    [LocalID]  NVARCHAR (50)   NOT NULL,
    [Message]  NVARCHAR (1024) NOT NULL,
    [RemoteID] NVARCHAR (50)   NOT NULL,
    [SendTime] DATETIME2 (7)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SMSTracking] PRIMARY KEY CLUSTERED ([LocalID] ASC, [RemoteID] ASC)
);

