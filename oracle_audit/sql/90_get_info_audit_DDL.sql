set trimspool on
set line 10000
set pagesize 10000
column audit_option format a30
column user_name    format a30
column SUCCESS      format a12
column FAILURE      format a12
spool '&1' append
select user_name, audit_option, success, failure from sys.dba_stmt_audit_opts order by user_name,audit_option;
spool off
exit