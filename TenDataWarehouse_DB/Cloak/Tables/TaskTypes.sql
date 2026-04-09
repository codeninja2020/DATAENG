CREATE TABLE [Cloak].[TaskTypes] (
    [Name]     VARCHAR (255) NOT NULL,
    [Outbound] INT           NOT NULL,
    [SiteID]   INT           NULL,
    [TTID]     INT           NOT NULL,
    CONSTRAINT [PK_Cloak_TaskTypes] PRIMARY KEY CLUSTERED ([TTID] ASC)
);

