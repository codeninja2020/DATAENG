




-- =============================================
-- Author:		<Ten Data>
-- Create date: <06/11/2019>
-- Description:	<V1 Migrating into Ten Data Warehouse>
-- =============================================
CREATE PROCEDURE [TDWI].[sp_EMP_History]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO TenDataWarehouse_Internal.dbo.EMP_History
Select 
concat(convert(int,convert(varchar(8),getdate(),112)),ecl.EmployeeID)  as HistKey,
convert(date, getdate()) as RunDate,
ecl.EmployeeID as EmployeeID,
ecl.CallMediaID,
stcl.financecode,
ecl.Firstname_Encrypted as emp_firstname,
ecl.Surname_Encrypted as emp_Surname,
ecl.jobtitleid,
ecl.contractedhours,
ecl.FTE,
ecl.DateCreated,
ecl.Datejoined,
ecl.dateleaved ,
ecl.employeetype,
ecl.active,
ecl.[NewRegionID],
ecl.NewSubRegionID,
ecl.NewTeamID,
ecl.NewSubTeamID,
ecl.NewSpecialistTeamID,
ecl.OfficeID,
ecl.PayrollOfficeID,
rcl.Description [Region],
srcl.Name [Sub_Region],
tcl.TeamName,
stcl.SubTeamName,
scl.SpecialistTeamName,
man.EmployeeID as [Manager_ID],
man.Firstname + ' ' + man.Surname [Manager_Name],
o.name as office,
case when
o.name = 'Sao Paulo' and ecl.jobtitleid = 5 then 'Sao PauloLM' 
when o.name = 'Sao Paulo' and ecl.jobtitleid = 58 then 'Sao PauloLM'
when o.name = 'Sao Paulo' and ecl.jobtitleid = 51 then 'Sao PauloLM'
else o.name end
as [Adjusted_Office_Name],
case when
o.name = 'Sao Paulo' and ecl.jobtitleid = 5 then 1000
when o.name = 'Sao Paulo' and ecl.jobtitleid = 58 then 1000
when o.name = 'Sao Paulo' and ecl.jobtitleid = 51 then 1000
else ecl.OfficeID end
as [Adjusted OfficeID]

from

 [TenDataWarehouse].[TenMAID_Global].[Employees]  as ecl

 left join [TenDataWarehouse].[TenMAID_Global].[Offices] as o
on o.officeid = ecl.officeid


left join [TenDataWarehouse].[TenMAID_Global].[tm5_SpecialistTeams] as scl
on scl.SpecialistId = ecl.NewSpecialistTeamID


left join [TenDataWarehouse].[TenMAID_Global].[tm5_SubTeam] as stcl
on stcl.SubTeamId = ecl.NewSubTeamID

left join [TenDataWarehouse].[TenMAID_Global].[tm5_Region] as rcl
on rcl.RegionId = ecl.NewRegionID

left join [TenDataWarehouse].[TenMAID_Global].[tm5_SubRegion] as srcl
on srcl.SubRegionId = ecl.NewSubRegionID

left join [TenDataWarehouse].[TenMAID_Global].[tm5_Team] as tcl
on tcl.TeamId = ecl.NewTeamID

 left join [TenDataWarehouse].[TenMAID_Global].[Employees]  as man 
 on man.employeeid = ecl.ManagerID

END
