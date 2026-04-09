CREATE TABLE [Django].[location_locationtags] (
    [id]                           NVARCHAR (50)   NOT NULL,
    [name]                         NVARCHAR (4000) NULL,
    [geoname_id]                   INT             NULL,
    [ivector_connect_geo_level_id] INT             NULL,
    [ivector_connect_id]           INT             NULL,
    [ivector_connect_unique_code]  NVARCHAR (4000) NULL,
    [inserted_on]                  DATETIME        NOT NULL,
    [processid]                    VARCHAR (255)   NULL
);

