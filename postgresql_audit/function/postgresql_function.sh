#!/bin/bash
#
# [Description]
# AUDIT Functions For Aurora PostgreSQL
#
# [Functions]
#
# 01. push_message             メッセージ出力
# 02. run_sql                  SQL 実行用ファンクション（エラーハンドリング含む）
# 03. check_connection         DB接続確認
# 04. check_extension_pgaudit  pgaudit 拡張機能を作成
# 05. create_role_rds_pgaudit  rds_pgaudit を作成
# 06. audit_database           接続先 DataBase の監査を設定
# 07. audit_role               cannnot login 以外のユーザーに対してセッション監査を設定
# 08. audit_table              table_list.txt のテーブルに対して監査設定
# 09. describe_audit_database  接続先 DataBase の監査設定を確認
# 10. describe_audit_role      各ロールの監査設定を確認
# 11. describe_audit_table     rds_pgaudit の権限を確認
# 12. noaudit_database         接続先 DataBase の監査設定を解除
# 13. noaudit_role          cannnot login 以外のユーザーに対してセッション監査設定を解除
# 14. noaudit_table            table_list.txt のテーブルに対して監査設定解除
# 15. check_role_rds_pgaudit   rds_pgaudit の設定を確認
#


#
# 01. push_message             メッセージ出力
#
function push_message() {

    # how to use
    # push_message 1 check_connection "success."
    # push_message 2 check_connection "error message."
    # push_message 3 check_connection "failed."

    var=$1
    fcn=$2
    msg=$3

    case "$var" in
        "1" ) 
            date "+%Y-%m-%d %H:%M:%S ${fcn} : ${msg}"  >> ${LOG_FILE_PATH}
        ;;

        "2" ) 
            echo ${msg} >> ${LOG_FILE_PATH}
        ;;

        "3" ) 
            echo "${fcn} : ${msg}"
        ;;
    esac
}

#
# 02. run_sql                  SQL 実行用ファンクション（エラーハンドリング含む）
#
function run_sql() {

    # get args
    function_nm=$1
    SQL=$2

    # run sql after check_connection
    #TRACE_SQL=`psql -w -h ${ENDPOINT} -U ${DB_USER} -p ${PORT} -d ${DATABASE} -c "${SQL}" 2>&1`
    TRACE_SQL=`${PSQL_CON} -A -t -c "${SQL}" 2>&1`
    ret=$?

    # error handling
    if [ "${ret}" = 0 ]; then
        # push logfile
        push_message 1 ${function_nm} "run_sql success."
    else
        # push logfile
        push_message 1 ${function_nm} "run_sql failed."
        push_message 2 ${function_nm} "--------- message ---------"
        push_message 2 ${function_nm} "${SQL}"
        push_message 2 ${function_nm} "${TRACE_SQL}"
        push_message 2 ${function_nm} "----------- end -----------"
        # push standard output
        push_message 3 ${function_nm} "run_sql failed."
        echo ""
        exit
    fi
}


#
# 03. check_connection         接続情報のチェック
#
function check_connection() {

    # function start
    push_message 1 check_connection "start."

    ### require configures
    echo ""
    echo "Please Set Connection Info."
    echo ""

    # ENDPOINT
    if [ -n "${ENDPOINT}" ]; then
        echo "ENDPOINT: ${ENDPOINT}"
    else
        echo -n "ENDPOINT: "
        read ENDPOINT
    fi

    # PORT
    if [ -n "${PORT}" ]; then
        echo "PORT    : ${PORT}"
    else
        echo -n "PORT    : "
        read PORT
    fi

    # DATABASE
    if [ -n "${DATABASE}" ]; then
        echo "DATABASE: ${DATABASE}"
    else
        echo -n "DATABASE: "
        read DATABASE
    fi

    # DB_USER
    if [ -n "${DB_USER}" ]; then
        echo "DB_USER : ${DB_USER}"
    else
        echo -n "DB_USER : "
        read DB_USER
    fi

    # PASSWORD
    export PGPASSWORD=${PASSWORD}
    if [ -n "${PGPASSWORD}" ]; then
        echo "PASSWORD: xxxxxxxxxx"
    else
        echo -n "PASSWORD: "
        read PASSWORD
        export PGPASSWORD=${PASSWORD}
    fi

    # push standard output
    echo ""

    ### Check Connection
    SQL="/*SQL01*/ select now();"
    PSQL_CON="psql -w -h ${ENDPOINT} -U ${DB_USER} -p ${PORT} -d ${DATABASE}"
    run_sql check_connection "${SQL}"

    # function end.
    push_message 3 check_connection "success."
    push_message 1 check_connection "end."
}


#
# 04. check_extension_pgaudit  pgaudit 拡張機能を作成
#
function check_extension_pgaudit() {

    # function start
    push_message 1 check_extension_pgaudit "start."

    ### make sure shared_preload_libraries
    SQL="/*SQL02*/ show shared_preload_libraries;"
    run_sql check_extension_pgaudit_1 "${SQL}"

    # make sure pgaudit installed.
    if [ "`echo ${TRACE_SQL} | grep -e "pgaudit"`" ]; then
        push_message 1 check_extension_pgaudit "pgaudit installed."
    else
        # push logfile
        push_message 1 check_extension_pgaudit "failed."
        push_message 2 check_extension_pgaudit "--------- message ---------"
        push_message 2 check_extension_pgaudit "pgaudit is not installed."
        push_message 2 check_extension_pgaudit "${TRACE_SQL}"
        push_message 2 check_extension_pgaudit "Please set shared_preload_libraries=pgaudit in parameter-group, then restart."
        push_message 2 check_extension_pgaudit "----------- end -----------"
        # push standard output
        push_message 3 check_extension_pgaudit "failed."
        echo ""
        exit
    fi

    ### make sure pgaudit in pg_extension
    SQL="/*SQL03*/ select extname from pg_extension;"
    run_sql check_extension_pgaudit_2 "${SQL}"

    # make sure pgaudit installed.
    if [ "`echo ${TRACE_SQL} | grep -e "pgaudit"`" ]; then
        push_message 1 check_extension_pgaudit "pgaudit is available."
    else
        push_message 1 check_extension_pgaudit "pgaudit is not available."
        ### create extension.
        SQL="/*SQL04*/ CREATE EXTENSION pgaudit;"
        run_sql check_extension_pgaudit_3 "${SQL}"
    fi

    # function end.
    push_message 3 check_extension_pgaudit "success"
    push_message 1 check_extension_pgaudit "end."
}


#
# 05. create_role_rds_pgaudit  rds_pgaudit を作成
#
function create_role_rds_pgaudit() {

    push_message 1 create_role_rds_pgaudit "start."
    
    ### make sure rds_pgaudit exists
    SQL="/*SQL05*/ select rolname from pg_roles where rolname='rds_pgaudit';"
    run_sql create_role_rds_pgaudit_1 "${SQL}"

    ### make sure rds_pgaudit exists
    if [ "${TRACE_SQL}" = "rds_pgaudit" ]; then
         push_message 1 create_role_rds_pgaudit "rds_pgaudit exists."
    else
        # push logfile
        push_message 1 create_role_rds_pgaudit "rds_pgaudit not exists."

        # Create role rds_pgaudit
        SQL="/*SQL06*/ CREATE ROLE rds_pgaudit;"
        run_sql create_role_rds_pgaudit_2 "${SQL}"
    fi

    ### check pgaudit.role
    SQL="/*SQL07*/ show pgaudit.role;"
    run_sql create_role_rds_pgaudit_3 "${SQL}"

    if [ "${TRACE_SQL}" = "rds_pgaudit" ]; then
        # push logfile
        push_message 1 create_role_rds_pgaudit "pgaudit.role is rds_pgaudit."
    else
        # push logfile
        push_message 1 create_role_rds_pgaudit "failed."
        push_message 2 create_role_rds_pgaudit "--------- message ---------"
        push_message 2 create_role_rds_pgaudit "pgaudit.role is not set."
        push_message 2 create_role_rds_pgaudit "Please set pgaudit.role=rds_pgaudit in parameter-group."
        push_message 2 create_role_rds_pgaudit "----------- end -----------"
        # push standard output
        push_message 3 create_role_rds_pgaudit "failed."
        echo ""
        exit
    fi

    # function end.
    push_message 3 create_role_rds_pgaudit "success."
    push_message 1 create_role_rds_pgaudit "end."
}


#
# 06. audit_database           接続先 DataBase の監査を設定
#
function audit_database() {

    push_message 1 audit_database "start."

    ### alter database
    SQL="/*SQL08*/ ALTER DATABASE ${DATABASE} set pgaudit.log='ALL';"
    run_sql audit_database "${SQL}"
    
    # function end.
    push_message 3 audit_database "success."
    push_message 1 audit_database "end."
}


#
# 07. audit_role            cannnot login 以外のユーザーに対してセッション監査を設定
#
function audit_role() {

    push_message 1 audit_role "start."

    ### Get User List
    SQL="/*SQL09*/ select rolname from pg_roles where rolcanlogin ='t' and rolname !='rdsadmin';"
    run_sql audit_role_1 "${SQL}"

    ### set array    
    USER_LIST_ARRAY=(`echo ${TRACE_SQL}`)

        # push logfile
        push_message 1 audit_role ""${#USER_LIST_ARRAY[@]}" users"
        push_message 2 audit_role "${TRACE_SQL}"
        # push standard output
        push_message 3 audit_role ""${#USER_LIST_ARRAY[@]}" users"

    ### check user count
    if [ "${#USER_LIST_ARRAY[@]}" = 0 ]; then
        # push logfile
        push_message 1 audit_role "failed."
        push_message 2 audit_role "--------- message ---------"
        push_message 1 audit_role "There is no user."
        push_message 2 audit_role "----------- end -----------"
        # push standard output
        push_message 3 audit_role "failed."
        echo ""
        exit
    fi

    for user in ${USER_LIST_ARRAY[@]}
    do
        # alter role
        SQL="/*SQL10*/ ALTER ROLE ${user} set pgaudit.log='ALL';"
        TRACE_SQL=`${PSQL_CON} -A -t -c "${SQL}" 2>&1`
        ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then
            # push logfile
            push_message 1 audit_role_2 "run_sql ${user} success."
        else
            # push logfile
            push_message 1 audit_role_2 "run_sql ${user} failed."
            push_message 2 audit_role_2 "--------- message ---------"
            push_message 2 audit_role_2 "${SQL}"
            push_message 2 audit_role_2 "${TRACE_SQL}"
            push_message 2 audit_role_2 "----------- end -----------"
            # push standard output
            push_message 3 audit_role_2 "run_sql ${user} failed."
            echo ""
            exit
        fi
    done

    push_message 3 audit_role "success."
    push_message 1 audit_role "end."
}


#
# 08. audit_table              table_list.txt のテーブルに対して監査設定
#
function audit_table() {
    
    push_message 1 audit_table "start."

    ### Table list
    TABLE_LIST=${SCRIPT_DIR}/env/table_list.txt

    ### check table_list.txt
    if [ ! -f ${TABLE_LIST} ]; then
        status=1
        push_message 1 audit_table "failed."
        push_message 2 audit_table "--------- message ---------"
        push_message 2 audit_table "table_list.txt not exists."
        push_message 2 audit_table "make [${TABLE_LIST}]"
        push_message 2 audit_table "----------- end -----------"
        push_message 3 audit_table "failed."
        echo ""
        exit
    fi

    ### check table count
    TABLE_LIST_COUNT=`cat ${TABLE_LIST} | wc -l`

    if [ "${TABLE_LIST_COUNT}" = 0 ]; then
        status=1
        push_message 1 audit_table "failed."
        push_message 2 audit_table "--------- message ---------"
        push_message 2 audit_table "there is no table in table_list.txt."
        push_message 2 audit_table "configure tables in [${TABLE_LIST}]"
        push_message 2 audit_table "----------- end -----------"
        push_message 3 audit_table "failed."
        echo ""
        exit
    fi

    ### grant all on table_list to rds_pgaudit
    while read line
    do
        if [ -z "${line}" ]; then
            continue
        fi
        # grant to rds_pgaudit
        SQL="/*SQL11*/ grant all on ${line} to rds_pgaudit;"
        TRACE_SQL=`${PSQL_CON} -A -t -c "${SQL}" 2>&1`
        ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then

            # success
            if [ "${TRACE_SQL}" = "GRANT" ]; then
                push_message 1 audit_table "run_sql ${line} success."
            # failed
            else
                push_message 1 audit_table "run_sql ${line} failed."
                push_message 2 audit_table "--------- message ---------"
                push_message 2 audit_table "${SQL}"
                push_message 2 audit_table "${TRACE_SQL}"
                push_message 2 audit_table "----------- end -----------"
                push_message 3 audit_table "failed."
                echo ""
                exit
            fi
        else
            # push logfile
            push_message 1 audit_table "run_sql ${line} failed."
            push_message 2 audit_table "--------- message ---------"
            push_message 2 audit_table "${SQL}"
            push_message 2 audit_table "${TRACE_SQL}"
            push_message 2 audit_table "----------- end -----------"
            # push standard output
            push_message 3 audit_table "run_sql ${line} failed."
            push_message 3 audit_table "failed."
            echo ""
            exit
        fi
    done < ${TABLE_LIST}

    # function end.
    push_message 3 audit_table "end."
    push_message 1 audit_table "end."

}


#
# 09. describe_audit_database  接続先 DataBase の監査設定を確認
#
function describe_audit_database() {

    push_message 1 describe_audit_database "start."

    ### describe_rds_pgaudit_privilege.sql
    SQL=${SCRIPT_DIR}/sql/describe_audit_database.sql

    ### check table_list.txt
    if [ ! -f ${SQL} ]; then
        push_message 1 describe_audit_database "failed."
        push_message 2 describe_audit_database "--------- message ---------"
        push_message 2 describe_audit_database "sql file not exists."
        push_message 2 describe_audit_database "put [${SQL}]"
        push_message 2 describe_audit_database "--------- message ---------"
        push_message 3 describe_audit_database "failed."
        echo ""
        exit
    fi

    ### describe rds_pgaudit access privilege
    echo "" >> ${LOG_FILE_PATH}
    TRACE_SQL=`${PSQL_CON} -f ${SQL} >> ${LOG_FILE_PATH} 2>&1`
    ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then

            # anything error happend
            if [ "`echo ${TRACE_SQL} | grep -e "ERROR"`" ]; then
                # push logfile
                push_message 1 describe_audit_database "run_sql failed."
                push_message 2 describe_audit_database "--------- message ---------"
                push_message 2 describe_audit_database "${SQL}"
                push_message 2 describe_audit_database "${TRACE_SQL}"
                push_message 2 describe_audit_database "----------- end -----------"
                # push standard output
                push_message 3 describe_audit_database "run_sql failed."
                echo ""
                exit
            fi

            # push logfile
            push_message 1 describe_audit_database "run_sql success."
        
        else
            # push logfile
            push_message 1 describe_audit_database "run_sql failed."
            push_message 2 describe_audit_database "--------- message ---------"
            push_message 2 describe_audit_database "${SQL}"
            push_message 2 describe_audit_database "${TRACE_SQL}"
            push_message 2 describe_audit_database "----------- end -----------"
            # push standard output
            push_message 3 describe_audit_database "run_sql failed."
            echo ""
            exit
        fi

    # function end.
    push_message 3 describe_audit_database "success."
    push_message 1 describe_audit_database "end."
}


#
# 10. describe_audit_role      各ロールの監査設定を確認
#
function describe_audit_role() {

    push_message 1 describe_audit_role "start."

    ### describe_rds_pgaudit_privilege.sql
    SQL=${SCRIPT_DIR}/sql/describe_audit_role.sql

    ### check table_list.txt
    if [ ! -f ${SQL} ]; then
        push_message 1 describe_audit_role "failed."
        push_message 2 describe_audit_role "--------- message ---------"
        push_message 2 describe_audit_role "sql file not exists."
        push_message 2 describe_audit_role "put [${SQL}]"
        push_message 2 describe_audit_role "--------- message ---------"
        push_message 3 describe_audit_role "failed."
        echo ""
        exit
    fi

    ### describe rds_pgaudit access privilege
    echo "" >> ${LOG_FILE_PATH}
    TRACE_SQL=`${PSQL_CON} -f ${SQL} >> ${LOG_FILE_PATH} 2>&1`
    ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then

            # anything error happend
            if [ "`echo ${TRACE_SQL} | grep -e "ERROR"`" ]; then
                # push logfile
                push_message 1 describe_audit_role "run_sql failed."
                push_message 2 describe_audit_role "--------- message ---------"
                push_message 2 describe_audit_role "${SQL}"
                push_message 2 describe_audit_role "${TRACE_SQL}"
                push_message 2 describe_audit_role "----------- end -----------"
                # push standard output
                push_message 3 describe_audit_role "run_sql failed."
                echo ""
                exit
            fi

            # push logfile
            push_message 1 describe_audit_role "run_sql success."
        
        else
            # push logfile
            push_message 1 describe_audit_role "run_sql failed."
            push_message 2 describe_audit_role "--------- message ---------"
            push_message 2 describe_audit_role "${SQL}"
            push_message 2 describe_audit_role "${TRACE_SQL}"
            push_message 2 describe_audit_role "----------- end -----------"
            # push standard output
            push_message 3 describe_audit_role "run_sql failed."
            echo ""
            exit
        fi


    # function end.
    push_message 3 describe_audit_role "success."
    push_message 1 describe_audit_role "end."
}


#
# 11. describe_audit_table     rds_pgaudit の権限を確認
#
function describe_audit_table() {

    push_message 1 describe_audit_table "start."

    ### describe_rds_pgaudit_privilege.sql
    SQL=${SCRIPT_DIR}/sql/describe_audit_table.sql

    ### check table_list.txt
    if [ ! -f ${SQL} ]; then
        push_message 1 describe_audit_table "failed."
        push_message 2 describe_audit_table "--------- message ---------"
        push_message 2 describe_audit_table "sql file not exists."
        push_message 2 describe_audit_table "put [${SQL}]"
        push_message 2 describe_audit_table "--------- message ---------"
        push_message 3 describe_audit_table "failed."
        echo ""
        exit
    fi

    ### describe rds_pgaudit access privilege
    echo "" >> ${LOG_FILE_PATH}
    TRACE_SQL=`${PSQL_CON} -f ${SQL} >> ${LOG_FILE_PATH} 2>&1`
    ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then

            # anything error happend
            if [ "`echo ${TRACE_SQL} | grep -e "ERROR"`" ]; then
                # push logfile
                push_message 1 describe_audit_table "run_sql failed."
                push_message 2 describe_audit_table "--------- message ---------"
                push_message 2 describe_audit_table "${SQL}"
                push_message 2 describe_audit_table "${TRACE_SQL}"
                push_message 2 describe_audit_table "----------- end -----------"
                # push standard output
                push_message 3 describe_audit_table "run_sql failed."
                echo ""
                exit
            fi

            # push logfile
            push_message 1 describe_audit_table "run_sql success."
        
        else
            # push logfile
            push_message 1 describe_audit_table "run_sql failed."
            push_message 2 describe_audit_table "--------- message ---------"
            push_message 2 describe_audit_table "${SQL}"
            push_message 2 describe_audit_table "${TRACE_SQL}"
            push_message 2 describe_audit_table "----------- end -----------"
            # push standard output
            push_message 3 describe_audit_table "run_sql failed."
            echo ""
            exit
        fi

    # function end.
    push_message 3 describe_audit_table "success."
    push_message 1 describe_audit_table "end."
}

#
# 12. noaudit_database         接続先 DataBase の監査設定を解除
#
function noaudit_database() {

    push_message 1 noaudit_database "start."

    ### alter database
    SQL="/*SQL15*/ ALTER DATABASE ${DATABASE} RESET pgaudit.log;"
    run_sql noaudit_database "${SQL}"
    
    # function end.
    push_message 3 noaudit_database "success."
    push_message 1 noaudit_database "end."
}


#
# 13. noaudit_role          cannnot login 以外のユーザーに対してセッション監査設定を解除
#
function noaudit_role() {

    push_message 1 noaudit_role "start."

    ### Get User List
    SQL="/*SQL16*/ select rolname from pg_roles where rolcanlogin ='t' and rolname !='rdsadmin';"
    run_sql noaudit_role "${SQL}"

    ### set array    
    USER_LIST_ARRAY=(`echo ${TRACE_SQL}`)

        # push logfile
        push_message 1 noaudit_role ""${#USER_LIST_ARRAY[@]}" users"
        push_message 2 noaudit_role "${TRACE_SQL}"
        # push standard output
        push_message 3 noaudit_role ""${#USER_LIST_ARRAY[@]}" users"

    ### check user count
    if [ "${#USER_LIST_ARRAY[@]}" = 0 ]; then
        # push logfile
        push_message 1 noaudit_role "failed."
        push_message 2 noaudit_role "--------- message ---------"
        push_message 1 noaudit_role "There is no user."
        push_message 2 noaudit_role "----------- end -----------"
        # push standard output
        push_message 3 noaudit_role "failed."
        echo ""
        exit
    fi

    for user in ${USER_LIST_ARRAY[@]}
    do
        # alter role
        SQL="/*SQL17*/ ALTER ROLE ${user} RESET pgaudit.log;"
        TRACE_SQL=`${PSQL_CON} -A -t -c "${SQL}" 2>&1`
        ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then
            # push logfile
            push_message 1 noaudit_role "run_sql ${user} success."
        else
            # push logfile
            push_message 1 noaudit_role "run_sql ${user} failed."
            push_message 2 noaudit_role "--------- message ---------"
            push_message 2 noaudit_role "${SQL}"
            push_message 2 noaudit_role "${TRACE_SQL}"
            push_message 2 noaudit_role "----------- end -----------"
            # push standard output
            push_message 3 noaudit_role "run_sql ${user} failed."
            echo ""
            exit
        fi
    done

    push_message 3 noaudit_role "success."
    push_message 1 noaudit_role "end."
}


#
# 14. noaudit_table            table_list.txt のテーブルに対して監査設定解除
#
function noaudit_table() {
    
    push_message 1 noaudit_table "start."

    ### Table list
    TABLE_LIST=${SCRIPT_DIR}/env/table_list.txt

    ### check table_list.txt
    if [ ! -f ${TABLE_LIST} ]; then
        # push logfile
        push_message 1 noaudit_table "failed."
        push_message 2 noaudit_table "--------- message ---------"
        push_message 2 noaudit_table "table_list.txt not exists."
        push_message 2 noaudit_table "make [${TABLE_LIST}]"
        push_message 2 noaudit_table "----------- end -----------"
        # push standard output
        push_message 3 noaudit_table "failed."
        echo ""
        exit
    fi

    ### check table count
    TABLE_LIST_COUNT=`cat ${TABLE_LIST} | wc -l`

    if [ "${TABLE_LIST_COUNT}" = 0 ]; then
        # push logfile
        push_message 1 noaudit_table "failed."
        push_message 2 noaudit_table "--------- message ---------"
        push_message 2 noaudit_table "there is no table in table_list.txt."
        push_message 2 noaudit_table "configure tables in [${TABLE_LIST}]"
        push_message 2 noaudit_table "----------- end -----------"
        # push standard output
        push_message 3 noaudit_table "failed."
        echo ""
        exit
    fi

    ### grant all on table_list to rds_pgaudit
    while read line
    do
        if [ -z "${line}" ]; then
            continue
        fi
        # grant to rds_pgaudit
        SQL="/*SQL18*/ revoke all on ${line} from rds_pgaudit;"
        TRACE_SQL=`${PSQL_CON} -A -t -c "${SQL}" 2>&1`
        ret=$?

        # error handling
        if [ "${ret}" = 0 ]; then

            # success
            if [ "${TRACE_SQL}" = "REVOKE" ]; then
                push_message 1 noaudit_table "run_sql ${line} success."
            # failed
            else
                # push logfile
                push_message 1 noaudit_table "run_sql ${line} failed."
                push_message 2 noaudit_table "--------- message ---------"
                push_message 2 noaudit_table "${SQL}"
                push_message 2 noaudit_table "${TRACE_SQL}"
                push_message 2 noaudit_table "----------- end -----------"
                # push standard output
                push_message 3 noaudit_table "failed."
                echo ""
                exit
            fi

        else
            # push logfile
            push_message 1 noaudit_table "run_sql ${line} failed."
            push_message 2 noaudit_table "--------- message ---------"
            push_message 2 noaudit_table "${SQL}"
            push_message 2 noaudit_table "${TRACE_SQL}"
            push_message 2 noaudit_table "----------- end -----------"
            # push standard output
            push_message 3 noaudit_table "failed."
            echo ""
            exit
        fi
    done < ${TABLE_LIST}

    # function end.
    push_message 3 noaudit_table "end."
    push_message 1 noaudit_table "end."

}


#
# 15. check_role_rds_pgaudit   rds_pgaudit の設定を確認
#
function check_role_rds_pgaudit() {

    push_message 1 check_role_rds_pgaudit "start."
    
    ### make sure rds_pgaudit exists
    SQL="/*SQL19*/ select rolname from pg_roles where rolname='rds_pgaudit';"
    run_sql check_role_rds_pgaudit "${SQL}"

    ### make sure rds_pgaudit exists
    if [ "${TRACE_SQL}" != "rds_pgaudit" ]; then
        # push logfile
        push_message 1 check_role_rds_pgaudit "failed."
        push_message 2 check_role_rds_pgaudit "--------- message ---------"
        push_message 2 check_role_rds_pgaudit "rds_pgaudit not exists."
        push_message 2 check_role_rds_pgaudit "----------- end -----------"
        # push standard output
        push_message 3 check_role_rds_pgaudit "failed."
        echo ""
        exit
    fi

    ### check pgaudit.role
    SQL="/*SQL20*/ show pgaudit.role;"
    run_sql check_role_rds_pgaudit "${SQL}"

    if [ "${TRACE_SQL}" != "rds_pgaudit" ]; then
        # push logfile
        push_message 1 check_role_rds_pgaudit "failed."
        push_message 2 check_role_rds_pgaudit "--------- message ---------"
        push_message 2 check_role_rds_pgaudit "pgaudit.role is not set."
        push_message 2 check_role_rds_pgaudit "----------- end -----------"
        # push standard output
        push_message 3 check_role_rds_pgaudit "failed."
        echo ""
        exit
    fi

    # function end.
    push_message 3 check_role_rds_pgaudit "success."
    push_message 1 check_role_rds_pgaudit "end."
}