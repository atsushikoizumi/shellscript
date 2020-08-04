set head off
set termout off
set feedback off
set pagesize 0
select USERNAME from dba_users where ACCOUNT_STATUS='OPEN' and USERNAME not in('SYS','RDSADMIN') order by USERNAME;
exit