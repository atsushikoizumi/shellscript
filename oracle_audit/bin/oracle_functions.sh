#!/bin/bash
#
# [Description]
# AUDIT Functions For RDS Oracle
#
# [Functions]
#
#  push_message             メッセージ出力
#  runsql                   SQL実行とエラーハンドリング
#  check_connection         接続情報のチェック
#  audit_DDL                DDLの監査設定
#  audit_DML                DMLの監査設定
#  get_info_audit_DDL       DDLの監査設定を確認
#  get_info_audit_DML       DMLの監査設定を確認
#  noaudit_operation_ALL    操作・ユーザに対する監査設定をすべて解除
#  noaudit_object_ALL       スキーマ・オブジェクトに対する監査設定をすべて解除
#

#
# push_message
#
function push_message() {

var=$1
msg=$2

case "$var" in
    "1" ) 
        date "+%Y-%m-%d %H:%M:%S ${FUNCNAME[1]} : ${msg}"  >> ${LOG_FILE}
    ;;

    "2" ) 
        echo ${msg} >> ${LOG_FILE}
    ;;

    "3" ) 
        echo "${FUNCNAME[1]} : ${msg}"
    ;;
esac
}

#
# runsql
#
function runsql () {

var=$1
sql=$2
arg=$3

# run sql
case "$var" in
    "1" ) 
        TRACE_SQL=`sqlplus -S -L ${DB_USER}/${PASSWORD}@${ENDPOINT}:${PORT}/${DATABASE} @${SQL_PATH}/${sql}`

        # error handling
        if [ $? != 0 ] || [ "`echo ${TRACE_SQL} | grep -e "ORA-" -e "SP2-" -e "error"`" ]; then
        push_message 1 "failed."
        push_message 2 "--------- message ---------"
        push_message 2 "[${sql}]"
        push_message 2 "${TRACE_SQL}"
        push_message 2 "----------- end -----------"
        push_message 3 "failed."
        exit
        fi
    ;;

    "2" ) 
        TRACE_SQL=`echo -e "${sql}" | sqlplus -S -L ${DB_USER}/${PASSWORD}@${ENDPOINT}:${PORT}/${DATABASE}`

        # error handling
        if [ $? != 0 ] || [ "`echo ${TRACE_SQL} | grep -e "ORA-" -e "SP2-" -e "error"`" ]; then
        push_message 1 "failed."
        push_message 2 "--------- message ---------"
        push_message 2 "[${sql}]"
        push_message 2 "${TRACE_SQL}"
        push_message 2 "----------- end -----------"
        push_message 3 "failed."
        exit
        fi
    ;;

    "3" ) 
        RACE_SQL=`sqlplus -S -L ${DB_USER}/${PASSWORD}@${ENDPOINT}:${PORT}/${DATABASE} @${SQL_PATH}/${sql} "${arg}"`

        # error handling
        if [ $? != 0 ] || [ "`echo ${TRACE_SQL} | grep -e "ORA-" -e "SP2-" -e "error"`" ]; then
        push_message 1 "failed."
        push_message 2 "--------- message ---------"
        push_message 2 "[${sql}]"
        push_message 2 "${TRACE_SQL}"
        push_message 2 "----------- end -----------"
        push_message 3 "failed."
        exit
        fi
    ;;
esac

}

#
# check_connection
#
function check_connection() {

    # function start
    push_message 1 "start."

    echo ""
    echo "Please Set Connection Info."
    echo ""

    # Endpoint
    if [ -n "${ENDPOINT}" ]; then
        echo "ENDPOINT: ${ENDPOINT}"
    else
        echo -n "ENDPOINT: "
        read ENDPOINT
    fi

    # Port
    if [ -n "${PORT}" ]; then
        echo "PORT    : ${PORT}"
    else
        echo -n "PORT    : "
        read PORT
    fi

    # DataBase
    if [ -n "${DATABASE}" ]; then
        echo "DATABASE: ${DATABASE}"
    else
        echo -n "DATABASE: "
        read DATABASE
    fi

    # DB User
    if [ -n "${DB_USER}" ]; then
        echo "DB_USER : ${DB_USER}"
    else
        echo -n "DB_USER : "
        read DB_USER
    fi

    # Password
    export PGPASSWORD=${PASSWORD}
    if [ -n "${PGPASSWORD}" ]; then
        echo "PASSWORD: xxxxxxxxxx"
    else
        echo -n "PASSWORD: "
        read PASSWORD
        export PGPASSWORD=${PASSWORD}
    fi

    # push parameters into log file
    push_message 1 "set connection info"
    push_message 1 "ENDPOINT  = ${ENDPOINT}"
    push_message 1 "PORT      = ${PORT}"
    push_message 1 "DATABASE  = ${DATABASE}"
    push_message 1 "DB_USER   = ${DB_USER}"
    push_message 1 "PGPASSWORD= xxxxxxxxxx"

    # check connection
    runsql 1 01_connection.sql

    # function end
    push_message 1 "end."

}

#
# audit_DDL
#
function audit_DDL () {

    # function start
    push_message 1 "start."

    # audit_DDL
    runsql 1 02_audit_ddl.sql

    # function end
    push_message 1 "end."

}


#
# audit_DML
#
function audit_DML () {

    # function start
    push_message 1 "start."

    # select users
    SQL=`cat ${SQL_PATH}/03_select_users_1.sql`
    runsql 2 "${SQL}"

    # store user list in array
    AUDIT_DML_USERS_ARRAY=(`echo ${TRACE_SQL}`)

    # push log
    push_message 1 "user count ${#AUDIT_DML_USERS_ARRAY[@]}"
    push_message 2 "$(echo "${AUDIT_DML_USERS_ARRAY[@]}")"

    # make audit_dml_SQL
    for user in ${AUDIT_DML_USERS_ARRAY[@]}
    do
        SQL="${SQL}audit SELECT TABLE,UPDATE TABLE,INSERT TABLE,DELETE TABLE,EXECUTE PROCEDURE by ${user}"
    done
    SQL="${SQL}exit"

    # runsql
    runsql 2 "${SQL}"

    # function start
    push_message 1 "end."

}


#
# get_audit_info_DDL
#
function get_info_audit_DDL () {

    # function start
    push_message 1 "start."

    # get_audit_info_DDL
    runsql 3 90_get_info_audit_DDL.sql "${LOG_FILE}"

    # function start
    push_message 1 "end."

}


#
# get_info_audit_DML
#
function get_info_audit_DML () {

    # function start
    push_message 1 "start."

    # get_audit_info_DML
    runsql 3 91_get_info_audit_DML.sql "${LOG_FILE}"

    # function start
    push_message 1 "end."

}

#
# 08. noaudit_operation_ALL
#
function noaudit_operation_ALL() {

    # function start
    push_message 1 "start."

    # select users
    SQL=`cat ${SQL_PATH}/04_select_users_2.sql`
    runsql 2 "${SQL}"

    # make noaudit sql
    # control IFS (Internal Filed Separator)
    SQL=` echo "set head off"
          echo "set termout off"
          OLDIFS=$IFS
          IFS=,
          echo "${TRACE_SQL}" | while read line
          do
            AUDIT_ARRAY=($(echo "${line}"))
            if [ -n "${AUDIT_ARRAY[0]}" ]; then
                echo "noaudit ${AUDIT_ARRAY[1]} by ${AUDIT_ARRAY[0]};"
            else
                echo "noaudit ${AUDIT_ARRAY[1]};"
            fi
          done
          IFS=$OLDIFS
          echo "exit"`

    # runsql
    runsql 2 "${SQL}"

    # function start
    push_message 1 "end."

}
