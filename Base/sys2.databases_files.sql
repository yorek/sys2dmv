------------------------------------------------------------------------
-- Script:			sys2.databases_files.sql
-- Version:			4
-- Release Date:	2012-03-26
-- Author:			Davide Mauri (Solid Quality Mentors)
-- Credits:			-
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			SELECT * FROM sys2.databases_files					
-- Notes:			
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Version History
--
-- 1				First Version
-- 2				Added "space_used_in_mb". This column will show the used space for the active database
-- 3				Added File Type information and Improved Max_Size reporting when Autogrow is disabled
-- 4				Added "autogrow_enabled" and "autogrow_unlimited" columns
------------------------------------------------------------------------


IF NOT EXISTS(SELECT * FROM sys.schemas s WHERE s.[name] = 'sys2')
	EXEC sp_executesql N'CREATE SCHEMA sys2'
go
	
IF (OBJECT_ID('sys2.databases_files', 'V') IS NOT NULL)
	DROP VIEW sys2.databases_files
GO

CREATE VIEW sys2.databases_files
AS
with cte as
(
select 
	database_name = d.name,
	mf.database_id,
	file_id,
	file_name = mf.name,
	file_type_id = mf.type,
	file_type = mf.type_desc,
	physical_name,
	size_in_mb = (cast([size] as bigint)* 8) / 1024.,	
	space_used_in_mb = (cast(fileproperty(mf.name, 'SpaceUsed') as bigint)* 8) / 1024.,      
	max_size_in_mb = case 
							when growth = 0 then (cast([size] as bigint)* 8) / 1024. 
							when  growth != 0 and max_size not in (-1, 268435456) then (cast(max_size as bigint)* 8) / 1024. 
					else null end,
	growth_in_mb = case when is_percent_growth <> 0 then null else (cast(growth as bigint) * 8) / 1024. end,
	growth_in_percent = case when is_percent_growth <> 0 then growth else null end,
	autogrow_enabled = case when growth = 0 then 0 else 1 end,
	autogrow_unlimited = case when max_size in (-1, 268435456) and growth != 0 then 1 else 0 end,
	database_read_only = d.is_read_only,
	file_read_only = mf.is_read_only,
	database_state_desc = d.state_desc
from 
	sys.master_files mf
inner join
	sys.databases d on d.database_id = mf.database_id
)
select	
	database_name,
	database_id,
	file_id,
	file_name,
	file_type_id,
	file_type,
	physical_name,
	size_in_mb,	
	space_used_in_mb,
	max_size_in_mb,
	available_space_for_growth_in_mb = max_size_in_mb - size_in_mb,
	growth_in_mb,
	growth_in_percent,
	autogrow_enabled,
	autogrow_unlimited,
	database_state_desc,
	database_read_only,
	file_read_only
from
	cte

