CREATE TABLE [Django].[articles] (
    [id]          INT             NOT NULL,
    [title]       NVARCHAR (4000) NULL,
    [slug]        NVARCHAR (4000) NULL,
    [tags]        NVARCHAR (4000) NULL,
    [created]     DATETIME2 (0)   NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);

