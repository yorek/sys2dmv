------------------------------------------------------------------------
-- Version:			1
-- Release Date:	2012-11-21
-- Author:			Davide Mauri (SolidQ)
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			Show the resource usage by database
------------------------------------------------------------------------
declare @top_count int;
declare @minute_window int;
declare @show_plans bit;

set @top_count = 10;
set @minute_window = 1; -- set to null to analyze all queries. 
set @show_plans = 0;

if (object_id('sys2.query_stats') is null)
begin
	raiserror('sys2.query_stats not found.', 16, 1)
	return
end

if (object_id('tempdb..#t') is not null) 
	drop table #t

select 
	database_id,
	database_name = db_name(database_id),
	total_resource_usage = sum(avg_worker_time) -- Change the aggreagated column to analyze also logical_reads, logical_writes, execution_count and so on...
into
	#t
from 
	sys2.query_stats(0)
where
	(last_execution_time >= dateadd(minute, -@minute_window, getdate()) or @minute_window is null)
group by
	database_id
option
	(recompile)
	
select
	*,
	impact_perc = (100. * total_resource_usage) / (sum(total_resource_usage) over ())
from
	#t
order by
	total_resource_usage desc
