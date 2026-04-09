CREATE TABLE [Genesys_dbo].[IO_LTFModification] (
    [Description]             NVARCHAR (2000) NULL,
    [EndDateSUT]              DATETIME        NULL,
    [FilterSet]               NVARCHAR (MAX)  NULL,
    [GridModificationDataSet] NVARCHAR (MAX)  NULL,
    [IsSelected]              TINYINT         NOT NULL,
    [LongTermForecastID]      CHAR (22)       NOT NULL,
    [LTFModificationID]       CHAR (22)       NOT NULL,
    [Metric]                  NVARCHAR (255)  NULL,
    [ModificationOrder]       INT             NOT NULL,
    [ModificationValue]       NUMERIC (18)    NULL,
    [ModifierUserID]          NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]       DATETIME        NULL,
    [StartDateSUT]            DATETIME        NULL,
    [Type]                    INT             NOT NULL,
    [Version]                 INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_LTFModification] PRIMARY KEY CLUSTERED ([LTFModificationID] ASC)
);

