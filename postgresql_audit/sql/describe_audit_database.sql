/*SQL12*/
select
    db.datname as "database",
    dbrl.setconfig 
from pg_db_role_setting dbrl 
left outer join pg_database db on dbrl.setdatabase=db.oid 
where dbrl.setrole=0 
and db.datname not in ('rdsadmin');