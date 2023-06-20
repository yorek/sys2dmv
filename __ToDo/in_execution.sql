select
	*
from	
	sys.dm_os_waiting_tasks ws
inner join
	sys.dm_exec_requests r on r.session_id = ws.session_id
cross apply
	sys.dm_exec_sql_text(r.plan_handle) sq
cross apply
	sys.dm_exec_query_plan(r.plan_handle) qp
where
	ws.session_id = 96
