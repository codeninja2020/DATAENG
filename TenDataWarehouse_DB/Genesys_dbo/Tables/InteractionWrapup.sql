CREATE TABLE [Genesys_dbo].[InteractionWrapup] (
    [InteractionIDKey]       CHAR (18)      NOT NULL,
    [nHold]                  INT            NULL,
    [nSupervisorRequest]     INT            NULL,
    [nSuspend]               INT            NULL,
    [SeqNo]                  TINYINT        NOT NULL,
    [SiteID]                 SMALLINT       NOT NULL,
    [SourceInteractionIDKey] CHAR (18)      NOT NULL,
    [tAcw]                   NUMERIC (18)   NULL,
    [tConnected]             NUMERIC (18)   NULL,
    [tHold]                  NUMERIC (18)   NULL,
    [tSuspend]               NUMERIC (18)   NULL,
    [UserID]                 NVARCHAR (50)  NULL,
    [WorkgroupID]            NVARCHAR (100) NULL,
    [WrapupCategory]         NVARCHAR (50)  NULL,
    [WrapupCode]             NVARCHAR (50)  NULL,
    [WrapupIncompleteReason] CHAR (1)       NULL,
    [WrapupRequired]         BIT            NULL,
    [WrapupSegmentID]        SMALLINT       NOT NULL,
    [WrapupStartDateTimeUTC] DATETIME2 (7)  NULL,
    [WrapupStartDTOffset]    INT            NULL,
    CONSTRAINT [PK_Genesys_dbo_InteractionWrapup] PRIMARY KEY CLUSTERED ([InteractionIDKey] ASC, [SeqNo] ASC, [SiteID] ASC, [SourceInteractionIDKey] ASC, [WrapupSegmentID] ASC)
);


GO
ALTER TABLE [Genesys_dbo].[InteractionWrapup] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);

