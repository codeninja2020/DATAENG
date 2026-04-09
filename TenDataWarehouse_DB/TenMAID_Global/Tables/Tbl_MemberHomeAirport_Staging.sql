CREATE TABLE [TenMAID_Global].[Tbl_MemberHomeAirport_Staging] (
    [HomeAirportId]        INT            NOT NULL,
    [HomeAirportName]      NVARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_Tbl_MemberHomeAirport_Staging] PRIMARY KEY CLUSTERED ([HomeAirportId] ASC)
);

