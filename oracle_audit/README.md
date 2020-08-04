# RDS Oracle用 監査設定用スクリプトの使用方法

# スクリプト

| スクリプト名 | 説明 |
| ------------- | ------------- |
| audit_ddl.sh | DDLの監査設定を登録 |
| audit_object.sh | オブジェクトのDML操作に対する監査設定を登録 |
| audit_user.sh | ユーザのDML操作に対する監査設定を登録 |
| describe_audit.sh | 監査設定を確認 |
| noaudit_ddl.sh | DDLの監査設定を解除 |
| noaudit_object.sh | オブジェクトのDML操作に対する監査設定を解除 |
| noaudit_user.sh | ユーザのDML操作に対する監査設定を解除 |

# 使用方法
# 01. 接続情報の事前入力
connection.env  に直接接続情報を入力しておくと、スクリプト実行時に接続情報の入力は求められません。


# 02. ログ出力
log フォルダに各種ログファイルを出力しています。<br>
 |-- audit_ddl.log
 |-- audit_object.log
 |-- audit_user.log
 |-- describe_audit.log
 |-- noaudit_ddl.log
 |-- noaudit_object.log
 |-- noaudit_user.log

# 03. error 発生時
正常終了しない場合、ログファイルにエラー内容を出力します。<br>

ex) sql ファイルが存在しない<br>

2020-08-05 04:32:50 runsql : failed.<br>
2020-08-05 04:32:50 runsql : file does not exist or is empty. /home/emily/work/20200803/sql/01_connection.sql<br>

ex) ORA-xxx<br>

2020-08-05 04:41:22 runsql : failed.<br>
--------- message ---------<br>
[90_get_info_audit_DDL.sql]<br>
select ser_name, audit_option, success, failure from sys.dba_stmt_audit_opts order by user_name,audit_option bin env log main sql ERROR at line 1: ORA-00904: "SER_NAME":<br> invalid identifier<br>
----------- end -----------<br>

ex) SP2-xxx<br>
2020-08-05 04:43:20 runsql : failed.<br>
--------- message ---------<br>
[02_audit_ddl.sql]<br>
SP2-0734: unknown command beginning "audi SESSI..." - rest of line ignored.<br>
----------- end -----------

