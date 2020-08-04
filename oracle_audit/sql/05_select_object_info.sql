set termout off
set feedback off
set pagesize 0
select owner || ',' || object_name from sys.dba_obj_audit_opts order by owner,object_name;
exit