CREATE TABLE [cms].[Dining] (
    [dining_id]          INT            NOT NULL,
    [ivector_id]         INT            NULL,
    [ten_maid_vendor_id] INT            NULL,
    [dining_name]        NVARCHAR (255) NULL,
    [location_id]        INT            NULL,
    [latitude]           FLOAT (53)     NULL,
    [longitude]          FLOAT (53)     NULL,
    [held_table]         BIT            NULL,
    [Inserted_On]        DATETIME       NULL,
    [ProcessId]          VARCHAR (36)   NULL,
    [FileName]           VARCHAR (255)  NULL
);

