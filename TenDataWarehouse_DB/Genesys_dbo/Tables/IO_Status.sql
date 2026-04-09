CREATE TABLE [Genesys_dbo].[IO_Status] (
    [ActivityTypeID]    CHAR (22)      NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [SiteID]            INT            NULL,
    [StatusID]          CHAR (22)      NOT NULL,
    [StatusKey]         NVARCHAR (100) NOT NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Status] PRIMARY KEY CLUSTERED ([StatusID] ASC)
);

