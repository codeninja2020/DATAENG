CREATE TABLE [TenMAID_Global].[Tbl_PvtIngenicoSchemeMaintenance_Staging] (
    [CardTypeID]           INT            NULL,
    [CreatedBy]            INT            NULL,
    [Currencies]           NVARCHAR (500) NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [MaintenanceID]        INT            NOT NULL,
    [Notes]                NVARCHAR (500) NULL,
    [ProfileID]            INT            NULL,
    [PSPID]                INT            NULL,
    [SchemeID]             INT            NULL,
    [UpdatedBy]            INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_PvtIngenicoSchemeMaintenance_Staging] PRIMARY KEY CLUSTERED ([MaintenanceID] ASC)
);

