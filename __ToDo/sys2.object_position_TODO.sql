select
	[object_name] = o.[name],
	[object_type] = o.[type_desc],
	[index_name] = i.[name],
	[filegroup_name] = f.[name]
from
	sys.indexes i
inner join
	sys.objects o on i.[object_id] = o.[object_id]
inner join
	sys.filegroups f on i.data_space_id = f.data_space_id

