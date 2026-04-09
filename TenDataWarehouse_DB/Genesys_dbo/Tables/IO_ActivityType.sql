CREATE TABLE [Genesys_dbo].[IO_ActivityType] (
    [ActivityTypeID]     CHAR (22)      NOT NULL,
    [ActivityTypeName]   NVARCHAR (100) NOT NULL,
    [IgnoreForAdherence] TINYINT        NOT NULL,
    [IsContiguous]       TINYINT        NULL,
    [IsPaid]             TINYINT        NULL,
    [IsPlanned]          TINYINT        NULL,
    [LengthInMinutes]    INT            NULL,
    [ModifierUserID]     NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]  DATETIME       NULL,
    [ShortName]          NVARCHAR (25)  NULL,
    [Version]            INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ActivityType] PRIMARY KEY CLUSTERED ([ActivityTypeID] ASC)
);

