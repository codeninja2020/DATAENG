CREATE TABLE [Genesys_dbo].[InteractionAttribute] (
    [AttrTypeID] INT             NOT NULL,
    [FldVal]     NVARCHAR (2000) NULL,
    [IntxID]     CHAR (22)       NOT NULL,
    [Version]    INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_InteractionAttribute] PRIMARY KEY CLUSTERED ([AttrTypeID] ASC, [IntxID] ASC)
);

