CREATE TABLE [TenMAID_US].[Tbl_PvtIngenicoPaymentProfile] (
    [CardTypeID]  INT            NULL,
    [CreatedBy]   INT            NULL,
    [Currencies]  NVARCHAR (500) NULL,
    [DateCreated] DATETIME       NULL,
    [DateUpdated] DATETIME       NULL,
    [ID]          INT            NOT NULL,
    [IsDefault]   BIT            NULL,
    [Notes]       NVARCHAR (500) NULL,
    [ProfileID]   INT            NULL,
    [PSPID]       INT            NULL,
    [UpdatedBy]   INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PvtIngenicoPaymentProfile] PRIMARY KEY CLUSTERED ([ID] ASC)
);

