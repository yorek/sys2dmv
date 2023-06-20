select
	t.*
from
	sys.dm_exec_sessions s
inner join
	sys.dm_os_waiting_tasks t on s.session_id = t.session_id
where 
	is_user_process = 1 and program_name like 'SSIS%'
	
select
	r.*
from
	sys.dm_exec_sessions s
inner join
	sys.dm_exec_requests r on s.session_id = r.session_id
where 
	is_user_process = 1 and program_name like 'SSIS%'
	
select
	t.*
from
	sys.dm_exec_sessions s
inner join
	sys.dm_os_tasks t on s.session_id = t.session_id
where 
	is_user_process = 1 and program_name like 'SSIS%'
		