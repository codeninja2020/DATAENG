CREATE TABLE [Genesys_dbo].[SpeedDialList] (
    [Access]   INT           NULL,
    [ID]       NVARCHAR (25) NOT NULL,
    [ListName] NVARCHAR (80) NULL,
    [Owner]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_Genesys_dbo_SpeedDialList] PRIMARY KEY CLUSTERED ([ID] ASC)
);

