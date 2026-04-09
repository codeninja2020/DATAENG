CREATE TABLE [TenMAID_US].[Tbl_ML_Scenario] (
    [Definition]     NVARCHAR (200) NULL,
    [ID]             INT            NOT NULL,
    [PointCashValue] FLOAT (53)     NULL,
    [Scenarios]      NVARCHAR (100) NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_ML_Scenario] PRIMARY KEY CLUSTERED ([ID] ASC)
);

