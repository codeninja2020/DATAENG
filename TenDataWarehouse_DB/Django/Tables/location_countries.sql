CREATE TABLE [Django].[location_countries] (
    [id]                           NVARCHAR (50)   NOT NULL,
    [name]                         NVARCHAR (4000) NULL,
    [geoname_id]                   NVARCHAR (4000) NULL,
    [ivector_connect_geo_level_id] NVARCHAR (4000) NULL,
    [ivector_connect_id]           NVARCHAR (4000) NULL,
    [ivector_connect_unique_code]  NVARCHAR (4000) NULL,
    [alpha3_code]                  NVARCHAR (4000) NULL,
    [iso_code]                     NVARCHAR (4000) NULL,
    [inserted_on]                  DATETIME        NOT NULL,
    [processid]                    VARCHAR (255)   NULL
);

