#!/bin/sh
# 
# Script to create full and incremental backups (for all databases on server) using innobackupex from Percona.
# http://www.percona.com/doc/percona-xtrabackup/innobackupex/innobackupex_script.html
#
# Every time it runs will generate an incremental backup except for the first time (full backup).
# FULLBACKUPLIFE variable will define your full backups schedule.

CAT=/bin/cat
FORMAIL=/usr/bin/formail
SENDMAIL=/usr/sbin/sendmail
CHMOD=/bin/chmod
CP=/bin/cp
MKDIR=/bin/mkdir
INNOBACKUPEX=innobackupex
INNOBACKUPEXFULL=/usr/bin/$INNOBACKUPEX
RCLONE=/bin/rclone
USEROPTIONS="--user=root --password={{ mysql_sa_pass }} --host=127.0.0.1"
TMPFILE="/tmp/innobackupex-runner.$$.tmp"
MAILTO={{ mysql_mailto | default('') }}
MYCNF=/etc/my.cnf
MYSQL=/usr/bin/mysql
MYSQLADMIN=/usr/bin/mysqladmin
XBCRYPT=/usr/bin/xbcrypt
BACKUPDIR={{ mysql_path }}/backup/mysql # Backups base directory
KEYRINGFILEDIR={{ mysql_path }}/mysql/mysql-keyring
FULLBACKUPDIR=$BACKUPDIR/full # Full backups directory
INCRBACKUPDIR=$BACKUPDIR/incr # Incremental backups directory
KEYRINGBACKUPDIR=$BACKUPDIR/mysql-keyring
FULLBACKUPLIFE={{ mysql_backupset_arg.life }} # Lifetime of the latest full backup in seconds
UMASK=755
KEEP={{ mysql_backupset_arg.keep }} # Number of full backups (and its incrementals) to keep
THREADS={{ ansible_processor_vcpus }}
ENCRYPT=AES256
ENCRYPTKEY="{{ mysql_backupset_arg.encryptkey }}"

# Grab start time
STARTED_AT=`date +%s`

#############################################################################
# Display error message and exit
#############################################################################
error()
{
	echo "$1" 1>&2
	exit 1
}

# Check options before proceeding
if [ ! -x $INNOBACKUPEXFULL ]; then
  error "$INNOBACKUPEXFULL does not exist."
fi

if [ ! -d $BACKUPDIR ]; then
  error "Backup destination folder: $BACKUPDIR does not exist."
fi

if [ -z "`$MYSQLADMIN $USEROPTIONS status | grep 'Uptime'`" ] ; then
  error "HALTED: MySQL does not appear to be running."
fi

if ! `echo 'exit' | $MYSQL -s $USEROPTIONS` ; then
  error "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)."
fi

# Some info output
echo "----------------------------"
echo
echo "$0: MySQL backup script"
echo "started: `date`"
echo

# Create full and incr backup directories if they not exist.
mkdir -p $FULLBACKUPDIR
mkdir -p $INCRBACKUPDIR

# Find latest full backup
LATEST_FULL=`find $FULLBACKUPDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -nr | head -1`

# Get latest backup last modification time
LATEST_FULL_CREATED_AT=`stat -c %Y $FULLBACKUPDIR/$LATEST_FULL`

# Run an incremental backup if latest full is still valid. Otherwise, run a new full one.
if [ "$LATEST_FULL" -a `expr $LATEST_FULL_CREATED_AT + $FULLBACKUPLIFE + 5` -ge $STARTED_AT ] ; then
  # Create incremental backups dir if not exists.
  TMPINCRDIR=$INCRBACKUPDIR/$LATEST_FULL
  mkdir -p $TMPINCRDIR
  
  # Find latest incremental backup.
  LATEST_INCR=`find $TMPINCRDIR -mindepth 1 -maxdepth 1 -type d | sort -nr | head -1`
  
  # If this is the first incremental, use the full as base. Otherwise, use the latest incremental as base.
  if [ ! $LATEST_INCR ] ; then
    INCRBASEDIR=$FULLBACKUPDIR/$LATEST_FULL
  else
    INCRBASEDIR=$LATEST_INCR
  fi
  
  echo "Running new incremental backup using $INCRBASEDIR as base."
  $INNOBACKUPEXFULL --defaults-file=$MYCNF --compress --compress-threads=$THREADS --encrypt-threads=$THREADS --encrypt-chunk-size=256K --encrypt=$ENCRYPT --encrypt-key=$ENCRYPTKEY{% if mysql_arg.data_encryption | bool %} --keyring-file-data=$KEYRINGFILEDIR/keyring{% endif %} --parallel=$THREADS $USEROPTIONS --incremental $TMPINCRDIR --incremental-basedir $INCRBASEDIR > $TMPFILE 2>&1
else
  echo "Running new full backup."
  $INNOBACKUPEXFULL --defaults-file=$MYCNF --compress --compress-threads=$THREADS --encrypt-threads=$THREADS --encrypt-chunk-size=256K --encrypt=$ENCRYPT --encrypt-key=$ENCRYPTKEY{% if mysql_arg.data_encryption | bool %} --keyring-file-data=$KEYRINGFILEDIR/keyring{% endif %} --parallel=$THREADS $USEROPTIONS $FULLBACKUPDIR > $TMPFILE 2>&1
fi

{% if mysql_arg.data_encryption | bool %}
if [ ! -d $KEYRINGBACKUPDIR ]; then
  $MKDIR $KEYRINGBACKUPDIR
fi
$CP $KEYRINGFILEDIR/* $KEYRINGBACKUPDIR
{% endif %}

echo "Decrypting Encrypted LSN." >> $TMPFILE 2>&1
for i in `find $BACKUPDIR -iname "xtrabackup_checkpoints.xbcrypt"`; do $XBCRYPT -d --encrypt-key=$ENCRYPTKEY --encrypt-algo=$ENCRYPT < $i > $(dirname $i)/$(basename $i .xbcrypt); done

{% if mysql_mailto is defined %}
if [ -z "`tail -2 $TMPFILE | grep 'completed OK!'`" ] ; then
  echo "$INNOBACKUPEX failed:"; echo
  echo "---------- ERROR OUTPUT from $INNOBACKUPEX ----------"
  $CAT $TMPFILE | $FORMAIL -I "X-Message-Flag: " -I "X-Priority: 1 (Highest)" -I "X-MSMail-Priority: High" -I "From: do-not-reply@somebody.com" -I "Subject:"`hostname`" MySQL backup failed on "`date '+%Y%m%d'` | $SENDMAIL -oi $MAILTO
  exit 1
else
  $CAT $TMPFILE | $FORMAIL -I "From: do-not-reply@somebody.com" -I "Subject:"`hostname`" MySQL backup succeed on "`date '+%Y%m%d'` | $SENDMAIL -oi $MAILTO
fi
{% endif %}

THISBACKUP=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" $TMPFILE`

echo "Databases backed up successfully to: $THISBACKUP"
echo

# Cleanup
/bin/date >> $TMPFILE
echo "Cleanup. Keeping only $KEEP full backups and its incrementals."
AGE=$(($FULLBACKUPLIFE * $KEEP / 60))
find $FULLBACKUPDIR -maxdepth 1 -type d -mmin +$AGE -exec echo "removing: "$FULLBACKUPDIR \; -exec rm -rf {} \;  >> $TMPFILE
find $INCRBACKUPDIR -maxdepth 1 -type d -mmin +$AGE -exec echo "removing: "$INCRBACKUPDIR \; -exec rm -rf {} \;  >> $TMPFILE

# Changing default umask
$CHMOD -R $UMASK $BACKUPDIR

{% if mysql_backupset_arg.cloud_rsync | bool and mysql_backupset_arg.cloud_drive is defined %}
# Rsync for cloud storage
$RCLONE --verbose --config="/etc/rclone_mysql.conf" mkdir mysql:{{ ansible_hostname | lower }} >> $TMPFILE
$RCLONE --bwlimit="{{ mysql_backupset_arg.cloud_bwlimit | default('10M') }}" --verbose --config="/etc/rclone_mysql.conf" sync {{ mysql_path }}/backup/mysql mysql:{{ ansible_hostname | lower }} >> $TMPFILE
{% endif %}

#rm -f $TMPFILE
echo
echo "completed: `date`"
exit 0
