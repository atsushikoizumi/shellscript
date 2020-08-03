# RDS Oracle用 監査設定用スクリプトの使用方法

# スクリプト

| スクリプト名 | 説明 |
| ------------- | ------------- |
| audit_oracle_ALL.sh | 全操作の監査設定を行うスクリプト |
| audit_oracle_Describe.sh | 査設定の確認用スクリプト |
| connection.env  | 接続情報を保持 |
| noaudit_oracle_ALL.sh | 全操作の監査設定解除を行うスクリプト |
| oracle_audit.log | ログファイル |

# 使用方法
# 01. 接続情報の事前入力
connection.env  に直接接続情報を入力しておくと、スクリプト実行時に接続情報の入力は求められません。


# 02. 監査設定の実行
audit_oracle_ALL.sh を実行すると監査設定が行えます。<br>
結果は log/audit_oracle_ALL_YYYYMMDDHHMISS.log に出力されます。<br>
本スクリプトによる具体的な監査対象操作内容は以下です。

  1. 全ユーザー
  ・接続操作　ログイン/ログアウト<br>
  ・ユーザー操作　作成／更新／削除／権限<br>
  ・DDL操作　作成／更新／削除／権限<br>

  2. SYS,RDSADMIN を除くアカウントステータスが有効なユーザー全て<br>
  ・データ抽出操作 Exp,Imp (EXECUTE PROCEDURE)<br>
  ・監査テーブルへの Select, Update, Insert, Delete<br>


# 03. 監査設定内容の確認
describe_audit.sh を実行すると、監査設定が確認できます。<br>
結果は oracle_audit.log に出力されます。

# 04. 監査設定解除の実行
noaudit_oracle_ALL.sh を実行すると監査設定の解除が行えます。<br>
結果は log/noaudit_oracle_ALL_YYYYMMDDHHMISS.log に出力されます。<br>
本スクリプトによる具体的な監査設定解除対象は以下です。<br>
なお、監査設定解除の対象は監査設定用スクリプトによって監査設定したものに限りません。<br>

  1. 全操作
  　全ユーザの監査設定（dba_stmt_audit_optsビューから対象を抽出）

# 05. error 発生時の対応について
正常終了しない場合、ログファイルにエラー内容を出力します。<br>
以下、失敗例とエラー原因箇所の特定方法を記載します。<br>

ex) bash command failed.<br>

2020-06-29 18:29:31 audit_DML_users   : bash command failed.<br>

シェルスクリプトの内容に正常終了しないコマンドが存在します。<br>
bin\functions.sh の function: audit_DML_users に問題があります。<br>

ex) SP2-XXXX:<br>

2020-06-29 19:37:44 audit_DDL         : failed.<br>
--------- message ---------<br>
SP2-0734: unknown command beginning "udit SESSI..." - rest of line ignored.<br>
----------- end -----------<br>

Sqlplus のコマンドの構文に誤りがあります。<br>
bin\functions.sh の function: audit_DDL に問題があります。<br>


ex) ORA-XXXXX<br>

2020-06-29 19:42:35 audit_DML_users   : failed.<br>
--------- message ---------<br>
select SERNAME from dba_users where ACCOUNT_STATUS='OPEN' and USERNAME not in('SYS','RDSADMIN')<br>
    *<br>
ERROR at line 1:<br>
ORA-00904: "SERNAME": invalid identifier<br>
----------- end -----------<br>

SQL文 の中に誤りがあります。<br>
bin\functions.sh の function: audit_DML_users に問題があります。
