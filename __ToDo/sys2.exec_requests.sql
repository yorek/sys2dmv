create view sys2.exec_requests
as
select 
	r.session_id,
	r.blocking_session_id,
	r.database_id,
	database_name = db_name(r.database_id),
	s.host_name,
	s.program_name,
	r.command,
	s.login_name,
	s.status,
	r.total_elapsed_time,
	r.wait_time,
	r.last_wait_type,
	r.sql_handle,
    r.plan_handle,
    s.is_user_process
from 
	sys.dm_exec_requests r 
inner join
	sys.dm_exec_sessions s on r.session_id = s.session_id
