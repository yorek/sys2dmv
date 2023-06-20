select 
	d.database_id,
	s.[schema_id],
	o.[object_id],
	database_name = d.[name],
	object_schema = s.[name],
	[object_name] = o.[name],
	i.*
from 
	sys.dm_db_index_physical_stats(14, NULL, NULL, NULL, 'SAMPLED') i
inner join
	sys.databases d on i.database_id = d.database_id
inner join
	sys.objects o on i.[object_id] = o.[object_id]
inner join
	sys.schemas s on o.[schema_id] = s.[schema_id]
where 
(
	avg_fragmentation_in_percent > 20
or
	avg_page_space_used_in_percent < 80
)
and
	page_count > 8