/*SQL14*/
SELECT r.rolname AS "RoleName",
  n.nspname AS "Schema",
  c.relname AS "Table",
  case WHEN c.relkind = 'r' THEN 'Table'
     WHEN c.relkind = 'v' THEN 'View'
     WHEN c.relkind = 'S' THEN 'Sequence'
     WHEN c.relkind = 'm' THEN 'Materialized View'
     WHEN c.relkind = 'p' THEN 'Partitioned Table'
     WHEN c.relkind = 'f' THEN 'Foreign Table'
     WHEN c.relkind = 't' THEN 'TOAST Table'
     WHEN c.relkind = 'I' THEN 'Partitioned Index'
     WHEN c.relkind = 'c' THEN 'Composite Type'
     END AS "Type",
  case WHEN has_table_privilege(r.oid, c.oid, 'SELECT')
     AND  has_table_privilege(r.oid, c.oid, 'INSERT')
     AND  has_table_privilege(r.oid, c.oid, 'UPDATE')
     AND  has_table_privilege(r.oid, c.oid, 'DELETE')
     AND  has_table_privilege(r.oid, c.oid, 'TRUNCATE')
     AND  has_table_privilege(r.oid, c.oid, 'REFERENCES')
     AND  has_table_privilege(r.oid, c.oid, 'TRIGGER')
     THEN 1
     ELSE 0
     END AS "ALL",
  case WHEN has_table_privilege(r.oid, c.oid, 'SELECT') THEN 1 ELSE 0 END AS "SEL",
  case WHEN has_table_privilege(r.oid, c.oid, 'INSERT') THEN 1 ELSE 0 END AS "INS",
  case WHEN has_table_privilege(r.oid, c.oid, 'UPDATE') THEN 1 ELSE 0 END AS "UPD",
  case WHEN has_table_privilege(r.oid, c.oid, 'DELETE') THEN 1 ELSE 0 END AS "DEL",
  case WHEN has_table_privilege(r.oid, c.oid, 'TRUNCATE') THEN 1 ELSE 0 END AS "TRU",
  case WHEN has_table_privilege(r.oid, c.oid, 'REFERENCES') THEN 1 ELSE 0 END AS "REF",
  case WHEN has_table_privilege(r.oid, c.oid, 'TRIGGER') THEN 1 ELSE 0 END AS "TRI"
FROM pg_roles r, pg_class c, pg_namespace n
WHERE c.relnamespace = n.oid
AND r.rolname = 'rds_pgaudit'  /* オブジェクト監査実行ロールを指定 */
AND n.nspname NOT IN ('pg_toast','pg_catalog','information_schema')  /* 監査対象外のスキーマ名を指定 */
AND (has_table_privilege(r.oid, c.oid, 'SELECT')
  or has_table_privilege(r.oid, c.oid, 'UPDATE')
  or has_table_privilege(r.oid, c.oid, 'DELETE')
  or has_table_privilege(r.oid, c.oid, 'TRUNCATE')
  or has_table_privilege(r.oid, c.oid, 'REFERENCES')
  or has_table_privilege(r.oid, c.oid, 'TRIGGER')
  )
ORDER BY "RoleName","Schema","Table","Type"
;