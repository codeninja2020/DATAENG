CREATE TABLE [TenMAID_Global].[Tbl_MemberSportsPreferenceType] (
    [SportsPreferenceTypeID] INT            NOT NULL,
    [SportsPreferenceType]   NVARCHAR (100) NULL,
    [IsActive]               BIT            NULL,
    CONSTRAINT [PK_Tbl_MemberSportsPreferenceType] PRIMARY KEY CLUSTERED ([SportsPreferenceTypeID] ASC)
);

