#!/bin/bash
#
# [Description]
# Oracle RDS 監査設定スクリプト
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

# Run Functions
check_connection
audit_DDL
audit_DML


# ALL Success End
echo ""
date "+%Y-%m-%d %H:%M:%S all success end." >> ${LOG_FILE}
echo "all success end."
echo ""
