------------------------------------------------------------------------
-- Version:			1
-- Release Date:	2012-11-21
-- Author:			Davide Mauri (SolidQ)
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			Show total missing indexes and average importance
--					on every database in the instance.
------------------------------------------------------------------------
declare @max_columns_per_index int
declare @min_avg_user_impact numeric(5,2)

set @max_columns_per_index = 5
set @min_avg_user_impact = 50

if (object_id('sys2.missing_indexes') is null)
begin
	raiserror('sys2.missing_indexes not found.', 16, 1)
	return
end
	
select 
	database_name,
	missing_indexes = count(*),
	avg_user_seeks = avg(user_seeks),
	avg_user_impact = avg(avg_user_impact),
	avg_importance_perc = 100 * avg((user_seeks * avg_user_impact) / total_columns_to_index) / sum(avg((user_seeks * avg_user_impact) / total_columns_to_index)) over ()
from 
	sys2.missing_indexes	
where
	[total_columns_to_index] <= @max_columns_per_index and avg_user_impact > @min_avg_user_impact 
group by
	database_name
order by
	avg_importance_perc desc
	