CREATE TABLE [TenMAID_US].[tm5_SchemeCategoryCustomization] (
    [ContactMailTempID]     INT           NOT NULL,
    [FieldLength]           INT           NULL,
    [FieldName]             NVARCHAR (30) NULL,
    [FieldPosition]         INT           NULL,
    [FieldValidationTypeID] INT           NULL,
    [IsAcknowledgement]     BIT           NULL,
    [IsJobFlow]             BIT           NULL,
    [IsSMS]                 BIT           NULL,
    [IsTitleModification]   BIT           NULL,
    [JobRequestTypeId]      INT           NOT NULL,
    [SchemeCategoryCustID]  INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_SchemeCategoryCustomization] PRIMARY KEY CLUSTERED ([SchemeCategoryCustID] ASC)
);

