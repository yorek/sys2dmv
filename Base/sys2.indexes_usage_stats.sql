------------------------------------------------------------------------
-- Script:			sys2.indexes_usage_stats.sql
-- Version:			6.1
-- Release Date:	2012-06-07
-- Author:			Davide Mauri (SolidQ)
-- Credits:			
-- Contributors:	Francesco Quaratino, Francesco Milano
-- License:			Microsoft Public License (Ms-PL)
-- Target Version:	SQL Server 2005 RTM or above
-- Tab/indent size:	4
-- Usage:			SELECT * FROM sys2.indexes_usage_stats('<schema>.<table>')					
-- Notes:			If you pass a NULL value as parameter, you'll get all the indexes in ALL tables.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Version History
--
-- 4				Added "total_seeks", "total_scans", "total_lookups" and "total_updates" columns
-- 5				Added "is_unique" column
-- 6				Now all indexes will be listed even if they've never been used
-- 6.1				Fixed a bug where you'll may get indexes also from other databases 
------------------------------------------------------------------------

IF NOT EXISTS(SELECT * FROM sys.schemas s WHERE s.[name] = 'sys2')
	EXEC sp_executesql N'CREATE SCHEMA sys2'
go
	
IF (OBJECT_ID('sys2.indexes_usage_stats', 'IF') IS NOT NULL)
	DROP FUNCTION sys2.indexes_usage_stats
GO

CREATE FUNCTION sys2.indexes_usage_stats(@tablename sysname)
RETURNS TABLE 
AS
RETURN
SELECT TOP 4096
	[schema_name] = s.[name],
	[object_name] = o.[name],
	[object_type] = o.[type],
	[object_type_desc] = o.[type_desc],
	[index_name] = i.[name],
	[index_type] = i.[type],
	[index_type_desc] = i.[type_desc],	
	i.is_disabled,
	i.is_primary_key,
	i.is_unique,
	i.is_unique_constraint,
	total_seeks = user_seeks + system_seeks,
	total_scans = user_scans + system_scans,
	total_lookups = user_lookups + system_lookups,
	total_updates = user_updates + system_updates,	
	u.*	
FROM 
    sys.indexes i
LEFT OUTER JOIN
    sys.dm_db_index_usage_stats u on i.[object_id] = u.[object_id] and i.[index_id] = u.[index_id]
INNER JOIN
	sys.objects o ON i.[object_id] = o.[object_id]
INNER JOIN
	sys.schemas s ON o.[schema_id] = s.[schema_id]
WHERE 
	(i.[object_id] = object_id(@tablename) OR @tablename IS NULL)
AND
	i.[type] <> 0
AND
	o.[type] IN ('U', 'V')
AND
    u.[database_id] = db_id()
ORDER BY
	u.[user_seeks]
GO
