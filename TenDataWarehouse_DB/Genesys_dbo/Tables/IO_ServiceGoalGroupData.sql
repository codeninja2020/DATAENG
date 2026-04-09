CREATE TABLE [Genesys_dbo].[IO_ServiceGoalGroupData] (
    [InteractionType]        INT            NOT NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NOT NULL,
    [ServiceGoalGroupDataID] CHAR (22)      NOT NULL,
    [ServiceGoalGroupID]     CHAR (22)      NOT NULL,
    [Version]                INT            NOT NULL,
    [WorkgroupID]            CHAR (22)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ServiceGoalGroupData] PRIMARY KEY CLUSTERED ([ServiceGoalGroupDataID] ASC)
);

