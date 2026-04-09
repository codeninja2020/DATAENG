CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitProgram] (
    [CreatedBy]   INT            NULL,
    [DateCreated] DATETIME       NULL,
    [DateUpdated] DATETIME       NULL,
    [ProgramID]   INT            NOT NULL,
    [ProgramName] NVARCHAR (500) NOT NULL,
    [UpdatedBy]   INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitProgram] PRIMARY KEY CLUSTERED ([ProgramID] ASC)
);

