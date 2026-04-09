CREATE TABLE [Django].[member_details] (
    [id]                INT             NOT NULL,
    [member_profile_id] INT             NULL,
    [tag]               NVARCHAR (4000) NULL,
    [tag_id]            INT             NULL,
    [inserted_on]       DATETIME        NOT NULL,
    [processid]         VARCHAR (255)   NULL
);

