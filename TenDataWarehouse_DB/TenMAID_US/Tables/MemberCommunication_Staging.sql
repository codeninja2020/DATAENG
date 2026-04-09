CREATE TABLE [TenMAID_US].[MemberCommunication_Staging] (
    [Biography]            VARCHAR (512) NULL,
    [CallingInstrutions]   VARCHAR (50)  NULL,
    [CommunicationID]      INT           NOT NULL,
    [DateOfBirth]          DATETIME      NULL,
    [EMail]                BIT           NULL,
    [Fax]                  BIT           NULL,
    [HomePhone]            BIT           NULL,
    [MemberID]             INT           NULL,
    [Mobile]               BIT           NULL,
    [Nationality]          VARCHAR (30)  NULL,
    [Other]                BIT           NULL,
    [OtherDetails]         VARCHAR (30)  NULL,
    [PA]                   BIT           NULL,
    [PassportName]         VARCHAR (30)  NULL,
    [PassportNo]           VARCHAR (30)  NULL,
    [WorkPhone]            BIT           NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_MemberCommunication_Staging] PRIMARY KEY CLUSTERED ([CommunicationID] ASC)
);

