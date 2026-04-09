CREATE TABLE [TenMAID_Global].[MembershipLength_Staging] (
    [LengthDuration]       INT           NULL,
    [LengthName]           NVARCHAR (50) NULL,
    [MembershipLengthID]   INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_MembershipLength_Staging] PRIMARY KEY CLUSTERED ([MembershipLengthID] ASC)
);

