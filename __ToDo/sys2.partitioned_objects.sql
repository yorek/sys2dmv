SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view sys2.partitioned_objects
as
select distinct
	p.object_id,
	index_name = i.name,
	index_type_desc = i.type_desc,
	partition_scheme = ps.name,
	data_space_id = ps.data_space_id,
	function_name = pf.name,
	function_id = ps.function_id
from 
	sys.partitions p
inner join
	sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id
inner join
	sys.data_spaces ds on i.data_space_id = ds.data_space_id
inner join
	sys.partition_schemes ps on ds.data_space_id = ps.data_space_id
inner join
	sys.partition_functions pf on ps.function_id = pf.function_id

GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
