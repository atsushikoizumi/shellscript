set trimspool on
set line 10000
set pagesize 10000
column owner       format a20
column object_name format a30
spool '&1' append
select owner, object_name, aud as "audit",sel as "select", upd as "update", ins as "insert", del as "delete" from sys.dba_obj_audit_opts order by owner,object_name;
spool off
exit