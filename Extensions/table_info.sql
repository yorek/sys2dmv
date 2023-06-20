------------------------------------------------------------------------
-- Version:			1
-- Release Date:	2013-02-04
-- Author:			Davide Mauri (SolidQ)
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			Shows table usage
------------------------------------------------------------------------
if (object_id('sys2.objects_data_spaces') is null)
begin
	raiserror('sys2.objects_data_spaces not found.', 16, 1)
	return
end
;

if (object_id('tempdb..#t') is not null) 
	drop table #t
;

select 
	schema_name, 
	object_name, 
	object_type, 
	object_type_desc, 
	index_name, 
	index_type, 
	index_type_desc, 
	[rows] = SUM(case when alloc_unit_type_desc = 'IN_ROW_DATA' then [rows] else 0 end), 
	space_used_in_kb = SUM(space_used_in_kb), 
	space_used_in_mb = SUM(space_used_in_mb),
	is_partitioned = MAX(case when data_space_type = 'PS' then 1 else 0 end),
	is_compressed = MAX(case when data_compression != 0 then 1 else 0 end)
into 
	#t
from 
	sys2.objects_data_spaces(null)
group by 
	schema_name, object_name, object_type, object_type_desc, index_name, index_type, index_type_desc
;

select
	*	
from
	#t
order by
	[rows] desc