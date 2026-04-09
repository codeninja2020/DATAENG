CREATE TABLE [TenMAID_Global].[Tbl_AreaOfInterest_Staging] (
    [AreaDescription]      NVARCHAR (100) NULL,
    [AreaInterestID]       INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_AreaOfInterest_Staging] PRIMARY KEY CLUSTERED ([AreaInterestID] ASC)
);

