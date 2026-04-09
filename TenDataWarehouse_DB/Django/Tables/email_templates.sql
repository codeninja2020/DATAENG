CREATE TABLE [Django].[email_templates] (
    [name]        NVARCHAR (4000) NOT NULL,
    [campaign_id] INT             NOT NULL,
    [name1]       NVARCHAR (4000) NOT NULL,
    [sites]       NVARCHAR (4000) NULL,
    [subject]     NVARCHAR (4000) NOT NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);

