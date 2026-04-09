CREATE TABLE [Django].[entertainment_bookings] (
    [id]                 INT             NOT NULL,
    [member_id]          INT             NULL,
    [author_id]          INT             NULL,
    [name]               NVARCHAR (4000) NULL,
    [status]             NVARCHAR (4000) NULL,
    [delivery_method_id] INT             NULL,
    [performance_id]     INT             NULL,
    [payment_status]     NVARCHAR (4000) NULL,
    [external_id]        INT             NULL,
    [provider]           NVARCHAR (4000) NULL,
    [created]            DATETIME2 (0)   NULL,
    [inserted_on]        DATETIME        NOT NULL,
    [processid]          VARCHAR (255)   NULL
);

