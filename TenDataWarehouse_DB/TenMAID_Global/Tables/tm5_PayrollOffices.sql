CREATE TABLE [TenMAID_Global].[tm5_PayrollOffices] (
    [FTEHours]          FLOAT (53)    NULL,
    [ISO_CountryID]     NVARCHAR (40) NULL,
    [PayrollOfficeID]   INT           NOT NULL,
    [PayrollOfficeName] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_PayrollOffices] PRIMARY KEY CLUSTERED ([PayrollOfficeID] ASC)
);

