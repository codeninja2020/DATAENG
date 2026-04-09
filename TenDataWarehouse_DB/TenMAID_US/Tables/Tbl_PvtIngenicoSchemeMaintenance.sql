CREATE TABLE [TenMAID_US].[Tbl_PvtIngenicoSchemeMaintenance] (
    [CardTypeID]    INT            NULL,
    [CreatedBy]     INT            NULL,
    [Currencies]    NVARCHAR (500) NULL,
    [DateCreated]   DATETIME       NULL,
    [DateUpdated]   DATETIME       NULL,
    [MaintenanceID] INT            NOT NULL,
    [Notes]         NVARCHAR (500) NULL,
    [ProfileID]     INT            NULL,
    [PSPID]         INT            NULL,
    [SchemeID]      INT            NULL,
    [UpdatedBy]     INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PvtIngenicoSchemeMaintenance] PRIMARY KEY CLUSTERED ([MaintenanceID] ASC)
);

