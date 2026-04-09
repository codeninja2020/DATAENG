CREATE TABLE [Genesys_dbo].[IndivAttribute] (
    [AttrTypeID] INT             NOT NULL,
    [FldVal]     NVARCHAR (2000) NULL,
    [IndivID]    CHAR (22)       NOT NULL,
    [Version]    INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IndivAttribute] PRIMARY KEY CLUSTERED ([AttrTypeID] ASC, [IndivID] ASC)
);

