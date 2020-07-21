Aurora PostgreSQL 11 向けの監査設定スクリプトです。

# directory 構成
|-- env<br>
|-- |-- connection.env<br>
|-- |-- table_list.txt<br>
|-- function<br>
|-- |-- postgresql_function.sh<br>
|-- main<br>
|-- |-- audit_database.sh<br>
|-- |-- audit_deescribe.sh<br>
|-- |-- audit_role.sh<br>
|-- |-- audit_table.sh<br>
|-- sql<br>
|-- |-- describe_audit_database.sql<br>
|-- |-- describe_audit_role.sql<br>
|-- |-- describe_audit_table.sql<br>

# 使用方法
1. connection.env の使い方<br>
接続情報を入力<br>

2. table_list.txt の使い方<br>
監査対象のテーブルを入力<br>

3. audit_deescribe.sh の使い方<br>
監査設定を確認<br>
./main/audit_deescribe.sh<br>

4. audit_database.sh の使い方<br>
データベースレベル監査設定を実行<br>
./main/audit_database.sh 0<br>

データベースレベル監査設定を解除<br>
./main/audit_database.sh 1<br>

5. audit_role.sh の使い方<br>
ロールレベル監査設定を実行<br>
./main/audit_role.sh 0<br>

ロールレベル監査設定を解除<br>
./main/audit_role.sh 1<br>

6. audit_table.sh の使い方<br>
オブジェクト監査設定を実行<br>
./main/audit_table.sh 0<br>

オブジェクト監査設定を解除<br>
./main/audit_table.sh 1<br>
