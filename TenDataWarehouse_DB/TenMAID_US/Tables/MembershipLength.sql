CREATE TABLE [TenMAID_US].[MembershipLength] (
    [LengthDuration]     INT           NULL,
    [LengthName]         NVARCHAR (50) NULL,
    [MembershipLengthID] INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_US_MembershipLength] PRIMARY KEY CLUSTERED ([MembershipLengthID] ASC)
);

