CREATE TABLE [TenMAID_US].[EmployeeGroupRestrictionByScheme_Staging] (
    [GroupID]              INT          NULL,
    [GroupRestrictionID]   INT          NOT NULL,
    [SchemeID]             INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeGroupRestrictionByScheme_Staging] PRIMARY KEY CLUSTERED ([GroupRestrictionID] ASC)
);

