#!/bin/sh
DATE=/bin/date
CAT=/bin/cat
GREP=/bin/grep
RM=/bin/rm
FORMAIL=/usr/bin/formail
SENDMAIL=/usr/sbin/sendmail
MYSQLSLA=/usr/bin/pt-query-digest
LOGROTATE=/usr/sbin/logrotate
MKDIR=/bin/mkdir
MAILTO="{{ mysql_mailto }}"
SYS_DATE=`$DATE '+%Y%m%d'`
SYS_YEAR=`$DATE '+%Y'`
SYS_MONTH=`$DATE '+%m'`
SLOW_LOG=/data/mysql/logs/mysql_slow.log
RESULT_PATH=/data/mysql/mysqlsla_analyzes
RESULT_FILE=${RESULT_PATH}/${SYS_YEAR}/${SYS_MONTH}/mysqlsla_analyzes_$SYS_DATE

if [ ! -d "${RESULT_PATH}"/"${SYS_YEAR}"/"${SYS_MONTH}" ]; then
  $MKDIR -p ${RESULT_PATH}"/"${SYS_YEAR}"/"${SYS_MONTH}
fi

$MYSQLSLA --report-format 'rusage,date,header,profile,query_report,prepared' --filter '$event->{user} !~ m/prometheus|root/' $SLOW_LOG > $RESULT_FILE

$CAT $RESULT_FILE | $FORMAIL -I "From: do-not-reply@somebody.com" -I "Subject:"`hostname`" MySQL queries analyzes on "`date '+%Y%m%d'` | $SENDMAIL -oi $MAILTO

$LOGROTATE -f {{ mysql_path }}/mysql/mysql-log-rotate

exit 0
