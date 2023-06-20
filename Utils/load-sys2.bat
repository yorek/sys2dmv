@set sys2path=Z:\Work\SQL Scripts\sys2
@set targetserver=localhost
@set targetdb=AdventureWorks2012

sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.buffer_cache_usage.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.databases_files.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.database_backup_info.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.indexes.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.indexes_operational_stats.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.indexes_per_table.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.indexes_physical_stats.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.indexes_size.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.indexes_usage_stats.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.logs_usage.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.missing_indexes.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.objects_data_spaces.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.objects_dependencies.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.objects_partition_ranges.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.plan_cache_size.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.query_memory_grants.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.query_stats.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.stats.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.stp_get_databases_space_used_info.sql"
sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%\sys2.tables_columns.sql"

pause