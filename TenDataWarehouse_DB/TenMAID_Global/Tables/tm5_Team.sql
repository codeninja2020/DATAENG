CREATE TABLE [TenMAID_Global].[tm5_Team] (
    [CreatedBy]   INT            NULL,
    [CreatedDate] DATETIME       NULL,
    [SubRegionId] INT            NULL,
    [TeamId]      INT            NOT NULL,
    [TeamName]    NVARCHAR (100) NULL,
    [UpdatedBy]   INT            NULL,
    [UpdatedDate] DATETIME       NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_Team] PRIMARY KEY CLUSTERED ([TeamId] ASC)
);

