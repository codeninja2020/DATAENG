CREATE TABLE [Genesys_dbo].[IVRHistory] (
    [cEventData1]    NVARCHAR (50) NULL,
    [cEventData2]    NVARCHAR (50) NULL,
    [cEventData3]    NVARCHAR (50) NULL,
    [cEventType]     VARCHAR (10)  NULL,
    [dEventTime]     DATETIME      NOT NULL,
    [I3TimeStampGMT] DATETIME      NOT NULL,
    [InteractionKey] CHAR (18)     NOT NULL,
    [SeqNo]          SMALLINT      NOT NULL,
    [SiteId]         SMALLINT      NOT NULL,
    [SubSiteId]      SMALLINT      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IVRHistory] PRIMARY KEY CLUSTERED ([dEventTime] ASC, [InteractionKey] ASC, [SeqNo] ASC, [SiteId] ASC)
);

