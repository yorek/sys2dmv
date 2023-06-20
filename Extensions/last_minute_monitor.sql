------------------------------------------------------------------------
-- Version:			1
-- Release Date:	2012-11-21
-- Author:			Davide Mauri (SolidQ)
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			Return the most resource consuming queries executed
--					in the last "x" minutes.
------------------------------------------------------------------------
declare @top_count int;
declare @minute_window int;
declare @show_plans bit;

set @top_count = 10;
set @minute_window = 1;
set @show_plans = 0;

if (object_id('sys2.query_stats') is null)
begin
	raiserror('sys2.query_stats not found.', 16, 1)
	return
end

with cte as
(
	select top (@top_count)
		cache_elapsed_min = datediff(minute, creation_time, last_execution_time),
		*
	from
		sys2.query_stats(@show_plans)
	where
		last_execution_time >= dateadd(minute, -@minute_window, getdate())
	order by
		total_worker_time desc -- Change the order by column to analyze also logical_reads, logical_writes, execution_count and so on...
)
select
	execution_per_minute = case when cache_elapsed_min != 0 then (1. * execution_count) / cache_elapsed_min else null end,	
	*
from
	cte