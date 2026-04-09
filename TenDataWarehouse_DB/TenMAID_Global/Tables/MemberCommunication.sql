CREATE TABLE [TenMAID_Global].[MemberCommunication] (
    [Biography]          VARCHAR (512) NULL,
    [CallingInstrutions] VARCHAR (50)  NULL,
    [CommunicationID]    INT           NOT NULL,
    [DateOfBirth]        DATETIME      NULL,
    [EMail]              BIT           NULL,
    [Fax]                BIT           NULL,
    [HomePhone]          BIT           NULL,
    [MemberID]           INT           NULL,
    [Mobile]             BIT           NULL,
    [Nationality]        VARCHAR (30)  NULL,
    [Other]              BIT           NULL,
    [OtherDetails]       VARCHAR (30)  NULL,
    [PA]                 BIT           NULL,
    [PassportName]       VARCHAR (30)  NULL,
    [PassportNo]         VARCHAR (30)  NULL,
    [WorkPhone]          BIT           NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberCommunication] PRIMARY KEY CLUSTERED ([CommunicationID] ASC)
);

