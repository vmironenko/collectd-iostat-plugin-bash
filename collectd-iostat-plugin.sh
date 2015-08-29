#!/bin/bash
set -eo pipefail
pid_own="$$"

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname)}"
INTERVAL="${COLLECTD_INTERVAL:-1}"

iostat_disk() {
iostat -dxk $INTERVAL | awk -v HOSTNAME=$HOSTNAME -v interval=$INTERVAL '!/~|Linux|Time:|avg-cpu|Device|^$/{
# device-1, rrqm_se-2,  wrqm_sec-3, r_s-4, w_s-5, rsec-6, wse-7, avgrq_s-8, avgqu_sz-9, await-10, svctm-11,  util-12
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/rrqm"    " interval=" interval  " N:"  $2 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/wrqm"    " interval=" interval  " N:"  $3 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/rs"      " interval=" interval  " N:"  $4 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/ws"      " interval=" interval  " N:"  $5 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/rsec"    " interval=" interval  " N:"  $6 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/wsec"    " interval=" interval  " N:"  $7 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/avgrqsz" " interval=" interval  " N:"  $8 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/avgqusz" " interval=" interval  " N:"  $9 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/await"   " interval=" interval  " N:"  $10 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/svctm"   " interval=" interval  " N:"  $11 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/util"    " interval=" interval  " N:"  $12 ;
         }'
}

iostat_cpu() {
iostat -c $INTERVAL | awk -v HOSTNAME=$HOSTNAME -v interval=$INTERVAL '!/~|Linux|Time:|avg-cpu|Device|^$/{
#user-1   nice-2 system-3 iowait-4  steal-5   idle-6
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/user"   " interval=" interval  " N:"  $1 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/nice"   " interval=" interval  " N:"  $2 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/system" " interval=" interval  " N:"  $3 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/iowait" " interval=" interval  " N:"  $4 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/steal"  " interval=" interval  " N:"  $5 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/idle"   " interval=" interval  " N:"  $6 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/util"   " interval=" interval  " N:"  $1 + $3 ;
        }'
}

iostat_disk &
pid_iostat_disk="$!"

iostat_cpu &
pid_iostat_cpu="$!"

pid_iostat1="`ps -ef|grep "iostat "|grep $pid_iostat_disk|awk '{print $2}'`"
pid_iostat2="`ps -ef|grep "iostat "|grep $pid_iostat_cpu|awk '{print $2}'`"

trap "echo kill -15  $pid_iostat1 $pid_iostat2 $pid_iostat_disk; kill -9 $pid_own; exit;" 1 2 15
read e
