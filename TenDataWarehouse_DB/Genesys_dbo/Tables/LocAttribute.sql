CREATE TABLE [Genesys_dbo].[LocAttribute] (
    [AttrTypeID] INT             NOT NULL,
    [FldVal]     NVARCHAR (2000) NULL,
    [LocID]      CHAR (22)       NOT NULL,
    [Version]    INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_LocAttribute] PRIMARY KEY CLUSTERED ([AttrTypeID] ASC, [LocID] ASC)
);

