------------------------------------------------------------------------
-- Script:          sys2.objects_data_spaces.sql
-- Version:         2.3
-- Release Date:    2016-04-12
-- Author:          Davide Mauri
-- Credits:         -
-- License:         MIT License (MIT)
-- Target Version:  SQL Server 2008 or above
-- Tab/indent size: 4 (Spaces)
-- Usage:           SELECT * FROM sys2.objects_data_spaces('<schema>.<table>')                  
-- Notes:           Display in which partition an object (table or index) resides.
--                  If you pass a NULL value as parameter, you'll get data for ALL tables.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Version History
--
-- 2.1              Added information regarding the data space in which LOB data is stored
-- 2.2              Added "space_used" and "alloc_unit_type_desc" columns
-- 2.3              Minimum version required: SQL Server 2008. Added information on partition boundaries
------------------------------------------------------------------------

IF NOT EXISTS(SELECT * FROM sys.schemas s WHERE s.[name] = 'sys2')
    EXEC sp_executesql N'CREATE SCHEMA sys2'
go
    
IF (OBJECT_ID('sys2.objects_data_spaces', 'IF') IS NOT NULL)
    DROP FUNCTION sys2.objects_data_spaces
GO

CREATE FUNCTION sys2.objects_data_spaces(@tablename sysname)
RETURNS TABLE 
AS
RETURN
SELECT TOP 16777216
    o.[object_id],
    [schema_name] = s.[name],
    [object_name] = o.[name],
    [object_type] = o.[type],
    [object_type_desc] = o.[type_desc],
    [index_name] = i.[name],
    [index_type] = i.[type],
    [index_type_desc] = i.[type_desc],  
    alloc_unit_type_desc = au.type_desc,
    p.partition_number,
    p.[rows],                               
    space_used_in_kb = (au.used_pages * 8.0),
    space_used_in_mb = (au.used_pages * 8.0 / 1024.0),      
    p.[data_compression],                       
    p.data_compression_desc,
    data_space_name = ds.name,
    data_space_type = ds.[type],
    data_space_type_desc = ds.type_desc,
    [filegroup_name] = f.name,
    f.is_read_only, 
    lob_data_space = lobds.name,
    pf.fanout,
    range_type = CASE pf.boundary_value_on_right WHEN 1 THEN 'RIGHT' WHEN 0 THEN 'LEFT' ELSE NULL END,
    boundary_value = prv.value
FROM 
    sys.partitions p
INNER JOIN
    sys.indexes i on p.[object_id] = i.[object_id] and p.index_id = i.index_id
INNER JOIN
    sys.objects o ON i.[object_id] = o.[object_id]
INNER JOIN
    sys.schemas s ON o.[schema_id] = s.[schema_id]
INNER JOIN
    sys.data_spaces ds on i.data_space_id = ds.data_space_id
LEFT JOIN
    sys.partition_schemes ps on i.data_space_id = ps.data_space_id  
LEFT JOIN
    sys.partition_functions pf on ps.function_id = pf.function_id
LEFT JOIN
    sys.partition_range_values prv on prv.function_id = ps.function_id and p.partition_number = prv.boundary_id
LEFT JOIN
    sys.destination_data_spaces dds on dds.partition_scheme_id = ps.data_space_id and p.partition_number = dds.destination_id
INNER JOIN
    sys.filegroups f on f.data_space_id = CASE WHEN ds.[type] <> 'PS' THEN ds.data_space_id ELSE dds.data_space_id END
LEFT JOIN
    sys.tables t on o.[object_id] = t.[object_id]
LEFT JOIN
    sys.data_spaces lobds on t.lob_data_space_id = lobds.data_space_id
INNER JOIN
    sys.allocation_units au on  p.partition_id = au.container_id 
where
    (p.[object_id] = object_id(@tablename) OR @tablename IS NULL)
AND
    o.[type] IN ('U', 'V')
ORDER BY    
    o.[name]
GO
