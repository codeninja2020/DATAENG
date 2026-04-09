CREATE TABLE [Django].[travel_car_hire_depots] (
    [id]                 INT                NOT NULL,
    [latitude]           DECIMAL (9, 6)     NULL,
    [longitude]          DECIMAL (9, 6)     NULL,
    [ivector_connect_id] NVARCHAR (4000)    NULL,
    [name]               NVARCHAR (4000)    NULL,
    [vendor_id]          INT                NULL,
    [location_id]        NVARCHAR (50)      NULL,
    [created]            DATETIMEOFFSET (7) NULL,
    [deleted]            DATETIMEOFFSET (7) NULL,
    [inserted_on]        DATETIME           NOT NULL,
    [processid]          VARCHAR (255)      NULL
);

