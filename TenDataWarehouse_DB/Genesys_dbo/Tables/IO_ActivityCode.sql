CREATE TABLE [Genesys_dbo].[IO_ActivityCode] (
    [ActivityCodeID]     CHAR (22)      NOT NULL,
    [ActivityCodeName]   NVARCHAR (100) NOT NULL,
    [ActivityTypeID]     CHAR (22)      NOT NULL,
    [IgnoreForAdherence] TINYINT        NOT NULL,
    [IsActive]           TINYINT        NOT NULL,
    [IsContiguous]       TINYINT        NOT NULL,
    [IsPaid]             TINYINT        NOT NULL,
    [IsPlanned]          TINYINT        NOT NULL,
    [LengthInMinutes]    INT            NOT NULL,
    [ModifierUserID]     NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]  DATETIME       NULL,
    [ShortName]          NVARCHAR (25)  NULL,
    [Version]            INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ActivityCode] PRIMARY KEY CLUSTERED ([ActivityCodeID] ASC)
);

