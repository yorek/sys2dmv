USE [master]
GO
/****** Object:  StoredProcedure [sys2].[stp_report_blocked_tasks]    Script Date: 07/02/2009 16:36:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [sys2].[stp_report_blocked_tasks]
@timeLimitInSec int = 10000,
@sendMail bit = 0
as
set nocount on;

with blocking_hierarchy (head_wait_resource, session_id, blocking_session_id, tree_level, request_id, transaction_id, 
	status, sql_handle, plan_handle, statement_start_offset, statement_end_offset, wait_type, wait_time, wait_resource, 
	program_name, seconds_active_idle, open_transaction_count, transaction_isolation_level) 
as 
(
	select 
		(select min(wait_resource) from sys.dm_exec_requests where blocking_session_id = s.session_id) as head_wait_resource, 
		s.session_id, 
		convert(smallint, NULL), 
		convert(int, 0), 
		r.request_id, 
		coalesce(r.transaction_id, st.transaction_id), 
		isnull(r.status, 'idle'), 
		r.sql_handle, 
		r.plan_handle, 
		r.statement_start_offset, 
		r.statement_end_offset, 
		r.wait_type, 
		r.wait_time, 
		r.wait_resource, 
		s.program_name,
		case when r.request_id is null then datediff(ss, s.last_request_end_time, getdate()) else datediff(ss, r.start_time, getdate()) end,
		convert(int, p.open_tran),
		coalesce(r.transaction_isolation_level, s.transaction_isolation_level)
	from sys.dm_exec_sessions s
		join sys.sysprocesses p on s.session_id = p.spid
		left join sys.dm_exec_requests r on s.session_id = r.session_id
		left join sys.dm_tran_session_transactions st on s.session_id = st.session_id
	where s.session_id in (select blocking_session_id from sys.dm_exec_requests) 
		and isnull(r.blocking_session_id, 0) = 0

	union all

	select b.head_wait_resource, 
		r.session_id, 
		r.blocking_session_id, 
		tree_level + 1, 
		r.request_id, 
		r.transaction_id, 
		r.status, 
		r.sql_handle, 
		r.plan_handle, 
		r.statement_start_offset, 
		r.statement_end_offset, 
		r.wait_type, 
		r.wait_time, 
		r.wait_resource, 
		NULL,
		NULL,
		r.open_transaction_count,
		r.transaction_isolation_level
	from sys.dm_exec_requests r
		join blocking_hierarchy b on r.blocking_session_id = b.session_id
)
select b.head_wait_resource,
	b.session_id, 
	b.request_id, 
	b.blocking_session_id, 
	b.program_name, 
	b.tree_level, 
	--case when LEN(qt.query_text) < 2048 then qt.query_text else LEFT(qt.query_text, 2048) + N'...' end as query_text,
	--master.dbo.fn_varbintohexstr(b.sql_handle) as sql_handle, 
	--master.dbo.fn_varbintohexstr(b.plan_handle) as plan_handle, 
	--b.statement_start_offset, 
	--b.statement_end_offset, 
	b.status as session_or_request_status, 
	b.wait_type, 
	b.wait_time, 
	b.wait_resource, 
	b.transaction_id, 
	b.transaction_isolation_level,
	b.open_transaction_count,
	b.seconds_active_idle,
	t.name as transaction_name, 
	t.transaction_begin_time, 
	t.transaction_type, 
	t.transaction_state, 
	t.dtc_state, 
	t.dtc_isolation_level,
	st.enlist_count, 
	st.is_user_transaction, 
	st.is_local, 
	st.is_enlisted, 
	st.is_bound
into
	#b
from blocking_hierarchy b
	left join sys.dm_tran_session_transactions st on st.transaction_id = b.transaction_id and st.session_id = b.session_id
	left join sys.dm_tran_active_transactions t on t.transaction_id = b.transaction_id
	--outer apply msdb.MS_PerfDashboard.fn_QueryTextFromHandle(b.sql_handle, b.statement_start_offset, b.statement_end_offset) as qt
;

select
	*
into
	#b2
from
	#b
where
	wait_time > @timeLimitInSec
;

if (@sendMail <> 0)
begin
	declare @bc int;
	select @bc = count(*) from #b2;
	set @bc = isnull(@bc, 0)

	if (@bc > 0)
	begin
		PRINT 'Rilevati ' + CAST(@bc as varchar(9)) + ' processi bloccati';
		
		DECLARE @tableHTML  NVARCHAR(MAX) ;

		SET @tableHTML =
			N'<H1>Blocked Tasks</H1><font size=1>' +
			N'<table border="1">' +
			N'<tr>'+
			N'<th>head_wait_resource</th>'+
			N'<th>session_id</th>' +
			N'<th>request_id</th>' +
			N'<th>blocking_session_id</th>' +
			N'<th>program_name</th>' +
			N'<th>tree_level</th>' +
			--N'<th>query_text</th>' +
			--N'<th>sql_handle</th>' +
			--N'<th>plan_handle</th>' +
			--N'<th>statement_start_offset</th>' +
			--N'<th>statement_end_offset</th>' +
			N'<th>session_or_request_status</th>' +
			N'<th>wait_type</th>' +
			N'<th>wait_time</th>' +
			N'<th>wait_resource</th>' +
			N'<th>transaction_id</th>' +
			N'<th>transaction_isolation_level</th>' +
			N'<th>open_transaction_count</th>' +
			N'<th>seconds_active_idle</th>' +
			N'<th>transaction_name</th>' +
			N'<th>transaction_begin_time</th>' +
			N'<th>transaction_type</th>' +
			N'<th>transaction_state</th>' +
			N'<th>dtc_state</th>' +
			N'<th>dtc_isolation_level</th>' +	
			N'<th>enlist_count</th>' +	
			N'<th>is_user_transaction</th>' +	
			N'<th>is_local</th>' +	
			N'<th>is_enlisted</th>' +	
			N'<th>is_bound</th>' +
			CAST ( ( 

			select 
				td = isnull(head_wait_resource,''), '',
				td = isnull(session_id,''), '',
				td = isnull(request_id,''), '',
				td = isnull(blocking_session_id,''), '',
				td = isnull(program_name,''), '', 
				td = isnull(tree_level,''), '',
				--td = isnull(query_text,''), '',
				--td = isnull(sql_handle,''), '',
				--td = isnull(plan_handle,''), '',
				--td = isnull(statement_start_offset,''), '',
				--td = isnull(statement_end_offset,''), '',
				td = isnull(session_or_request_status,''), '',
				td = isnull(wait_type,''), '',
				td = isnull(wait_time,''), '',
				td = isnull(wait_resource,''), '', 
				td = isnull(transaction_id,''), '',
				td = isnull(transaction_isolation_level,''), '',
				td = isnull(open_transaction_count,''), '',
				td = isnull(seconds_active_idle,''), '',
				td = isnull(transaction_name,''), '',
				td = isnull(transaction_begin_time,''), '',
				td = isnull(transaction_type,''), '',
				td = isnull(transaction_state,''), '',
				td = isnull(dtc_state,''), '',
				td = isnull(dtc_isolation_level,''), '',
				td = isnull(enlist_count,''), '',
				td = isnull(is_user_transaction,''), '',
				td = isnull(is_local,''), '',
				td = isnull(is_enlisted,''), '',
				td = isnull(is_bound,''), ''
			FROM
				#b
			FOR 
				XML PATH('tr'), TYPE 
					
			) AS NVARCHAR(MAX) ) +
			N'</table></font>' ;

			--SELECT @tableHTML

			DECLARE @recipients NVARCHAR(MAX)
			select @recipients = email_address from msdb.dbo.sysoperators where name = 'IT'

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'Default',
				@recipients = @recipients,
				@body = @tableHTML,
				@body_format = 'HTML',
				@subject = 'Task bloccati'
	end

	drop table #b
	drop table #b2
end
else
begin

	select * from #b2

end	



