set head off
set termout off
set feedback off
select USERNAME from dba_users where ACCOUNT_STATUS='OPEN' and USERNAME not in('SYS','RDSADMIN');
exit