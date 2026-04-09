CREATE TABLE [Genesys_dbo].[IO_ForecastDataModification] (
    [DaysApplicable]             INT            NOT NULL,
    [DurationInMinutes]          INT            NOT NULL,
    [FilteredRouteGroups]        VARCHAR (MAX)  NOT NULL,
    [ForecastDataModificationID] CHAR (22)      NOT NULL,
    [Metric]                     INT            NOT NULL,
    [ModifierUserID]             NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]          DATETIME       NULL,
    [OperationEnabled]           TINYINT        NOT NULL,
    [OperationOrder]             INT            NOT NULL,
    [OperationType]              INT            NOT NULL,
    [StartOffsetInMinutes]       INT            NOT NULL,
    [Value]                      FLOAT (53)     NOT NULL,
    [Version]                    INT            NOT NULL,
    [VolumeForecastID]           CHAR (22)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ForecastDataModification] PRIMARY KEY CLUSTERED ([ForecastDataModificationID] ASC)
);

