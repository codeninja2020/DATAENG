CREATE TABLE [Genesys_dbo].[ININSearchDefn] (
    [AttributeName]      VARCHAR (50)     NULL,
    [Conjunction]        VARCHAR (8)      NULL,
    [FieldName]          VARCHAR (50)     NULL,
    [IntegerValue]       INT              NULL,
    [IsEmpty]            INT              NULL,
    [LDateValue]         DATETIME         NULL,
    [LTimeValue]         DATETIME         NULL,
    [Operator]           VARCHAR (16)     NULL,
    [ParentSearchTermId] UNIQUEIDENTIFIER NULL,
    [RDateValue]         DATETIME         NULL,
    [RTimeValue]         DATETIME         NULL,
    [SearchId]           UNIQUEIDENTIFIER NULL,
    [SearchTermId]       UNIQUEIDENTIFIER NOT NULL,
    [Sequence]           INT              NULL,
    [StringValue]        NVARCHAR (255)   NULL,
    CONSTRAINT [PK_Genesys_dbo_ININSearchDefn] PRIMARY KEY CLUSTERED ([SearchTermId] ASC)
);

