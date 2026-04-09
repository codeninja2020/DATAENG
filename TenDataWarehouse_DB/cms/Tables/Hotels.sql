CREATE TABLE [cms].[Hotels] (
    [accommodation_id]   INT            NOT NULL,
    [ivector_id]         INT            NULL,
    [accommodation_name] NVARCHAR (255) NULL,
    [rating]             DECIMAL (3, 1) NULL,
    [latitude]           FLOAT (53)     NULL,
    [longitude]          FLOAT (53)     NULL,
    [location_id]        INT            NULL,
    [is_benefits_hotel]  BIT            NULL,
    [Inserted_On]        DATETIME       NULL,
    [ProcessId]          VARCHAR (36)   NULL,
    [FileName]           VARCHAR (255)  NULL
);

