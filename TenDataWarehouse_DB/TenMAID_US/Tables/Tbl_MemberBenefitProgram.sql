CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitProgram] (
    [CreatedBy]   INT            NULL,
    [DateCreated] DATETIME       NULL,
    [DateUpdated] DATETIME       NULL,
    [ProgramID]   INT            NOT NULL,
    [ProgramName] NVARCHAR (500) NOT NULL,
    [UpdatedBy]   INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitProgram] PRIMARY KEY CLUSTERED ([ProgramID] ASC)
);

