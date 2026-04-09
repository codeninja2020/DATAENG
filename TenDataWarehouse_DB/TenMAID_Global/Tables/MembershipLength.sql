CREATE TABLE [TenMAID_Global].[MembershipLength] (
    [LengthDuration]     INT           NULL,
    [LengthName]         NVARCHAR (50) NULL,
    [MembershipLengthID] INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_MembershipLength] PRIMARY KEY CLUSTERED ([MembershipLengthID] ASC)
);

