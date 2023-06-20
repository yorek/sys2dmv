with cte_qs as 
(
	SELECT 
		[object_name] = o.name,
		[schema_name] = s.name,
		qs.*
	FROM 
		sys.dm_exec_procedure_stats qs
	inner join
		sys.objects o on qs.object_id = o.object_id
	inner join
		sys.schemas s on o.schema_id = s.schema_id
	where
		database_id = DB_ID()	
)
SELECT TOP 15 
	[schema_name],
	[object_name],
	execution_count = SUM(execution_count),
	last_execution_time = MAX(last_execution_time),
    avg_elapsed_time_ms =  (SUM(total_elapsed_time) / SUM(execution_count)) / 1000.,
    avg_logical_reads =  (SUM(total_logical_reads) / SUM(execution_count))
FROM 
   cte_qs
GROUP BY 
	[schema_name],
	[object_name]	
ORDER BY
	avg_elapsed_time_ms DESC;
GO

