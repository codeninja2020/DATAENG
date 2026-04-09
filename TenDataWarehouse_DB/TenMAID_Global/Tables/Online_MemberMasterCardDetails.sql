CREATE TABLE [TenMAID_Global].[Online_MemberMasterCardDetails] (
    [BenefitCode]     VARCHAR (25)   NULL,
    [BenefitName]     VARCHAR (750)  NULL,
    [BIN]             CHAR (12)      NULL,
    [DateCreated]     DATETIME       NULL,
    [ICABusinessName] VARCHAR (50)   NULL,
    [ICACode]         VARCHAR (10)   NULL,
    [ICACountryCode]  CHAR (3)       NULL,
    [ICACountryName]  VARCHAR (50)   NULL,
    [ICALegalName]    VARCHAR (75)   NULL,
    [ICARegion]       CHAR (3)       NULL,
    [ICAState]        VARCHAR (20)   NULL,
    [MasterCardID]    INT            NOT NULL,
    [MemberID]        INT            NOT NULL,
    [ParentICACode]   VARCHAR (10)   NULL,
    [ProductCode]     CHAR (3)       NULL,
    [ProductName]     NVARCHAR (100) NULL,
    [TENProduct]      CHAR (6)       NULL,
    CONSTRAINT [PK_TenMAID_Global_Online_MemberMasterCardDetails] PRIMARY KEY CLUSTERED ([MasterCardID] ASC)
);

