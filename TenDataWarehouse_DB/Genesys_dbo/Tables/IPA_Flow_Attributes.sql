CREATE TABLE [Genesys_dbo].[IPA_Flow_Attributes] (
    [AttrName]   NVARCHAR (128)   NOT NULL,
    [AttrType]   TINYINT          NULL,
    [AttrValue]  NVARCHAR (MAX)   NULL,
    [FlowExecID] UNIQUEIDENTIFIER NOT NULL,
    [Version]    INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Flow_Attributes] PRIMARY KEY CLUSTERED ([AttrName] ASC, [FlowExecID] ASC)
);

