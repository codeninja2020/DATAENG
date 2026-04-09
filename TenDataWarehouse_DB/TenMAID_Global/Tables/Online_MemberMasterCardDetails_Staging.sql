CREATE TABLE [TenMAID_Global].[Online_MemberMasterCardDetails_Staging] (
    [BenefitCode]          VARCHAR (10)  NULL,
    [BenefitName]          VARCHAR (750) NULL,
    [BIN]                  CHAR (12)     NULL,
    [DateCreated]          DATETIME      NULL,
    [ICABusinessName]      VARCHAR (50)  NULL,
    [ICACode]              VARCHAR (10)  NULL,
    [ICACountryCode]       CHAR (3)      NULL,
    [ICACountryName]       VARCHAR (50)  NULL,
    [ICALegalName]         VARCHAR (75)  NULL,
    [ICARegion]            CHAR (3)      NULL,
    [ICAState]             VARCHAR (20)  NULL,
    [MasterCardID]         INT           NOT NULL,
    [MemberID]             INT           NULL,
    [ParentICACode]        VARCHAR (10)  NULL,
    [ProductCode]          CHAR (3)      NULL,
    [ProductName]          VARCHAR (50)  NULL,
    [TENProduct]           CHAR (6)      NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_MemberMasterCardDetails_Staging] PRIMARY KEY CLUSTERED ([MasterCardID] ASC)
);

