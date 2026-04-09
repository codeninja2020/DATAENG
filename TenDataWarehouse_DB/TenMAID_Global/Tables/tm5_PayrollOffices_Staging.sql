CREATE TABLE [TenMAID_Global].[tm5_PayrollOffices_Staging] (
    [FTEHours]             FLOAT (53)    NULL,
    [ISO_CountryID]        NVARCHAR (40) NULL,
    [PayrollOfficeID]      INT           NOT NULL,
    [PayrollOfficeName]    NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_PayrollOffices_Staging] PRIMARY KEY CLUSTERED ([PayrollOfficeID] ASC)
);

