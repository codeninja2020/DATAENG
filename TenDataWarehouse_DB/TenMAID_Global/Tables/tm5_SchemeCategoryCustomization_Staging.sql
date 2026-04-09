CREATE TABLE [TenMAID_Global].[tm5_SchemeCategoryCustomization_Staging] (
    [ContactMailTempID]     INT           NULL,
    [FieldLength]           INT           NULL,
    [FieldName]             NVARCHAR (30) NULL,
    [FieldPosition]         INT           NULL,
    [FieldValidationTypeID] INT           NULL,
    [IsAcknowledgement]     BIT           NULL,
    [IsJobFlow]             BIT           NULL,
    [IsSMS]                 BIT           NULL,
    [IsTitleModification]   BIT           NULL,
    [JobRequestTypeId]      INT           NULL,
    [SchemeCategoryCustID]  INT           NOT NULL,
    [SYS_CHANGE_OPERATION]  NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]    BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_SchemeCategoryCustomization_Staging] PRIMARY KEY CLUSTERED ([SchemeCategoryCustID] ASC)
);

