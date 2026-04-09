CREATE TABLE [Django].[partners] (
    [id]          INT             NOT NULL,
    [name]        NVARCHAR (4000) NULL,
    [link]        NVARCHAR (4000) NULL,
    [chosen_tags] NVARCHAR (4000) NULL,
    [sites]       NVARCHAR (4000) NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_partners_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

