#!/bin/bash
#
# [Description]
# Aurora PostgreSQL 監査設定の確認スクリプト
#

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
describe_audit_database
describe_audit_role
describe_audit_table

# script end
echo ""
push_message 1 main "all success end."
push_message 3 main "all success end."
echo ""
echo "" >> ${LOG_FILE_PATH}
