# PostgreSQL shellscript
Aurora PostgreSQL 11 向けの監査設定スクリプトです。

# directory 構成
|-- env
    |-- connection.env
    |-- table_list.txt
|-- function
    |-- postgresql_function.sh
|-- main
    |-- audit_database.sh
    |-- audit_deescribe.sh
    |-- audit_role.sh
    |-- audit_table.sh
|-- sql
    |-- describe_audit_database.sql
    |-- describe_audit_role.sql
    |-- describe_audit_table.sql

# 使用方法
1. connection.env の使い方
接続情報を入力

2. table_list.txt の使い方
監査対象のテーブルを入力

3. audit_deescribe.sh の使い方
監査設定を確認
./main/audit_deescribe.sh

4. audit_database.sh の使い方
データベースレベル監査設定を実行
./main/audit_database.sh 0

データベースレベル監査設定を解除
./main/audit_database.sh 1

5. audit_role.sh の使い方
ロールレベル監査設定を実行
./main/audit_role.sh 0

ロールレベル監査設定を解除
./main/audit_role.sh 1

6. audit_table.sh の使い方
オブジェクト監査設定を実行
./main/audit_table.sh 0

オブジェクト監査設定を解除
./main/audit_table.sh 1
