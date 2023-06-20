------------------------------------------------------------------------
-- Version:			1
-- Release Date:	2012-11-21
-- Author:			Davide Mauri (SolidQ)
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			Show missing indexes information and generate the
--					CREATE INDEX command for all the missing indexes
--					in a specific database
------------------------------------------------------------------------
declare @max_columns_per_index int
declare @min_avg_user_impact numeric(5,2)
declare @target_database sysname

set @max_columns_per_index = 5
set @min_avg_user_impact = 50
set @target_database = 'AdventureWorks'

if (object_id('sys2.missing_indexes') is null)
begin
	raiserror('sys2.missing_indexes not found.', 16, 1)
	return
end
	
select 
	* 
from 
	sys2.missing_indexes	
where
	[total_columns_to_index] <= @max_columns_per_index and avg_user_impact > @min_avg_user_impact 
and
	database_name = @target_database
order by
	(user_seeks * avg_user_impact) / total_columns_to_index desc
	
