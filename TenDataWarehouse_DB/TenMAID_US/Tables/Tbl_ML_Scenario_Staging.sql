CREATE TABLE [TenMAID_US].[Tbl_ML_Scenario_Staging] (
    [Definition]           NVARCHAR (200) NULL,
    [ID]                   INT            NOT NULL,
    [PointCashValue]       FLOAT (53)     NULL,
    [Scenarios]            NVARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_ML_Scenario_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

