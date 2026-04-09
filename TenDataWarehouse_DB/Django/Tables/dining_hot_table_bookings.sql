CREATE TABLE [Django].[dining_hot_table_bookings] (
    [id]           INT             NOT NULL,
    [member_id]    INT             NULL,
    [author_id]    INT             NULL,
    [hot_table_id] INT             NULL,
    [status]       NVARCHAR (4000) NULL,
    [created]      DATETIME2 (0)   NULL,
    [inserted_on]  DATETIME        NOT NULL,
    [processid]    VARCHAR (255)   NULL
);

