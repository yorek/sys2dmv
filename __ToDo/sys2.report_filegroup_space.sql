alter procedure sys2.report_filegroup_space
as
set nocount on;

create table #r
(
	[database_name] sysname NULL,
	[filegroup_name] sysname NOT NULL,
	[file_name] sysname NOT NULL,
	[space_used_mb] numeric(16, 6) NULL,
	[space_reserved_mb] numeric(16, 6) NULL,
	[space_reservable_mb] numeric(16, 6) NULL,
	[space_reserved_percent_used] numeric(38, 22) NULL,
	[space_reservable_percent_used] numeric(38, 22) NULL
)

exec sp_MSforeachdb
'use [?];
with cte as
(
select
	[database_name] = ''?'',
	[filegroup_name] = ds.name,
	[file_name] = df.name,
	space_used_mb = FILEPROPERTY(df.name, ''SpaceUsed'') * 8 / 1024., 
	space_reserved_mb = [size] * 8 / 1024., 
	space_reservable_mb = case when max_size = -1 then null else max_size * 8 / 1024. end
from 
	[?].sys.database_files df
inner join
	[?].sys.data_spaces ds on df.data_space_id = ds.data_space_id
)
insert into
	#r
select
	*,
	space_reserved_percent_used = space_used_mb / space_reserved_mb,
	space_reservable_percent_used = space_used_mb / space_reservable_mb
from
	cte';

select * from #r order by database_name, file_name;

drop table #r;