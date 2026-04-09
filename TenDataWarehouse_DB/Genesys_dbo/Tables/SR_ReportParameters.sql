CREATE TABLE [Genesys_dbo].[SR_ReportParameters] (
    [AllowInput]         NVARCHAR (50)  NULL,
    [DefaultValue]       NVARCHAR (MAX) NULL,
    [Description]        NVARCHAR (MAX) NULL,
    [ParameterName]      NVARCHAR (50)  NULL,
    [ParameterValueType] NVARCHAR (50)  NULL,
    [ReportName]         NVARCHAR (100) NOT NULL,
    [SiteName]           NVARCHAR (25)  NOT NULL
);

