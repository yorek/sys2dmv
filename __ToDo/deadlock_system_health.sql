with cte as
(
select 
      CAST(xet.target_data as xml) xd from sys.dm_xe_session_targets xet 
join sys.dm_xe_sessions xe 
on (xe.address = xet.event_session_address) 
where xe.name = 'system_health'
)
select
      T.C.value('./@timestamp', 'datetime2'),
      CAST(
                  REPLACE(
                        REPLACE(T.C.value('(data/value)[1]', 'varchar(max)'), 
                        '<victim-list>', '<deadlock><victim-list>'),
                  '<process-list>','</victim-list><process-list>')
            as xml) as DeadlockGraph

from
      cte
cross apply
      xd.nodes('//event[@name=''xml_deadlock_report'']') T(C)
