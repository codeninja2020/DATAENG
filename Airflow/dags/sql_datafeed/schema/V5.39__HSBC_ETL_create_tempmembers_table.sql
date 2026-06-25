/* ============================================================================
   Repeatable migration: R__HSBC_ETL_create_tempmembers_table.sql

   Purpose: Create HSBC_ETL.tempmembers as a copy of dbo.Members for HSBC ETL loads.

   Tables updated:
     - HSBC_ETL.tempmembers
============================================================================ */

USE TENMAID_UAT;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'HSBC_ETL.tempmembers', N'U') IS NULL
BEGIN
    CREATE TABLE [HSBC_ETL].[tempmembers] (
        [MemberID]                  INT             IDENTITY (1, 1) NOT NULL,
        [Name]                      NVARCHAR (255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [SchemeID]                  INT             NULL,
        [MemberGroupID]             INT             NULL,
        [DateOfExpiry]              DATETIME        NULL,
        [MembershipStatusID]        INT             NULL,
        [DateJoined]                DATETIME        NULL,
        [DateReceivedQuestionnaire] DATETIME        NULL,
        [SatisfactionID]            INT             NULL,
        [FirstName]                 NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [MiddleName]                NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [Surname]                   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [Sex]                       CHAR (1)        COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [JobTitle]                  NVARCHAR (100)  NULL,
        [CompanyName]               NVARCHAR (100)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [DateCreated]               DATETIME        CONSTRAINT [DF_tempmembers_DateCreated] DEFAULT (getdate()) NULL,
        [CreatedBy]                 INT             NULL,
        [DateUpdated]               DATETIME        CONSTRAINT [DF_tempmembers_DateUpdated] DEFAULT (getdate()) NULL,
        [UpdatedBy]                 INT             NULL,
        [PrimaryEmployeeID]         INT             NULL,
        [AccountingCode]            NVARCHAR (100)  NULL,
        [GoesBy]                    NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [_ReturnID]                 NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [Alert]                     NVARCHAR (1000) NULL,
        [MailName]                  NVARCHAR (50)   NULL,
        [IsNewsSend1]               BIT             CONSTRAINT [DF_tempmembers_IsNewsSend] DEFAULT ((1)) NULL,
        [PrimaryLMID]               INT             NULL,
        [IsInvestor]                BIT             NULL,
        [ClientRefNo]               NVARCHAR (50)   NULL,
        [LastDateMet]               DATETIME        NULL,
        [Reference1]                NVARCHAR (255)  NULL,
        [Reference2]                NVARCHAR (255)  NULL,
        [Reference3]                NVARCHAR (255)  NULL,
        [PrimaryID]                 INT             NULL,
        [RelationshipsToPM]         NVARCHAR (50)   NULL,
        [DOB]                       DATETIME        NULL,
        [AdditionalMemberID]        INT             NULL,
        [LocationID]                INT             NULL,
        [TitleID]                   INT             NULL,
        [ConsentID]                 INT             NULL,
        [CountryID]                 NCHAR (2)       COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [AlertGreen]                NVARCHAR (255)  NULL,
        [AlertBlue]                 NVARCHAR (255)  NULL,
        [IsWithWexas]               BIT             NULL,
        [IsNewsSend]                SMALLINT        NULL,
        [OtherLocation]             VARCHAR (50)    NULL,
        [AssignEmployeeID]          INT             NULL,
        [UsageAlert]                INT             NULL,
        [JobCount]                  INT             NULL,
        [VRegID]                    INT             NULL,
        [IsMain]                    BIT             NULL,
        [AttriumID]                 INT             NULL,
        [CitiUniqueID]              NVARCHAR (200)  NULL,
        [CitiCustomerID]            NVARCHAR (150)  NULL,
        [IsImportant]               BIT             NULL,
        [OldMemberID]               INT             NULL,
        [CitiCorporateID]           INT             NULL,
        [RBSAPrimaryID]             INT             NULL,
        [updatesusage]              DATETIME        NULL,
        [DolphinID]                 VARCHAR (50)    NULL,
        [knownas]                   NVARCHAR (50)   NULL,
        [brief]                     NVARCHAR (1000) NULL,
        [InternetPassword]          NVARCHAR (1000) NULL,
        [TeamLeader]                INT             NULL,
        [TempEmployeeID]            INT             NULL,
        [OnlineMemberID]            VARCHAR (50)    NULL,
        [MemberNotes]               NVARCHAR (2000) NULL,
        [PrimaryEmail]              NVARCHAR (255)  NULL,
        [PrimaryMobile]             NVARCHAR (200)  NULL,
        [salesForceID]              VARCHAR (60)    NULL,
        [LanguageID]                NVARCHAR (100)  NULL,
        [Warning]                   NVARCHAR (2000) NULL,
        [TimeZoneID]                INT             NULL,
        [DigitalId]                 INT             NULL,
        [AmadeusProfileID]          NVARCHAR (50)   NULL,
        [AmadeusInstance]           INT             NULL,
        [PreferredTravelLM]         INT             NULL,
        [PreferredLifestyleLM]      INT             NULL,
        [MemberSurveyID]            INT             NULL,
        [MemberSurveyDate]          DATETIME        NULL,
        [TTSCustomerID]             INT             NULL,
        [GeoCity]                   NVARCHAR (250)  NULL,
        [GeoPostcode]               NVARCHAR (250)  NULL,
        [ForeignMemberID]           INT             NULL,
        [FirstName_Computed]        AS              (case when [FirstName] like '%*%' then (1) else (0) end) PERSISTED NOT NULL,
        [Reference5]                NVARCHAR (255)  NULL,
        [Reference6]                NVARCHAR (3000) NULL,
        CONSTRAINT [PK_tempmembers] PRIMARY KEY NONCLUSTERED ([MemberID] ASC) WITH (FILLFACTOR = 90)
    );

    CREATE CLUSTERED INDEX [CIX_tempmembers_FirstName]
        ON [HSBC_ETL].[tempmembers]([FirstName] ASC);

    CREATE NONCLUSTERED INDEX [IX_tempmembers_SchemeID_MemberGroupID_Reference1]
        ON [HSBC_ETL].[tempmembers]([SchemeID] ASC, [MemberGroupID] ASC, [Reference1] ASC);

    CREATE NONCLUSTERED INDEX [IX_tempmembers_SchemeId_MembershipStatusID_MemberSearchByEmail]
        ON [HSBC_ETL].[tempmembers]([SchemeID] ASC, [MembershipStatusID] ASC)
        INCLUDE([MemberID], [Surname], [PrimaryEmail], [FirstName]);
END;
GO
