#!/bin/bash
set -eo pipefail
pid_own="$$"

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname)}"
INTERVAL="${COLLECTD_INTERVAL:-1}"
INTERVAL="`echo $INTERVAL|sed s'#\..*##'`"
HOSTNAME="`echo $HOSTNAME|sed 's#\.#_#g'`"

func_vmstat() {
vmstat -S m  "$INTERVAL" | awk -v HOSTNAME="$HOSTNAME" -v interval="$INTERVAL" '!/~[a-z]/{
#r-1  b-2   swpd-3   free-4  inact-5 active-6   si-7   so-8    bi-9    bo-10   in-11   cs-12 us-13 sy-14 id-15 wa-16 st-17
    print "PUTVAL "  HOSTNAME  "/system_vmstat/gauge-interrupts_per_sec"    " interval=" interval  " N:"  $11 ;
    print "PUTVAL "  HOSTNAME  "/system_vmstat/gauge-context_switches"    " interval=" interval  " N:"  $12 ;
    system(""); # to flush output buffer
  }'
}


func_vmstat &
pid_func="$!"


pid_vmstat="`ps -ef|grep "vmstat "|grep $pid_func|awk '{print $2}'`"
trap "kill  $pid_vmstat $pid_func; kill -9 $pid_own; exit;" 1 2 15
read e
