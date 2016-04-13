------------------------------------------------------------------------
-- Script:          sys2.objects_data_spaces.sql
-- Version:         2.4
-- Release Date:    2016-04-13
-- Author:          Davide Mauri
-- Credits:         -
-- License:         MIT License (MIT)
-- Target Version:  SQL Server 2008 or above
-- Tab/indent size: 4 (Spaces)
-- Usage:           SELECT * FROM sys2.objects_data_spaces('<schema>.<table>')                  
-- Notes:           Display in which partition an object (table or index) resides.
--                  If you pass a NULL value as parameter, you'll get data for ALL tables.
--
-- 					Enable SQLCMD mode to execute this script
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Version History
--
-- 2.1              Added information regarding the data space in which LOB data is stored
-- 2.2              Added "space_used" and "alloc_unit_type_desc" columns
-- 2.3              Minimum version required: SQL Server 2008. Added information on partition boundaries
-- 2.4				Added check for correct SQL Server version and for SQLCMD usage
------------------------------------------------------------------------
:setvar SQLCMDMode "On"
go

if ( '$(SQLCMDMode)' = '$' + '(SQLCMDMode)' )
    raiserror ('This script must be run in SQLCMD mode.', 20, 1) with log;
go

:on error exit
go

declare @version_string varchar(100) = cast(serverproperty('ProductVersion') as varchar(100));
declare @major int = cast(substring(@version_string, 1, charindex('.', @version_string) - 1) as int);

if ( @major < 10 )
    begin
        raiserror('This script need SQL Server 2008 or higher to be executed', 20, 1) with log;
    end;
go

if not exists ( select * from [sys].[schemas] [s] where [s].[name] = 'sys2' )
    exec [sp_executesql] N'CREATE SCHEMA sys2';
go
    
if ( object_id('sys2.objects_data_spaces', 'IF') is not null )
    drop function [sys2].[objects_data_spaces];
go

create function [sys2].[objects_data_spaces] ( @tablename sysname )
returns table
as
return
    select top ( 2147483647 )
            [o].[object_id] ,
            [schema_name] = [s].[name] ,
            [object_name] = [o].[name] ,
            [object_type] = [o].[type] ,
            [object_type_desc] = [o].[type_desc] ,
            [index_name] = [i].[name] ,
            [index_type] = [i].[type] ,
            [index_type_desc] = [i].[type_desc] ,
            [alloc_unit_type_desc] = [au].[type_desc] ,
            [p].[partition_number] ,
            [p].[rows] ,
            [space_used_in_kb] = ( [au].[used_pages] * 8.0 ) ,
            [space_used_in_mb] = ( [au].[used_pages] * 8.0 / 1024.0 ) ,
            [p].[data_compression] ,
            [p].[data_compression_desc] ,
            [data_space_name] = [ds].[name] ,
            [data_space_type] = [ds].[type] ,
            [data_space_type_desc] = [ds].[type_desc] ,
            [filegroup_name] = [f].[name] ,
            [f].[is_read_only] ,
            [lob_data_space] = [lobds].[name] ,
            [pf].[fanout] ,
            [range_type] = case [pf].[boundary_value_on_right]
                           when 1 then 'RIGHT'
                           when 0 then 'LEFT'
                           else null
                         end ,
            [boundary_value] = [prv].[value]
    from    
		[sys].[partitions] [p]
	inner join 
		[sys].[indexes] [i] on [p].[object_id] = [i].[object_id] and [p].[index_id] = [i].[index_id]
    inner join 
		[sys].[objects] [o] on [i].[object_id] = [o].[object_id]
    inner join 
		[sys].[schemas] [s] on [o].[schema_id] = [s].[schema_id]
    inner join 
		[sys].[data_spaces] [ds] on [i].[data_space_id] = [ds].[data_space_id]
    left join 
		[sys].[partition_schemes] [ps] on [i].[data_space_id] = [ps].[data_space_id]
    left join 
		[sys].[partition_functions] [pf] on [ps].[function_id] = [pf].[function_id]
    left join 
		[sys].[partition_range_values] [prv] on [prv].[function_id] = [ps].[function_id] and [p].[partition_number] = [prv].[boundary_id]
    left join 
		[sys].[destination_data_spaces] [dds] on [dds].[partition_scheme_id] = [ps].[data_space_id] and [p].[partition_number] = [dds].[destination_id]
	inner join 
		[sys].[filegroups] [f] on [f].[data_space_id] = case when [ds].[type] <> 'PS' then [ds].[data_space_id] else [dds].[data_space_id] end
	left join 
		[sys].[tables] [t] on [o].[object_id] = [t].[object_id]
    left join 
		[sys].[data_spaces] [lobds] on [t].[lob_data_space_id] = [lobds].[data_space_id]
    inner join 
		[sys].[allocation_units] [au] on [p].[partition_id] = [au].[container_id]
    where   
		( [p].[object_id] = object_id(@tablename) or @tablename is null )
	and 
		[o].[type] in ( 'U', 'V' )
    order by 
		[o].[name];
go
