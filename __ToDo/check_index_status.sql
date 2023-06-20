declare @dbid int
declare @objectid int

set @dbid = db_id('GDODispensa_EURO')
set @objectid = object_id('[dbo].[Bolle_Stor_Righe]')

select * from sys.dm_db_index_physical_stats(@dbid, @objectid, NULL, NULL, 'SAMPLED')