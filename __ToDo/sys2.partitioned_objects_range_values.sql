select 
	p.object_id,
	p.index_id,
	p.partition_number,
	p.rows,
	index_name = i.name,
	index_type_desc = i.type_desc,
	i.data_space_id,
	pf.function_id,
	pf.type_desc,
	pf.boundary_value_on_right,
	destination_data_space_id = dds.destination_id,
	prv.parameter_id,
	prv.value,
	ds2.NAME
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
inner join
	sys.destination_data_spaces dds on dds.partition_scheme_id = ds.data_space_id and p.partition_number = dds.destination_id
INNER JOIN
	sys.data_spaces ds2 ON dds.destination_id = ds2.data_space_id
left outer join
	sys.partition_range_values prv on prv.function_id = ps.function_id and p.partition_number = prv.boundary_id
