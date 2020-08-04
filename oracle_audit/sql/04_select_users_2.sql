set termout off
set feedback off
set pagesize 0
select user_name || ',' || audit_option from sys.dba_stmt_audit_opts order by user_name, audit_option;
exit