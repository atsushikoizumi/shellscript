#!/bin/bash
#
# [Description]
# Oracle RDS 監査設定解除用スクリプト
#
#


# script path
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# Read Connectin Info
. ${SCRIPT_DIR%/*}/env/connection.env

# Read Functions
. ${SCRIPT_DIR%/*}/bin/oracle_functions.sh

# sql path
SQL_PATH=${SCRIPT_DIR%/*}/sql
if [ ! -d ${SQL_PATH} ]; then
    mkdir ${SQL_PATH}
fi

# log path
LOG_PATH=${SCRIPT_DIR%/*}/log
if [ ! -d ${LOG_PATH} ]; then
    mkdir ${LOG_PATH}
fi

# define log file
NAME=$(basename $0)
LOG_FILE=${LOG_PATH}/${NAME%.*}.log

# Start
push_message 1 "start."

# Run Functions
check_connection
get_info_audit_DDL
noaudit_DDL
get_info_audit_DDL

# ALL Success End
push_message 1 "all success end."
push_message 3 "all success end."
echo ""
