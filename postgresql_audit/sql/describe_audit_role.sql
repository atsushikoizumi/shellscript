/*SQL13*/ 
select 
    rolname,
    rolconfig 
from pg_roles 
where rolcanlogin ='t' 
and rolname !='rdsadmin';