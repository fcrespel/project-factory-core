#!/bin/bash
#
# tomcat       Startup script for the Apache Tomcat Servlet Container
#
### BEGIN INIT INFO
# Provides: @{package.service}
# Required-Start: $local_fs $remote_fs $network
# Required-Stop: $local_fs $remote_fs $network
# Should-Start: $named $time @{product.id}-mysql
# Should-Stop: $named $time @{product.id}-mysql
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: @{product.name} Apache Tomcat Servlet Container
# Description: @{product.name} Apache Tomcat Servlet Container
### END INIT INFO
#
# - originally written by Henri Gomez, Keith Irwin, and Nicolas Mailhot
# - heavily rewritten by Deepak Bhole and Jason Corley
# - adapted for use with standard Tomcat catalina.sh by Fabien Crespel
#

# Source LSB function library
if [ -r /lib/lsb/init-functions ]; then
	. /lib/lsb/init-functions
else
	exit 1
fi

DISTRIB_ID=`lsb_release -i -s 2>/dev/null`

NAME="$(basename $0)"
unset ISBOOT
if [ "${NAME:0:1}" = "S" -o "${NAME:0:1}" = "K" ]; then
	NAME="${NAME:3}"
	ISBOOT="1"
fi

# For SELinux we need to use 'runuser' not 'su'
if [ -x "/sbin/runuser" ]; then
	SU="/sbin/runuser -s /bin/bash"
else
	SU="/bin/su -s /bin/bash"
fi

# Get the tomcat config (use this for environment specific settings)
TOMCAT_CFG="@{product.app}/system/tomcat/conf/service.conf"
if [ -r "$TOMCAT_CFG" ]; then
	. $TOMCAT_CFG
fi

# Get instance specific config file
TOMCAT_INSTANCE_CFG="@{package.app}/conf/service.conf"
if [ -r "$TOMCAT_INSTANCE_CFG" ]; then
	. "$TOMCAT_INSTANCE_CFG"
fi

# Path to the tomcat launch script
TOMCAT_SCRIPT="@{product.app}/system/tomcat/bin/catalina.sh"

# Tomcat program name
TOMCAT_PROG="${NAME}"

# Define the tomcat username and group
TOMCAT_USER="${TOMCAT_USER:-tomcat}"
TOMCAT_GROUP=${TOMCAT_GROUP:-$(id -g $TOMCAT_USER)}

# Define the service log file
TOMCAT_LOG="${TOMCAT_LOG:-${CATALINA_BASE}/logs/initd.log}"

# Define the lock file name
TOMCAT_LOCKFILE="${TOMCAT_LOCKFILE:-/var/lock/subsys/${NAME}}"

# Define the pid file name
export CATALINA_PID="${CATALINA_PID:-/var/run/${NAME}.pid}"

function parseOptions() {
	options=""
	if [ -r "$TOMCAT_CFG" ]; then
		options="$options $(
					awk '!/^#/ && !/^$/ { ORS=" "; print "export ", $0, ";" }' \
					$TOMCAT_CFG
				 )"
	fi
	if [ -r "$TOMCAT_INSTANCE_CFG" ]; then
		options="$options $(
					awk '!/^#/ && !/^$/ { ORS=" "; print "export ", $0, ";" }' \
					$TOMCAT_INSTANCE_CFG
				 )"
	fi
	TOMCAT_SCRIPT="$options ${TOMCAT_SCRIPT}"
}

function version() {
	parseOptions
	$SU - $TOMCAT_USER -c "${TOMCAT_SCRIPT} version" || RETVAL="4"
}

function start() {
	echo -n "Starting ${TOMCAT_PROG}: "
	if [ "$RETVAL" != "0" ]; then 
		log_failure_msg
		return
	fi
	if [ -f "${TOMCAT_LOCKFILE}" ]; then
		if [ -f "${CATALINA_PID}" ]; then
			read kpid < ${CATALINA_PID}
			if [ -d "/proc/${kpid}" ]; then
				log_success_msg
				if [ "$DISTRIB_ID" = "MandrivaLinux" ]; then
					echo
				fi
				RETVAL="0"
				return
			fi
		fi
	fi
	# fix permissions on the log and pid files
	touch $CATALINA_PID 2>&1 || RETVAL="4"
	if [ "$RETVAL" -eq "0" -a "$?" -eq "0" ]; then 
		chown ${TOMCAT_USER}:${TOMCAT_GROUP} $CATALINA_PID
	fi
	[ "$RETVAL" -eq "0" ] && touch $TOMCAT_LOG 2>&1 || RETVAL="4" 
	if [ "$RETVAL" -eq "0" -a "$?" -eq "0" ]; then
		chown ${TOMCAT_USER}:${TOMCAT_GROUP} $TOMCAT_LOG
	fi
	chown -R ${TOMCAT_USER}:${TOMCAT_GROUP} "$CATALINA_BASE/logs/" "$CATALINA_BASE/run/" "$CATALINA_BASE/temp/" "$CATALINA_BASE/webapps/" "$CATALINA_BASE/work/"
	parseOptions
	if [ "$RETVAL" -eq "0" -a "$SECURITY_MANAGER" = "true" ]; then
		$SU - $TOMCAT_USER -c "${TOMCAT_SCRIPT} start -security" >> ${TOMCAT_LOG} 2>&1 || RETVAL="4"
	else
		[ "$RETVAL" -eq "0" ] && $SU - $TOMCAT_USER -c "${TOMCAT_SCRIPT} start" >> ${TOMCAT_LOG} 2>&1 || RETVAL="4"
	fi
	if [ "$RETVAL" -eq "0" ]; then 
		log_success_msg
		touch ${TOMCAT_LOCKFILE}
	else
		log_failure_msg "Error code ${RETVAL}"
	fi
	if [ "$DISTRIB_ID" = "MandrivaLinux" ]; then
		echo
	fi
}

function stop() {
	echo -n "Stopping ${TOMCAT_PROG}: "
	if [ -f "${TOMCAT_LOCKFILE}" ]; then
		parseOptions
		if [ "$RETVAL" -eq "0" ]; then
			touch ${TOMCAT_LOCKFILE} 2>&1 || RETVAL="4"
			[ "$RETVAL" -eq "0" ] && $SU - $TOMCAT_USER -c "${TOMCAT_SCRIPT} stop $SHUTDOWN_WAIT -force" >> ${TOMCAT_LOG} 2>&1 || RETVAL="4"
		fi
		if [ "$RETVAL" -eq "0" ]; then
			log_success_msg
			rm -f ${TOMCAT_LOCKFILE} ${CATALINA_PID}
		else
			log_failure_msg
			RETVAL="4"
		fi
	else
		log_success_msg
		RETVAL="0"
	fi
	if [ "$DISTRIB_ID" = "MandrivaLinux" ]; then
		echo
	fi
}

function status()
{
	checkpidfile 
	if [ "$RETVAL" -eq "0" ]; then
		log_success_msg "${NAME} (pid ${kpid}) is running..."
	elif [ "$RETVAL" -eq "1" ]; then
		log_failure_msg "PID file exists, but process is not running"
	else 
		checklockfile
		if [ "$RETVAL" -eq "2" ]; then
			log_failure_msg "${NAME} lockfile exists but process is not running"
		else
			pid="$(/usr/bin/pgrep -u ${TOMCAT_USER} -f ${NAME})"
			if [ -z "$pid" ]; then
				log_success_msg "${NAME} is stopped"
				RETVAL="3"
			else
				log_success_msg "${NAME} (pid $pid) is running..."
				RETVAL="0"
			fi
		fi
	fi
}

function checklockfile()
{
	if [ -f ${TOMCAT_LOCKFILE} ]; then
		pid="$(/usr/bin/pgrep -u ${TOMCAT_USER} -f ${NAME})"
		# The lockfile exists but the process is not running
		if [ -z "$pid" ]; then
			RETVAL="2"
		fi
	fi
}

function checkpidfile()
{
	if [ -f "${CATALINA_PID}" ]; then
		read kpid < ${CATALINA_PID}
		if [ -d "/proc/${kpid}" ]; then
			# The pid file exists and the process is running
			RETVAL="0"
		else
			# The pid file exists but the process is not running
			RETVAL="1"
			return
		fi
	fi
	# pid file does not exist and program is not running
	RETVAL="3"
}

function usage()
{
	echo "Usage: $0 {start|stop|restart|condrestart|try-restart|reload|force-reload|status|version}"
	RETVAL="2"
}

# See how we were called.
RETVAL="0"
case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	condrestart|try-restart)
		if [ -f "${CATALINA_PID}" ]; then
			stop
			start
		fi
		;;
	reload)
		RETVAL="3"
		;;
	force-reload)
		if [ -f "${CATALINA_PID}" ]; then
			stop
			start
		fi
		;;
	status)
		status
		;;
	version)
		version
		;;
	*)
		usage
		;;
esac

exit $RETVAL
