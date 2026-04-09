


-- =============================================
-- Author:		<TENDATA>
-- Create date: <2019-10-25>
-- Description: Online Request Categorisation
--				V1 Migrated over from BLASTERTRON
-- =============================================


CREATE PROCEDURE [dbo].[sp_REF_TBL_Job_OSS_OLR]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		IF OBJECT_ID('[TenDataWarehouse_Internal].dbo.REF_TBL_Job_OSS_OLR') IS NOT NULL
			DROP TABLE [TenDataWarehouse_Internal].dbo.REF_TBL_Job_OSS_OLR;

OPEN SYMMETRIC KEY SQLSymmetricKey
DECRYPTION BY CERTIFICATE SelfSignedCertificate;

		select x.*
		into [TenDataWarehouse_Internal].dbo.REF_TBL_Job_OSS_OLR
	from	(

--Does not need tenmaidUS as it does not contain any online briefs
select
jobid,
memberid,
briefdate,
--subject SQL_Latin1_General_CP1_CI_AS , 
--BriefOriginal, 
briefmethodid, 
createdby,
----Operational OSS OLR
case when j.BriefMethodID <> 15 then 'HTR'
		when j.BriefMethodID =15 and j.createdby <> 168 then 'OLR'
		when j.BriefMethodID = 15 and j.ClosedBy = 168 then 'OSS' 
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Track%' then 'OSS'
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Untrack%' then 'OSS'

		--when j.BriefMethodID = 15 and j.BriefOriginal like '%Restaurant Rumour Request:%' then 'OSS Dining Rumour-V1'
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%Sport Rumour Request:%' then 'OSS Sport Rumour-V1'
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%Theatre Rumour Request:%' then 'OSS Theatre Rumour-V1'
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%Music Rumour Request:%' then 'OSS Music Rumour-V1'
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%Comedy Rumour Request:%' then 'OSS Comedy Rumour-V1'

		--when j.BriefMethodID = 15 and j.BriefOriginal like 'Member wants updates on%' then 'OSS Track Artist-V1'
		--when j.BriefMethodID = 15 and j.BriefOriginal like 'Monitor future tour dates%' then 'OSS Track Artist-V1'
		--when j.BriefMethodID = 15 and j.BriefOriginal like '%Remove any tracking%' then 'OSS Untrack Artist-V1'
		else 'OLR' 
	end as [Job_Operational_OSS_OLR],


------Billing OSS OLR
----------------------------V2
	case when j.BriefMethodID <> 15 then 'HTR'
				--Dining Requests
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Dining Request</b>%' then 'OLR Dining-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Dining Request</s%' then 'OLR Dining-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Hot Table Booking%' then 'OSS Hot table-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Restaurant Name%' then 'OLR Dining-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%SO!</%' then 'OSS Hot table-V2'
		--Travel requests
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Hotel Name</b>%' then 'OSS Hotel-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Pay Local Selected</b>%' then 'OSS Car Rental-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Outbound Airport</b>%' then 'OSS Flight-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Flying from</b>%' then 'OSS Flight-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Travelling From<%' then 'OLR Travel Brief-V2'
		--General Request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Briefing Message<%' then 'OLR General Brief-V2'
		--Benefit Request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Redeemed_via_phone%' then 'OLR Phone Benefit-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Redeemed_via_code%' then 'OSS Code Benefit-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Redeemed_via_url%' then 'OSS URL Benefit-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Redeemed_via_pdf%' then 'OSS PDF Benefit-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Redeemed_via_Lifestyle_Manager%' then 'OLR LM Benefit-V2'
		--Entertainment Request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Track%' then 'OSS Track Artist-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;Untrack%' then 'OSS Untrack Artist-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;see_enta%' then 'OLR Tickets-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Event Name</%' then 'OLR Tickets-V2'
		--Event Request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;member_event%' then 'OLR Member Event-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;complimentary_event%' then 'OLR Complimentary Event-V2'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Fully booked%' then 'OLR Member Event-V2'
		
		-- Currently no definition available
				when j.BriefMethodID = 15 and j.BriefOriginal like '%nbsp;LimousineBriefing%' then 'OLR Limo Briefing -V2'
				when j.BriefMethodID = 15 and j.BriefOriginal like '%<b>Flight Direction</b>&nbsp;%' then 'OLR yQ Meet & Greet -V2'
------------------------------------------------------V1
		--Entertainment Request
		when j.BriefMethodID = 15 and j.BriefOriginal like 'Member wants updates on%' then 'OSS Track Artist-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like 'Monitor future tour dates%' then 'OSS Track Artist-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Remove any tracking%' then 'OSS Untrack Artist-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%: Sport:%' then 'OLR Sport Tickets-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%: Theatre%' then 'OLR Theatre Tickets-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%: Music:%' then 'OLR Music Tickets-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%: Comedy:%' then 'OLR Comedy Tickets-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Sport Rumour Request:%' then 'OSS Sport Rumour-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Theatre Rumour Request:%' then 'OSS Theatre Rumour-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Music Rumour Request:%' then 'OSS Music Rumour-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Comedy Rumour Request:%' then 'OSS Comedy Rumour-V1'
		--Dining Requests
		when j.BriefMethodID = 15 and j.BriefOriginal like '%<br>Subject: Online Hot Table%' then 'OSS Hot Table-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Hot Table %' then 'OSS Hot Table-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%First choice date:%' then 'OLR Dining Request-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Restaurant Rumour Request:%' then 'OSS Dining Rumour-V1'
		--Benefit Request
				when j.BriefMethodID = 15 and j.BriefOriginal like '%Online URL%' then 'OSS URL Benefit-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Online PDF%' then 'OSS PDF Benefit-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Online Other%' then 'OSS Other Benefit-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Online Call%' then 'OSS Call Benefit-V1'
		--Benefit Request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Guest Information<br />%' then 'OSS Attend Event-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Guest Information<br>%' then 'OSS Attend Event-V1'
		--Travel Request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Travel@%' then 'OSS Travel-V1'
		
		--general request
		when j.BriefMethodID = 15 and j.BriefOriginal like '%Couttsworld@%' then 'OLR General-V1'
		when j.BriefMethodID = 15 and j.BriefOriginal like '<p>%' then 'OLR General-V1'

		when j.BriefMethodID =15 and j.createdby <> 168 then 'OLR Created by LM'
				when j.BriefMethodID = 15 then 'Online Other'
				else 'HTR' 
	end as [Job_Billing_OSS_OLR],

--	concat(convert(varchar,convert(date,briefdate)),convert(varchar,MemberID),convert(varchar(max),Subject)) [Double Click ID],
row_number()over (Partition by concat(convert(varchar,convert(date,briefdate)),convert(varchar,MemberID),convert(varchar(max),Subject)) order by briefdate asc) as [Click Attempt]
	
from (select jobid,
	memberid,
	briefdate,
	CONVERT(nvarchar(max), DecryptByKey(BriefOriginal_Encrypted)) AS 'BriefOriginal',
	briefmethodid, 
	createdby,
	ClosedBy,
	CONVERT(nvarchar(max), DecryptByKey(Subject_Encrypted)) AS 'Subject'

	from [TenDataWarehouse].[TenMAID_Global].jobs) j

where briefdate > '20170501' and j.BriefMethodID = 15

) as x


END
