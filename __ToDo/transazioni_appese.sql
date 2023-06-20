
select 
	st.session_id,
	hostname = cast(p.hostname as varchar(20)),
	program_name = cast(p.program_name as varchar(20)),
	loginname = cast(p.loginame as varchar(20)),
	at.transaction_begin_time,
	p.last_batch
from 
	sys.dm_tran_session_transactions st
inner join
	sys.dm_tran_active_transactions at on st.transaction_id = at.transaction_id
inner join
	sys.sysprocesses p on st.session_id = p.spid
outer apply
	sys.dm_exec_sql_text(p.sql_handle) est
where 
	is_user_transaction = 1
and
	datediff(minute, transaction_begin_time, getdate()) > 10

