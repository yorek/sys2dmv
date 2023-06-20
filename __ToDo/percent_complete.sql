select 
	percent_complete,
	total_elapsed_time_in_minutes = r.total_elapsed_time / 1000. / 60.,
	estimated_completion_time_in_minutes = estimated_completion_time / 1000. / 60.,
	qt.text,
	*
from 
	sys.dm_exec_requests r
inner join
	sys.dm_exec_sessions s on r.session_id = s.session_id
cross apply
	sys.dm_exec_sql_text([sql_handle]) qt
where
	s.is_user_process <> 0
and
	s.session_id <> @@spid

