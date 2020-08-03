set trimspool on
set termout off
set line 1000
set pagesize 1000
column audit_option format a30
column user_name    format a30
column SUCCESS      format a12
column FAILURE      format a12
spool '&1' append
select systimestamp from dual;
select user_name, audit_option, success, failure from sys.dba_stmt_audit_opts order by 1,2;
spool off
exit