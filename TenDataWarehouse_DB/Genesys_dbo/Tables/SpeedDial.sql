CREATE TABLE [Genesys_dbo].[SpeedDial] (
    [AdditionalData]  NVARCHAR (128) NULL,
    [ContactID]       NVARCHAR (255) NOT NULL,
    [ContactSource]   NVARCHAR (64)  NOT NULL,
    [ID]              NVARCHAR (25)  NOT NULL,
    [ListID]          NVARCHAR (25)  NOT NULL,
    [SpeedDialNumber] NVARCHAR (2)   NULL,
    CONSTRAINT [PK_Genesys_dbo_SpeedDial] PRIMARY KEY CLUSTERED ([ID] ASC)
);

