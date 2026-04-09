CREATE TABLE [Django].[location_cities] (
    [id]                           NVARCHAR (36)   NOT NULL,
    [name]                         NVARCHAR (4000) NULL,
    [geoname_id]                   NVARCHAR (MAX)  NULL,
    [ivector_connect_geo_level_id] INT             NULL,
    [ivector_connect_id]           INT             NULL,
    [ivector_connect_unique_code]  NVARCHAR (4000) NULL,
    [administrative_subdivision]   NVARCHAR (4000) NULL,
    [country]                      NVARCHAR (4000) NULL,
    [inserted_on]                  DATETIME        NOT NULL,
    [processid]                    VARCHAR (255)   NULL
);

