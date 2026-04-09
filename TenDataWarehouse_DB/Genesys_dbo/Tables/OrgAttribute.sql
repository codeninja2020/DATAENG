CREATE TABLE [Genesys_dbo].[OrgAttribute] (
    [AttrTypeID] INT             NOT NULL,
    [FldVal]     NVARCHAR (2000) NULL,
    [OrgID]      CHAR (22)       NOT NULL,
    [Version]    INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_OrgAttribute] PRIMARY KEY CLUSTERED ([AttrTypeID] ASC, [OrgID] ASC)
);

