




create PROCEDURE [TDWI].[sp_ME_NPS_UPLOAD]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--Name  Transactional_NPS_SQL_query
	--Project    Transactional_NPS
	--Purpose    To generate the daily file to be sent to IBM   
	--Author     Ron Sibayan
	--Created    05/10/2018
	--LastEdited 25/03/2019 v6
	--
	-- v1 - confirm schemes ID's being filtered in ('109', '116', '224', '225', '253', '337', '362', '429', '514', '552', '619', '620', '621', '635', '636', '637', '638', '642', '643', '674', '782', '794', '589')
	--    - remove all blank emails
	--    - unique email addresses only
	--    - takes the first closed job of the day
	--    - hasn't provided any negative feedback in the last 90 days (91 including the reporting lag)
	--    - excludes if RBS or Natwest and postcode is blank
	--    - changed from select into to insert into
	--    - added Visa LAC and Amex China Scheme ID's
	-- v2 - changes to accomodate Swisscard 
	--      - added Gender Logic
	--      - adding Language Logic
	--      - Added Swisscard Exclusion filters
	--      - 20190124 - Added Marketing Consent filter for Visa LAC
	-- v3 - Massive refactoring excercise!  
	-- v4 - removed IsAdminJob = 1 from jobs
	--	  - removed jobs from Swisscard members that were closed by Non Swisscard LM's (Swiss_Close_Check)
	--	  - excluded jobs where MasterJobID is not null Globally
	--    - changed Swisscard Blacklist to look in Ref1 field (not memberID)
	--	  - changed Swisscard email field to bring in the real emails address (not test emails to Jose and Zabita)
	--    - added Scheme IDs for Amex LATAM (awaiting confirmation before turning on)
	-- v5 - removed filter to exclude Admin Jobs (because some of them will have comments that mean we need to remove the member entirely)
	--	  - extended global JOB level subject exclusions 
	--    - Logic to extend closed job date range on 1 day for LAC and Swiss launch
	-- v6 - Moved Admin Jobs logic to the end and 
	--    - Added Alphacard schemes

	-- v7 Added in SC scheme 1730 for dedicated centurion. Ammended SC job inclusion/exclusion policy
	-- v8 added in revolut
	-- v9 added in HSBC UAE
	-- V10 Added in an extra layer of email logic to check all emails
	-- V11 Added in Reference2 and Job billing type
	-- V12 ammended validation emails
	-- V13 HSBC UAE Moved to Live - hardcoded emails removed
	-- V14 Remove cancelled jobs
	-- V15 ADD REVOLUT AND REMOVE TERM 'BANKING'
	-- V16 remove all UNIONs for Validation Test Accounts
	-- v17 remove > from date range for extract


 ; OPEN SYMMETRIC KEY SQLSymmetricKey
   DECRYPTION BY CERTIFICATE SelfSignedCertificate ;

INSERT INTO [TenDataWarehouse_Internal].dbo.ME_NPS_UPLOAD

SELECT convert(datetime, GetDate()) AS DateAdded
	, Member_ID
	, Title
	, First_Name
	, Surname
	, Gender
	, DerivedLanguage
	, postcode
	, JobID
	, Subject
	, TenMAID_Dept
	, group1
	, scheme
	, Member_Group_Name
	, Closed_By
	, Closed_by_Team
	, Closed_by_Sub_Team
	, Scheme_ID
	, Scheme_ID01
	, case 

		   when scheme_id = '1611'  then 'kirstymiller2003@yahoo.co.uk'					  --Vodafone Black
		   else Email end as Email
	, LM_ID
	, Office
	, STATUS
	, ClosedDate
	, complaint_count
	, MarketingConsent
	, Job_OSS_OLR
	, Reference2_Encrypted

-- Use this to create the table
--into [TenDataWarehouse_Internal].dbo.ME_NPS_UPLOAD
FROM (



	SELECT distinct a.MemberID AS Member_ID

		, a.Reference2_Encrypted
		, A.Job_Billing_OSS_OLR as [Job_OSS_OLR]

		, a.Title
		, a.FirstName_Encrypted AS First_Name
		, a.Surname_Encrypted AS Surname
		, CASE WHEN schemeid in ('864', '865', '866', '867', '869', '870', '871', '872', '873', '874', '875', '876', '877', '878', '879', '880', '902', '903', '932', '933', '934', '965', '966','1730') and a.Gender NOT IN ('M', 'F') THEN 'Check' ELSE Gender END AS Gender
		, right(upper(PostCode_Unencrypted), 3) AS postcode
		, a.JobID
		, Subject
		, TenMAID_Dept
		, group1
		, corporateScheme1 AS scheme
		, MemberGroup AS Member_Group_Name
		, Closed_by_Team
		, Closed_by_Sub_Team
		, SchemeID AS Scheme_ID
		, SchemeID AS Scheme_ID01
		, Email
		, LM_ID
		, Office
		, Member_Active AS STATUS
		, a.ClosedDate
		, a.LanguageID


		-- Changing ClosedBy to include Swisscard specific closedBy definitions
		, Case 
			when SchemeID = '902' and Closed_by in ('Luana Machi', 'Marcello Martucci', 'Korine Weideli', 'Angelina Brunner') then 'Luana Machi'
			when SchemeID = '903' and Closed_by in ('Luana Machi', 'Marcello Martucci', 'Korine Weideli', 'Angelina Brunner') then 'Korine Weideli'
			when lower(Closed_By) = 'admin platform' then 'System Admin'
			else Closed_By
		end as Closed_By

		-- check for language against scheme ID here (includes second layer of Swisscard language derivation!!)
		, CASE 
			WHEN DerivedLanguage = 'Check' AND schemeID IN ('864', '867', '866', '865') THEN 'English' 
			WHEN DerivedLanguage = 'Check' AND schemeID IN ('873', '876', '875', '874') THEN 'French' 
			WHEN DerivedLanguage = 'Check' AND schemeID IN ('869', '872', '871', '870', '933') THEN 'German' 
			WHEN DerivedLanguage = 'Check' AND schemeID IN ('877', '880', '879', '878') THEN 'Italian' 
			WHEN DerivedLanguage = 'Check' AND schemeID IN ('903', '902', '966', '965', '932', '934','1730') THEN DerivedLanguage 
			WHEN schemeID NOT IN ('864', '867', '866', '865', '873', '876', '875', '874', '869', '872', '871', '870', '933', '877', '880', '879', '878', '903', '902', '966', '965', '932', '934','1730') THEN '' 
			ELSE DerivedLanguage 
		  END AS DerivedLanguage
		
	-- EXCLUSIONS

		-- Check if member has consented for Marketing Comms (filtered to Visa LAC)
		, CASE WHEN mc.memberid IS NULL AND a.schemeid IN ('1174', '1175', '1176', '1177', '1178', '1179', '1180', '1181', '1182', '1183', '1184', '1185', '1186', '1187', '1188', '1189', '1190', '1191', '1192', '1193', '1194', '1198', '1199', '1200', '1201', '1202', '1203', '1204', '1205', '1206', '1207', '1208', '1209', '1210') THEN 0 ELSE 1 END AS MarketingConsent
		
		-- Check when the scheme name contains RBS or Natwest and the postcode is blank
		, CASE WHEN (lower(corporateScheme1) LIKE '%rbs%' AND PostCode_Unencrypted= '') OR (lower(corporateScheme1) LIKE '%natwest%' AND PostCode_Unencrypted = '') THEN 1 ELSE 0 END AS remove_these  
		, isnull(Feedback_Count, 0) AS feedback_count
		, isnull(complaint_count, 0) AS complaint_count		
		
		-- SWISSCARD EXCLUSIONS

		-- check if Swisscard job was closed by Swiss LM (if a swiss job and closed by non swiss LM then 1.  Exclude the 1's)
		, case when swisscard_flag = 1 and isnull(NewSubRegionID, 999) != 12 then 1 else 0 end as swiss_close_check 	
			
		-- check if the job had a swisscard specific subject exclusion (brochure etc)
		--, ISNULL(swiss_feedback_count, 0) as Swiss_Feedback_Count 															

	-- BACKBONE!!

	FROM (


		SELECT a.MemberID
			, m.Reference1_Encrypted
			, m.Reference2_Encrypted
			, OSSOLR.Job_Billing_OSS_OLR
			, title.TitleName AS Title
			, m.FirstName_Encrypted
			, m.Surname_Encrypted
			, m.Sex AS Gender
			, a.JobID
			, a.MasterJobID
			, a.Subject
			, e3.Description AS TenMAID_Dept
			, e2.Description AS group1
			, cs.Name AS corporateScheme1
			, mg.Description AS MemberGroup
			, emp2.Firstname + ' ' + emp2.Surname AS Closed_By
			
			, t2.TeamName AS Closed_by_Team
			, st2.SubTeamName AS Closed_by_Sub_Team
			, m.SchemeID
			, case when schemeid in ('864', '867', '866', '865', '873', '876', '875', '874', '869', '872', '871', '870', '933', '877', '880', '879', '878', '903', '902', '966', '965', '932', '934','1730') then 1 else 0 end as Swisscard_Flag
			, case when CONVERT(nvarchar(max), DecryptByKey(m.PrimaryEmail_Encrypted)) is null then email.value
				  when CONVERT(nvarchar(max), DecryptByKey(m.PrimaryEmail_Encrypted))='' then email.Value
				  else m.PrimaryEmail_Encrypted end as Email
			, CASE WHEN a.closedfor = 168 THEN a.closedby WHEN a.closedFor IS NULL THEN a.ClosedBy ELSE a.ClosedFor END as LM_ID
			, o.Name AS Office
			, ms.Name AS Member_Active
			, a.ClosedDate
			, rank() OVER (
				PARTITION BY m.PrimaryEmail_Encrypted, email.value ORDER BY a.ClosedDate ASC
				) AS email_rank -- unique email addresses only
			-- implement DerivedLanguage based on LanguageID here
			, LanguageID

			, CASE 
				WHEN m.schemeid IN ('864', '865', '866', '867', '869', '870', '871', '872', '873', '874', '875', '876', '877', '878', '879', '880', '902', '903', '932', '933', '934', '965', '966','1730') AND LanguageID IN ('de', 'de,') THEN 'German' 
				WHEN m.schemeid IN ('864', '865', '866', '867', '869', '870', '871', '872', '873', '874', '875', '876', '877', '878', '879', '880', '902', '903', '932', '933', '934', '965', '966','1730') AND LanguageID IN ('en', 'en,') THEN 'English' 
				WHEN m.schemeid IN ('864', '865', '866', '867', '869', '870', '871', '872', '873', '874', '875', '876', '877', '878', '879', '880', '902', '903', '932', '933', '934', '965', '966','1730') AND LanguageID IN ('fr', 'fr,') THEN 'French' 
				WHEN m.schemeid IN ('864', '865', '866', '867', '869', '870', '871', '872', '873', '874', '875', '876', '877', '878', '879', '880', '902', '903', '932', '933', '934', '965', '966','1730') AND LanguageID IN ('it', 'it,') THEN 'Italian'
				WHEN m.schemeid IN ('864', '865', '866', '867', '869', '870', '871', '872', '873', '874', '875', '876', '877', '878', '879', '880', '902', '903', '932', '933', '934', '965', '966','1730') AND LanguageID NOT IN ('de', 'de,','en', 'en,','fr', 'fr,','it', 'it,') THEN 'Check'
				ELSE '' 
			  END AS DerivedLanguage

		FROM [TenDataWarehouse].[TenMAID_Global].[Jobs] a -- backbone
			-- getting category data
			LEFT JOIN (
				SELECT jobID
					, max(categoryID) AS CategoryID
				FROM [TenDataWarehouse].[TenMAID_Global].Tbl_JobCategories
				GROUP BY JobID
				) d ON a.JobID = d.JobID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].Tbl_Categories e				ON d.CategoryID = e.CategoryID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].Tbl_Categories e2				ON e.ParentID = e2.CategoryID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].Tbl_Categories e3				ON e2.ParentID = e3.CategoryID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].Members m						ON a.memberID = m.MemberID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].Titles title					ON m.TitleID = title.TitleID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].CorporateScheme cs				ON cast(m.SchemeID AS VARCHAR(10)) = cast(cs.CorporateSchemeID AS VARCHAR(10))
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].MemberGroup mg					ON m.MemberGroupID = mg.MemberGroupID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].[Employees] emp2				ON cast(CASE WHEN closedfor = 168 THEN closedby WHEN closedFor IS NULL THEN ClosedBy ELSE ClosedFor END AS NVARCHAR(25)) = cast(emp2.EmployeeID AS NVARCHAR(25)) -- this logic was taken from the LiveOps dashboard to avoid bulk close issues
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].[tm5_SpecialistTeams] AS s2	ON s2.SpecialistId = emp2.NewSpecialistTeamID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].[tm5_SubTeam] AS st2			ON st2.SubTeamId = emp2.NewSubTeamID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].[tm5_Team] AS t2				ON t2.TeamId = emp2.NewTeamID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].[Offices] o					ON emp2.OfficeID = o.OfficeID
			LEFT JOIN [TenDataWarehouse].[TenMAID_Global].[MembershipStatus] ms			ON m.MembershipStatusID = ms.MembershipStatusID
			--ADD ALL EMAILS
			LEFT JOIN [TenDataWarehouse_Internal].DBO.REF_TBL_member_unique_email_address as email on email.memberid = m.MemberID and email.ContactMethodID in (681,642,640,723,741,742,757)
			--ADD ONLINE REQUEST TYPE
			LEFT JOIN [TenDataWarehouse_Internal].DBO.REF_TBL_Job_OSS_OLR AS OSSOLR ON OSSOLR.jobid = A.JobID

		WHERE 

			convert(DATE, a.closedDate) = convert(DATE, getdate() - 1) -- Change the date range for your extract here, default is set to - 1 ie yesterday

		--JOB Level Exclusions

			-- exclude jobs closed more than 60 days after the brief date
			AND convert(DATE, a.briefdate) >= convert(DATE, a.closedDate - 60) 

			-- Exclude specific JOBS with the following in the subject field (later on, we'll remove MEMBERS with certain negative terms on any job in the past 90 days)
			AND UPPER(a.subject) NOT LIKE '%ONLINE RUMOUR%' 
			AND UPPER(a.subject) NOT LIKE '%WELCOME CALL%'
			AND UPPER(a.subject) NOT LIKE '%AUTHORISATION%'
			AND UPPER(a.subject) NOT LIKE '%AUTHORIZATION%'
			AND UPPER(a.subject) NOT LIKE '%ADMIN%'
			AND UPPER(a.subject) NOT LIKE '%WELCOME%'
			AND UPPER(a.subject) NOT LIKE '%EMPOWERMENT%'
			AND UPPER(a.subject) NOT LIKE '%RESEND%'
			AND UPPER(a.subject) NOT LIKE '%RESENT%'
			AND UPPER(a.subject) NOT LIKE '%SCHEDULE%'
			AND UPPER(a.subject) NOT LIKE '%SKEDCHG%'
			AND UPPER(a.subject) NOT LIKE '%ELITE TIER%'
			AND UPPER(a.subject) NOT LIKE '%CALL BACK%'
			AND UPPER(a.subject) NOT LIKE '%PCB%'
			AND UPPER(a.subject) NOT LIKE '%&CS%'
			AND UPPER(a.subject) NOT LIKE '%&C''S%'
			AND UPPER(a.subject) NOT LIKE '%TERMS%'
			AND UPPER(a.subject) NOT LIKE '%FUTURE%'
			AND UPPER(a.subject) NOT LIKE '%TRACK%'
			AND UPPER(A.Subject) NOT LIKE '%BROCHURE%' 
			AND UPPER(A.Subject) NOT LIKE '%BROSCHURE%' 
			AND UPPER(A.subject) NOT LIKE '%BROSHURE%' 
			AND UPPER(A.subject) NOT LIKE '%VOLLMACHT%' 
			AND UPPER(A.subject) NOT LIKE '%POWER OF ATTORNEY%' 
			AND UPPER(A.subject) NOT LIKE '%BANKING%' 

			-- Remove cancelled jobs
			AND JobStatusID!=100
		) a

	-- get complaint_count
	LEFT JOIN (
		SELECT 
			  b.memberID
			, sum(CASE WHEN feedbackType = 'Negative' THEN 1 ELSE 0 END) AS complaint_count
		FROM
			  [TenDataWarehouse].[TenMAID_Global].JobSatisfaction b
		LEFT JOIN 
			  [TenDataWarehouse].[TenMAID_Global].FeedbackType c ON b.FeedbackTypeID = c.FeedbackTypeID AND c.FeedbackType = 'Negative'
		WHERE 
			  convert(DATE, datefeedbackreceived) >= convert(DATE, getdate() - 91)
		GROUP BY b.MemberID
		) b ON a.memberID = b.memberID

	-- get postcode
	LEFT JOIN (
		SELECT 
			  memberID
			, CONVERT(nvarchar(max), DecryptByKey(PostCode_Encrypted)) as PostCode_Unencrypted
			, PostCode_Encrypted as PostCode
			, rank() OVER (
				PARTITION BY MemberID ORDER BY DateCreated DESC
				) AS ranky
		FROM 
			  [TenDataWarehouse].[TenMAID_Global].[MemberAddresses]
		WHERE 
			MemberAddressTypeID = 105
		) c ON a.MemberID = c.MemberID AND ranky = 1

	-- Find any MEMBER who has one of these words in the subject for any job they've raised (including Admin Jobs) in the past 90 days
	LEFT JOIN (
		SELECT memberID
			, convert(DATE, ClosedDate) AS ClosedDate
			, count(*) AS Feedback_Count
		FROM [TenDataWarehouse].[TenMAID_Global].jobs
		WHERE 
			UPPER(subject) LIKE '%FEEDBACK%' OR
			UPPER(subject) LIKE '%COMPLAINT%' OR
			UPPER(subject) LIKE '%UPSET%' OR
			UPPER(subject) LIKE '%MISSED JOB%' OR
			UPPER(subject) LIKE '%LOST JOB%' OR
			UPPER(subject) LIKE '%NEGATIVE%'
		group by memberID
			, convert(DATE, ClosedDate)
		) d ON a.MemberID = d.MemberID AND isnull(convert(DATE, d.ClosedDate), convert(DATE, '01/01/2099')) BETWEEN convert(DATE, getdate() - 90) AND convert(DATE, getdate())

		-- Excludes any SWISSCARD MEMBER who has one of these words in the subject for any job they've raised (including Admin Jobs) in the past 30 days based on the closed data of the job
	--LEFT JOIN (
	--	SELECT a.memberID
	--		, convert(DATE, ClosedDate) AS ClosedDate
	--		, count(*) AS Swiss_Feedback_Count
	--	FROM tenmaid_reports.dbo.jobs a
	--	inner join tenmaid_reports.dbo.members b on a.MemberID = b.MemberID 
	--	and b.SchemeID IN ('864', '867', '866', '865', '873', '876', '875', '874', '869', '872', '871', '870', '933', '877', '880', '879', '878', '903', '902', '966', '965', '932', '934','1730')
	--	WHERE 
	--		UPPER(subject) LIKE '%BROCHURE%' 
	--		OR UPPER(subject) LIKE '%BROSCHURE%' 
	--		OR UPPER(subject) LIKE '%BROSHURE%' 
	--		--OR UPPER(subject) LIKE '%TIME%'
	--	group by a.memberID
	--		, convert(DATE, ClosedDate)
	--	) d2 ON a.MemberID = d2.MemberID AND isnull(convert(DATE, d2.ClosedDate), convert(DATE, '01/01/2099')) BETWEEN convert(DATE, getdate() - 30) AND convert(DATE, getdate())
	
	-- check if members have consented to marketing communications
	LEFT JOIN (
		SELECT a.memberid, rank() over(partition by memberID order by updateDate desc) as ranky
		FROM [TenDataWarehouse].[TenMAID_Global].tm5_MemberConsent a
		WHERE a.IsAccepted = 1
		) mc ON a.MemberID = mc.MemberID
		and mc.ranky = 1


	-- Swisscard Blacklist Exclusions
	LEFT JOIN (
		SELECT [CISNumber]
		FROM [TenDataWarehouse_Internal].[dbo].[ME_REF_TBL_Swisscard_Blacklist] 
		) SCBL on CONVERT(nvarchar(max), DecryptByKey(a.Reference1_Encrypted)) = scbl.[CISNumber]

	-- Get the SubregionID for Swisscard 'closed outside Switzerland' Exclusions
	LEFT JOIN (
		SELECT employeeid, NewSubRegionID from [TenDataWarehouse].[TenMAID_Global].employees
		) OSSC  
		on a.LM_ID = ossc.EmployeeID

	INNER JOIN
		( select memberID , Jobid, rank() OVER (Partition by memberID, convert(date, closeddate) order by ClosedDate asc) as ranky 
			from [TenDataWarehouse].[TenMAID_Global].jobs 
			where isadminjob = 0
				
		) AS close_rank -- takes the first closed job
		ON a.memberID = close_rank.memberID
		and a.JobID = close_rank.JobID	


	WHERE 
	    -- take first closed job per member in the specified date range
		close_rank.ranky = 1 

		-- remove duplicate emails
		AND a.email_rank = 1

		-- hasn't provided any negative feedback in the last 90 days (91 including the reporting lag)
		AND isnull(complaint_count, 0) = 0 

		-- remove all blank emails
		--AND Email != '' 
		and CONVERT(nvarchar(max), DecryptByKey(Email)) !=''

		-- Member is Active 
		AND Member_Active = 'Active' 

		-- Exclude Swisscard Blacklist
		and scbl.CISNumber is null 

		
		--SCHEME ID INCLUSIONS LIST

		AND a.schemeid IN (
			  '716' -- Amex Alpha Card Gold (Flemish)
			, '715' -- Amex Alpha Card Gold (French)
			, '719' -- Amex Alpha Card Platinum (Flemish)
			, '718' -- Amex Alpha Card Platinum (French)
			, '991' -- New Amex Alpha Card Gold (Flemish)
			, '992' -- New Amex Alpha Card Gold (French)
			, '987' -- New Amex Alpha Card Platinum (Flemish)
			, '988' -- New Amex Alpha Card Platinum (French)
			, '224' -- Natwest International
			, '642' -- NatWest International
			--, '362' -- Lloyds Amex Private
			, '643' -- Isle Of Man Bank
			, '225' -- Wexas
			, '782' -- Ten Private Classic
			, '617' -- Barclays Concierge Temporary- Hope Pack within last..
			, '621' -- Barclays Home Pack Concierge
			, '964' -- Barclays Online Home Pack concierge
			, '253' -- Barclays Premier Infinite
			, '619' -- Barclays Premier Life- 25- inactive scheme
			, '620' -- Barclays Premier Life- inactive scheme
			, '337' -- Coutts Silk Concierge
			, '783' -- Coutts Silk Online Concierge
			, '1023' -- Coutts Silk temporary card
			, '116' -- Deutsche Bank

		, '1597' -- HSBC Jade Canada Cantonese
		, '1595' -- HSBC Jade Canada English
		, '1596' -- HSBC Jade Canada French
		, '1598' -- HSBC Jade Canada Mandarin
		, '1590' -- HSBC Jade Channel Islands and Isle of Man
		, '1585' -- HSBC Jade China Cantonese
		, '1584' -- HSBC Jade China English
		, '1586' -- HSBC Jade China Mandarin
		, '1587' -- HSBC Jade UK
		, '1588' -- HSBC Jade France English
		, '1589' -- HSBC Jade France French
		, '1579' -- HSBC Jade Hong Kong English
		, '1580' -- HSBC Jade Hong Kong Cantonese
		, '1581' -- HSBC Jade Hong Kong Mandarin
		, '1582' -- HSBC Jade Singapore English
		, '1583' -- HSBC Jade Singapore Mandarin
		, '1592' -- HSBC Jade US Cantonese
		, '1591' -- HSBC Jade US English
		, '1593' -- HSBC Jade US Mandarin
		, '1594' -- HSBC Jade US Spanish
		, '1693' -- HSBC Jade UAE Arabic
		, '1681' -- HSBC Jade UAE English

			, '224' -- Lifestyle Benefits
			, '642' -- Lifestyle Benefits- RBSI and Gold
			, '643' -- Lifestyle Benefits RBSI Isle of Man
			, '362' -- Lloyds Amex Private
			, '798' -- NatWest Account Temporary
			, '635' -- NatWest Black Account
			, '637' -- RBS Black Account
			, '514' -- Ten Lifestyle
			, '429' -- Tesco Finest Concierge
			, '1539' -- VISA CEMEA Russia Infinite RUS
			, '1540' -- VISA CEMEA Russia Signature RUS
			, '1541' -- VISA CEMEA Russia Infinite ENG
			, '1542' -- VISA CEMEA Russia Signature ENG
			, '1543' -- VISA CEMEA CISSEE Infinite RUS
			, '1544' -- VISA CEMEA CISSEE Signature RUS
			, '1545' -- VISA CEMEA CISSEE Infinite ENG
			, '1546' -- VISA CEMEA CISSEE Signature ENG
			, '1547' -- VISA CEMEA SSA South Africa Infinite ENG
			, '1548' -- VISA CEMEA SSA South Africa Signature ENG
			, '1549' -- VISA CEMEA SSA Kenya Infinite ENG
			, '1550' -- VISA CEMEA SSA Kenya Signature ENG
			, '1551' -- VISA CEMEA SSA Rest of Africa Infinite ENG
			, '1552' -- VISA CEMEA SSA Rest of Africa Signature ENG
			, '1553' -- VISA CEMEA SSA Rest of Africa Infinite FRE
			, '1554' -- VISA CEMEA SSA Rest of Africa Signature FRE
			, '1555' -- VISA CEMEA MENA Saudi Arabia ENG (Sharia)
			, '1556' -- VISA CEMEA MENA Saudi Arabia AR (Sharia)
			, '1557' -- VISA CEMEA MENA Saudi Arabia ENG (Conventional)
			, '1558' -- VISA CEMEA MENA Saudi Arabia AR(Conventional)
			, '1559' -- VISA CEMEA MENA UAE ENG
			, '1560' -- VISA CEMEA MENA UAE AR
			, '1561' -- VISA CEMEA All other MENA ENG (Sharia)
			, '1562' -- VISA CEMEA All other MENA AR (Sharia)
			, '1563' -- VISA CEMEA All other MENA ENG (Conventional)
			, '1564' -- VISA CEMEA All other MENA AR (Conventional)
			, '1565' -- VISA CEMEA All other MENA FRE (Conventional)
			, '225' -- Wexas
			, '782' -- Ten Private Classic
			--, '794' -- Ten Private Dedicated
		
			 , '540' --Amex Ecuador Platinum RCP
			 , '541' --Amex Ecuador Platinum GRCC
			 , '543' --Amex Ecuador Gold
			 , '544' --Amex Ecuador Elite Lifemiles (TACA)
			 , '548' --Amex Peru Platinum RCP (Interbank)
			 , '549' --Amex Argentina Santander Black
			 , '562' --Amex Paraguay Platinum RCP
			 , '571' --Amex Costa Rica Platinum RCP
			 , '572' --Amex Guatemala Platinum RCP
			 , '573' --Amex Honduras Platinum Lifemiles Avianca (TACA)
			 , '574' --Amex El Salvador Platinum RCP
			 , '575' --Amex Pasaporte Platinum
			 , '590' --Amex Costa Rica AAdvantage Prestige
			 , '591' --Amex Costa Rica Lifemiles Elite
			 , '592' --Amex Costa Rica Platinum GRCC
			 , '593' --Amex Costa Rica AAdvantage Platinum
			 , '594' --Amex Costa Rica Lifemiles Premium Gold BBL
			 , '595' --Amex Costa Rica Pricesmart Platinum BBL
			 , '596' --Amex Costa Rica Gane Premios Platinum BBL
			 , '597' --Amex Costa Rica CashBack Platinum BBL
			 , '598' --Amex Guatemala AAdvantage Prestige
			 , '599' --Amex Guatemala Lifemiles Elite (TACA)
			 , '600' --Amex Guatemala Platinum Revolve
			 , '601' --Amex Guatemala AAdvantage Platinum
			 , '602' --Amex Guatemala PriceSmart Platinum
			 , '603' --Amex Guatemala Lifemiles Platinum
			 , '604' --Amex Colombia Platinum RCP
			 , '612' --Amex Nicaragua Black (Blue Box)
			 , '646' --Amex Honduras Platinum RCP
			 , '649' --Amex Honduras Platinum GRCC
			 , '650' --Amex Honduras Elite Lifemiles Avianca (TACA)
			 , '651' --Amex Honduras PriceSmart Platinum
			 , '652' --Amex Honduras Los Andes Platinum
			 , '653' --Amex Honduras Tigo Platinum
			 , '654' --Amex Honduras AAdvantage Platinum
			 , '655' --Amex Honduras AAdvantage Prestige
			 , '658' --Amex Honduras Economia Platinum
			 , '659' --Amex Republica Dominicana Platinum RCP
			 , '661' --Amex Republica Dominicana Casa de Campo Platinum
			 , '663' --Amex Republica Dominicana Gold
			 , '668' --Amex Costa Rica Black INCAE
			 , '669' --Amex Colombia Mileage Plus / Amex Colombia Gold
			 , '686' --Amex Nicaragua AAdvantage Prestige
			 , '687' --Amex Nicaragua Lifemiles Elite
			 , '688' --Amex Nicaragua Platinum RCP
			 , '689' --Amex Nicaragua AAdvantage Platinum
			 , '690' --Amex Nicaragua Lifemiles Platinum
			 , '725' --Amex El Salvador AAdvantage Platinum
			 , '726' --Amex El Salvador Platinum GRCC
			 , '727' --Amex El Salvador Pricesmart
			 , '728' --Amex El Salvador LifeMiles Platinum
			 , '729' --Amex El Salvador LifeMiles Elite
			 , '784' --Amex Peru Platinum BBL (Blue Box Line)
			 , '785' --Amex Uruguay Platinum RCP
			 , '846' --Amex Chile Santander Black Worldmember Limited
			 , '911' --Amex Ecuador AAdvantage Elite (Black Blue Box)
			 , '912' --Amex Ecuador AAdvantage Platinum (Black Blue Box)
			 , '999' --Amex Panama Gold
			 , '1004' --Amex Colpatria Platinum GRCC
			 , '1042' --Amex Chile Santander Black Worldmember
			 , '1043' --Amex Chile Santander Platinum RCP
			 , '1048' --Amex Panama ConnectMiles Black
			 , '1531' --Amex Mexico Santander Legacy
			 , '1684' --Amex Costa Rica Lifemiles Platinum BBL
			 , '1686' --Amex Costa Rica Cashback Premium (Black BBL)
			 , '1012' --BBVA - UHN Lifestyle Mexico
			 , '885' --Itaú (Mastercard) - Consultor de Experiências
			 , '1578' --Itaú (Visa) - Consultor de Experiências
		
			, '1174' -- VISA LAC Infinite - English Regional
			, '1175' -- VISA LAC Signature - English Regional
			, '1176' -- VISA LAC Platinum - English Regional
			, '1177' -- VISA LAC Infinite - Spanish Regional
			, '1178' -- VISA LAC Signature - Spanish Regional
			, '1179' -- VISA LAC Platinum - Spanish Regional
			, '1180' -- VISA LAC Infinite - Brazil
			, '1181' -- VISA LAC Infinite - Mexico
			, '1182' -- VISA LAC Platinum - Brazil
			, '1183' -- VISA LAC Platinum - Mexico
			, '1184' -- VISA LAC Signature - Argentina
			, '1185' -- VISA LAC Signature - Colombia
			, '1186' -- VISA LAC Infinite - Colombia
			, '1187' -- VISA LAC Platinum - Colombia
			, '1188' -- VISA LAC Platinum - Argentina
			, '1189' -- VISA LAC Platinum - Peru
			, '1190' -- VISA LAC Signature- Peru
			, '1191' -- VISA LAC Infinite- Chile
			, '1192' -- VISA LAC Infinite - Peru
			, '1193' -- VISA LAC Signature - Chile
			, '1194' -- VISA LAC Platinum - Chile
			, '1198' -- VISA LAC Business Platinum- English Regional
			, '1199' -- VISA LAC Signature Business - English Regional
			, '1200' -- VISA LAC Infinite Business - English Regional
			, '1201' -- VISA LAC Business Platinum - Spanish Regional
			, '1202' -- VISA LAC Signature Business - Spanish Regional
			, '1203' -- VISA LAC Infinite Business - Spanish Regional
			, '1204' -- VISA LAC Business Platinum - Brazil
			, '1205' -- VISA LAC Infinite Corporate - Brazil
			, '1206' -- VISA LAC Business Platinum - Mexico
			, '1207' -- VISA LAC Infinite Business - Mexico
			, '1208' -- VISA LAC Infinite Corporate - Mexico
			, '1209' -- VISA LAC Corporate Signature - Argentina
			, '1210' -- VISA LAC Business Signature - Chile
		
			--'556'  -- Amex China CMB Platinum stop on 31 March 2019
			,'561'  -- Amex China ICBC Centurion will continue the NPS.
			,'560'  -- Amex China ICBC Platinum will continue the NPS.
			,'1689'  -- ICBC Private Bank Concierge started NPS on 1st April 2019. 

		
			, '864' -- Swisscard - Amex Centurion Travel & Lifestyle Service (English)
			, '865' -- Swisscard - Amex Platinum Travel & Lifestyle Service (English)
			, '866' -- Swisscard - Amex Gold Travel Service (English)
			, '867' -- Swisscard - Amex Gold Business Travel Service (English)
			, '869' -- Swisscard - Amex Centurion Travel & Lifestyle Service (German)
			, '870' -- Swisscard - Amex Platinum Travel & Lifestyle Service (German)
			, '871' -- Swisscard - Amex Gold Travel Service (German)
			, '872' -- Swisscard - Amex Gold Business Travel Service (German)
			, '873' -- Swisscard - Amex Centurion Travel & Lifestyle Service (French)
			, '874' -- Swisscard - Amex Platinum Travel & Lifestyle Service (French)
			, '875' -- Swisscard - Amex Gold Travel Service (French)
			, '876' -- Swisscard - Amex Gold Business Travel Service (French)
			, '877' -- Swisscard - Amex Centurion Travel & Lifestyle Service (Italian)
			, '878' -- Swisscard - Amex Platinum Travel & Lifestyle Service (Italian)
			, '879' -- Swisscard - Amex Gold Travel Service (Italian)
			, '880' -- Swisscard - Amex Gold Business Travel Service (Italian)
			, '902' -- Swisscard - Amex Centurion Relationship Manager Luana Machi
			, '903' -- Swisscard - Amex Centurion Relationship Manager Korine Weideli
			, '932' -- Swisscard - Credit Suisse Bonviva Platinum Travel & Concierge Service
			, '933' -- Swisscard - MyNAB Platinum Travel & Concierge Service
			, '934' -- Swisscard - Mastercard Platinum Travel & Concierge Service
			, '965' -- Swisscard - Amex Corporate Platinum Travel & Lifestyle Service
			, '966' -- Swisscard - Amex Corporate Gold Travel Service

			,'1730' -- Swisscard - Amex Centurion Dedicated Service

			,'1752' --revolut schemes
			,'1753'
			,'1754'
		
			, '991' -- New Amex Alpha Card Gold (Flemish)
			, '987' -- New Amex Alpha Card Platinum (Flemish)
			, '719' -- Amex Alpha Card Platinum (Flemish)
			, '715' -- Amex Alpha Card Gold (French)
			, '718' -- Amex Alpha Card Platinum (French)
			, '988' -- New Amex Alpha Card Platinum (French)
			, '992' -- New Amex Alpha Card Gold (French)
			, '1037' -- Scotia Wealth Management Pursuits - English
			, '1038' -- Évasion de Gestion de patrimoine Scotia
			, '1729' -- Boston Consulting Group (Australia)
			, '944' -- PILOT Boston Consulting Group (BCG)- German
			, '1723' -- Boston Consulting Group (Italy)
			, '942' -- PILOT Boston Consulting Group (BCG) - Japanese
			, '1728' -- Boston Consulting Group (Singapore)
			, '1716' -- BCG
			, '1717' -- BCG
			, '1611' -- Vodafone Black
			, '1715' -- HSBC VI Singapore 
			, '1741' -- HSBC VI Singapore 
			, '1752' -- Revolut
			, '1753' -- Revolut
			, '1754' -- Revolut
			, '1172' -- Revolut
			, '1773' -- Revolut
			, '1777' -- Revolut Germany DE
			, '1779' -- Revolut Italy IT
			, '1755' -- Revolut
			, '1778' -- Revolut Portugal PT
			, '1776' -- Revolut Spain ES
			, '1774' -- Revolut UK ENG
			, '1771' -- Revolut
			, '1775' -- Revolut France FR
			, '1780' -- Revolut Rest of Europe (English)
			)

	) a
WHERE 
	-- 'remove these' refers to the filter which excludes -- when scheme like RBS or Natwest and postcode is blank, its implemented in a case right at the top of the query
	remove_these = 0 

	-- if the member has 'FEEDBACK' in any subject line for jobs closed in the preceding 30 days, remove that member entirely
	AND Feedback_Count < 1 	
	
	--Swisscard Exclusions
	AND DerivedLanguage != 'Check' 
	AND Gender != 'Check'
	AND swiss_close_check = 0
	--AND Swiss_Feedback_Count < 1

	 --Marketing Consent Agreed
	AND MarketingConsent = 1

	-- removed filter to reinclude Admin Jobs
	AND TenMAID_Dept != 'Admin Jobs'  

	-- Start of UNION to Validation Test Accounts


	-- Start of UNION to Validation Test Accounts

--		UNION
	
--	(
--		SELECT 
--			convert(datetime, GetDate()) AS DateAdded
--			, CAST(('201908141'
--					) AS INT) AS memberID
--			, 'Mr.' AS Title
--			, 'Andrew' AS First_Name
--			, 'Archeos' AS Surname
--			, 'M' AS Gender
--			, 'English' AS DerivedLanguage
--			, '3AL' AS Postcode
--			, '0000001' AS JobID
--			, 'This is a fake job for validation' AS subject
--			, 'Validation Dept' AS TenMAID_Dept
--			, 'Validation Group' AS group1
--			, 'Ten Private Classic' AS scheme
--			, 'ten 24' AS Member_Group_Name
--			, 'Validation LM' AS Closed_By
--			, 'Validation Team' AS Closed_by_Team
--			, 'Validation Sub Team' AS Closed_by_Sub_Team
--			, '782' AS Scheme_ID
--			, '782' AS Scheme_ID01
--			, 'aarcheos@icloud.com' AS Email
--			, '654321' AS LM_ID
--			, 'Validation Office' AS Office
--			, 'Active' AS STATUS
--			, convert(DATE, getdate() - 1) AS ClosedDate
--			--, 'en' AS LanguageID

--			, 0 AS complaint_count
--			, 1 AS MarketingConsent
--			, Null as Job_OSS_OLR
--			, Null as Reference2
--		) 


--UNION
	
--	(
--		SELECT 
--			convert(datetime, GetDate()) AS DateAdded
--			, CAST(('201908142'
--					) AS INT) AS memberID
--			, 'Ms.' AS Title
--			, 'Anna' AS First_Name
--			, 'Seizer' AS Surname
--			, 'F' AS Gender
--			, 'English' AS DerivedLanguage
--			, '3AL' AS Postcode
--			, '0000002' AS JobID
--			, 'This is a fake job for validation' AS subject
--			, 'Validation Dept' AS TenMAID_Dept
--			, 'Validation Group' AS group1
--			, 'Ten Private Classic' AS scheme
--			, 'ten 24' AS Member_Group_Name
--			, 'Validation LM' AS Closed_By
--			, 'Validation Team' AS Closed_by_Team
--			, 'Validation Sub Team' AS Closed_by_Sub_Team
--			, '782' AS Scheme_ID
--			, '782' AS Scheme_ID01
--			, 'annaseizer1981@gmail.com' AS Email
--			, '654321' AS LM_ID
--			, 'Validation Office' AS Office
--			, 'Active' AS STATUS
--			, convert(DATE, getdate() - 1) AS ClosedDate
--			, 0 AS complaint_count
--			, 1 AS MarketingConsent
--						, Null as Job_OSS_OLR
--			, Null as Reference2
--		) 


--		UNION
	
--	(
--		SELECT 
--			convert(datetime, GetDate()) AS DateAdded
--			, CAST(('201908143'
--					) AS INT) AS memberID
					
--			, 'Ms.' AS Title
--			, N'Yu 妤' AS First_Name
--			, N'Kang 康' AS Surname
--			, 'F' AS Gender
--			, 'English' AS DerivedLanguage
--			, '3AL' AS Postcode
--			, '0000003' AS JobID
--			, 'This is a fake job for validation' AS subject
--			, 'Validation Dept' AS TenMAID_Dept
--			, 'Validation Group' AS group1
--			, 'Amex China CMB Platinum' AS scheme
--			, 'Amex China' AS Member_Group_Name
--			, 'Validation LM' AS Closed_By
--			, 'Validation Team' AS Closed_by_Team
--			, 'Validation Sub Team' AS Closed_by_Sub_Team
--			, '556' AS Scheme_ID
--			, '556' AS Scheme_ID01
--			, 'sunnykang2u@gmail.com' AS Email
--			, '654321' AS LM_ID
--			, 'Validation Office' AS Office
--			, 'Active' AS STATUS
--			, convert(DATE, getdate() - 1) AS ClosedDate
--			, 0 AS complaint_count
--			, 1 AS MarketingConsent
--						, Null as Job_OSS_OLR
--			, Null as Reference2
--		)

--UNION
	
--	(
--		SELECT 
--			convert(datetime, GetDate()) AS DateAdded
--			, CAST(('201908144'
--					) AS INT) AS memberID
--			, 'Ms.' AS Title
--			, N'Yu 妤' AS First_Name
--			, N'Kang 康' AS Surname
--			, 'F' AS Gender
--			, 'English' AS DerivedLanguage
--			, '3AL' AS Postcode
--			, '0000004' AS JobID
--			, 'This is a fake job for validation' AS subject
--			, 'Validation Dept' AS TenMAID_Dept
--			, 'Validation Group' AS group1
--			, 'Amex China ICBC Centurion' AS scheme
--			, 'Amex China' AS Member_Group_Name
--			, 'Validation LM' AS Closed_By
--			, 'Validation Team' AS Closed_by_Team
--			, 'Validation Sub Team' AS Closed_by_Sub_Team
--			, '561' AS Scheme_ID
--			, '561' AS Scheme_ID01
--			, 'kangyu@ymail.com' AS Email
--			, '654321' AS LM_ID
--			, 'Validation Office' AS Office
--			, 'Active' AS STATUS
--			, convert(DATE, getdate() - 1) AS ClosedDate
--			, 0 AS complaint_count
--			, 1 AS MarketingConsent
--						, Null as Job_OSS_OLR
--			, Null as Reference2
--		) 
--UNION
	
--	(
--		SELECT 
--			convert(datetime, GetDate()) AS DateAdded
--			, CAST(('201908145'
--					) AS INT) AS memberID
--			, 'Ms.' AS Title
--			, N'Yu 妤' AS First_Name
--			, N'Kang 康' AS Surname
--			, 'F' AS Gender
--			, 'English' AS DerivedLanguage
--			, '3AL' AS Postcode
--			, '0000005' AS JobID
--			, 'This is a fake job for validation' AS subject
--			, 'Validation Dept' AS TenMAID_Dept
--			, 'Validation Group' AS group1
--			, 'Amex China ICBC Platinum' AS scheme
--			, 'Amex China' AS Member_Group_Name
--			, 'Validation LM' AS Closed_By
--			, 'Validation Team' AS Closed_by_Team
--			, 'Validation Sub Team' AS Closed_by_Sub_Team
--			, '560' AS Scheme_ID
--			, '560' AS Scheme_ID01
--			, 'sunnybaby2u@yahoo.com' AS Email
--			, '654321' AS LM_ID
--			, 'Validation Office' AS Office
--			, 'Active' AS STATUS
--			, convert(DATE, getdate() - 1) AS ClosedDate
--			, 0 AS complaint_count
--			, 1 AS MarketingConsent
--						, Null as Job_OSS_OLR
--			, Null as Reference2
--		) 

--UNION
	
--	(
--		SELECT 
--			convert(datetime, GetDate()) AS DateAdded
--			, CAST(('201908146'
--					) AS INT) AS memberID
--			, 'Mr.' AS Title
--			, 'Diego' AS First_Name
--			, 'Diaz Paterson' AS Surname
--			, 'M' AS Gender
--			, 'English' AS DerivedLanguage
--			, '3AL' AS Postcode
--			, '0000006' AS JobID
--			, 'This is a fake job for validation' AS subject
--			, 'Validation Dept' AS TenMAID_Dept
--			, 'Validation Group' AS group1
--			, 'Ten Private Classic' AS scheme
--			, 'ten 24' AS Member_Group_Name
--			, 'Validation LM' AS Closed_By
--			, 'Validation Team' AS Closed_by_Team
--			, 'Validation Sub Team' AS Closed_by_Sub_Team
--			, '782' AS Scheme_ID
--			, '782' AS Scheme_ID01
--			, 'diegodiazpaterson@gmail.com' AS Email
--			, '654321' AS LM_ID
--			, 'Validation Office' AS Office
--			, 'Active' AS STATUS
--			, convert(DATE, getdate() - 1) AS ClosedDate
--			, 0 AS complaint_count
--			, 1 AS MarketingConsent
--						, Null as Job_OSS_OLR
--			, Null as Reference2
--		)



END
