#!/bin/bash
#
# [Description]
# Aurora PostgreSQL ロールレベル監査設定スクリプト
#
# [Args]
# 0: audit mode.    監査設定実行
# 1: noaudit mode.  監査設定解除
#
# [Sample]
# ./main/audit_role.sh 0
#

# check args
Args=$1
if [[ $Args =~ [0-1] ]]; then
    echo ""
    if [ $Args = 0 ]; then
        echo "audit mode."
    elif [ $Args = 1 ]; then
        echo "noaudit mode."
    fi
else
    echo "unexpected args."
    exit
fi

# script path
SCRIPT_DIR=$(cd $(dirname $0); pwd)
SCRIPT_DIR=${SCRIPT_DIR%/*}

# log file path
if [ ! -d ${SCRIPT_DIR}/log ]; then
    mkdir ${SCRIPT_DIR}/log
fi

# log file name
SCRIPT_NAME=$(basename $0)
LOG_FILE_PATH=${SCRIPT_DIR}/log/${SCRIPT_NAME%.*}.log

# read connectin.env
. ${SCRIPT_DIR}/env/connection.env

# read postgresql_function.sh
. ${SCRIPT_DIR}/function/postgresql_function.sh

# script start
echo ""
push_message 1 main "start."
push_message 3 main "start."

# run functions
check_connection
check_extension_pgaudit
describe_audit_role
case $Args in
    "0" ) 
        audit_role
    ;;
    "1" )
        noaudit_role
    ;;
esac
describe_audit_role

# script end
echo ""
push_message 1 main "all success end."
push_message 3 main "all success end."
echo ""
echo "" >> ${LOG_FILE_PATH}
