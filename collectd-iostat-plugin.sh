#!/bin/bash
set -eo pipefail
pid_own="$$"

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname)}"
INTERVAL="${COLLECTD_INTERVAL:-1}"
INTERVAL="`echo $INTERVAL|sed s'#\..*##'`"
HOSTNAME="`echo $HOSTNAME|sed 's#\.#_#g'`"

func_iostat() {
iostat -cdxk "$INTERVAL" | awk -v HOSTNAME="$HOSTNAME" -v interval="$INTERVAL" '!/~|Linux|Time:|avg-cpu|Device|^$/{
if (NF==12){
# device-1, rrqm_se-2,  wrqm_sec-3, r_s-4, w_s-5, rsec-6, wse-7, avgrq_s-8, avgqu_sz-9, await-10, svctm-11,  util-12
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/rrqm"    " interval=" interval  " N:"  $2 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/wrqm"    " interval=" interval  " N:"  $3 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/rs"      " interval=" interval  " N:"  $4 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/ws"      " interval=" interval  " N:"  $5 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/rsec"    " interval=" interval  " N:"  $6 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/wsec"    " interval=" interval  " N:"  $7 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/avgrqsz" " interval=" interval  " N:"  $8 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/avgqusz" " interval=" interval  " N:"  $9 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/await"   " interval=" interval  " N:"  $10 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/svctm"   " interval=" interval  " N:"  $11 ;
            print "PUTVAL "  HOSTNAME  "/disk_iostat/gauge-"  $1  "/util"    " interval=" interval  " N:"  $12 ;
          }
if (NF==6){
#user-1   nice-2 system-3 iowait-4  steal-5   idle-6
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/user"   " interval=" interval  " N:"  $1 ;
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/nice"   " interval=" interval  " N:"  $2 ;
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/system" " interval=" interval  " N:"  $3 ;
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/iowait" " interval=" interval  " N:"  $4 ;
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/steal"  " interval=" interval  " N:"  $5 ;
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/idle"   " interval=" interval  " N:"  $6 ;
            print "PUTVAL "  HOSTNAME  "/cpu_iostat/gauge-cpu/util"   " interval=" interval  " N:"  $1 + $3 ;
          }
            system(""); # to flush output buffer
  }'
}


func_iostat &
pid_func="$!"


pid_iostat="`ps -ef|grep "iostat "|grep $pid_func|awk '{print $2}'`"
trap "kill  $pid_iostat $pid_func; kill -9 $pid_own; exit;" 1 2 15
read e
