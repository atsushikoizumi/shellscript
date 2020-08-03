set trimspool on
set termout off
set line 1000
set pagesize 1000
column owner       format a20
column object_name format a30
spool '&1' append
select systimestamp from dual;
select owner, object_name, aud as "audit",sel as "select", upd as "update", ins as "insert", del as "delete" from sys.dba_obj_audit_opts order by 1,2;
spool off
exit