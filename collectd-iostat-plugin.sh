#!/bin/bash
set -eo pipefail
pid_own="$$"

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname)}"
INTERVAL="${COLLECTD_INTERVAL:-1}"
INTERVAL="`echo $INTERVAL|sed s'#\..*##'`"
HOSTNAME="`echo $HOSTNAME|sed 's#\.#_#g'`"

func_iostat() {
iostat -cdxk "$INTERVAL" | awk -v HOSTNAME="$HOSTNAME" -v interval="$INTERVAL" '!/~|Linux|Time:|^$/{

if ( $0 !~ /[0-9]+/ ) { 
  gsub("%","");
  gsub("/","_");
  s=$0
 } else {
  ss=$0
  n=1
  if ( s ~ "cpu" ) {
    dev = "cpu"
    path="cpu_iostat"
    d=1
  } else {
    dev=$1
    path="disk_iostat"
    d=0
  }
  col=NF
  util=0
  while (n < col+d){
    n = n + 1
    $0 = s
    metric = $n
    $0 = ss
    if (metric == "user" || metric == "system" ) util = util + $(n-d)
    print "PUTVAL "  HOSTNAME  "/" path "/gauge-" dev "/" metric   " interval=" interval  " N:"  $(n-d)
  }
  if (path == "cpu_iostat" ) print "PUTVAL "  HOSTNAME  "/" path "/gauge-cpu/util"   " interval=" interval  " N:"  util
 }
}'
}

func_iostat &
pid_func="$!"


pid_iostat="`ps -ef|grep "iostat "|grep $pid_func|awk '{print $2}'`"
trap "kill  $pid_iostat $pid_func; kill -9 $pid_own; exit;" 1 2 15
read e
