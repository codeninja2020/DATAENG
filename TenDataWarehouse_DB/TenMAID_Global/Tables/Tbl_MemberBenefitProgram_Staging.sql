CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitProgram_Staging] (
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [ProgramID]            INT            NOT NULL,
    [ProgramName]          NVARCHAR (500) NULL,
    [UpdatedBy]            INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitProgram_Staging] PRIMARY KEY CLUSTERED ([ProgramID] ASC)
);

