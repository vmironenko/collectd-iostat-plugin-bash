#!/bin/bash
pid_own="$$"
HOSTNAME=`hostname -s`
iostat_disk() {
iostat -dxk 1| awk -v HOSTNAME=$HOSTNAME '!/~|Linux|Time:|avg-cpu|Device|^$/{
# device-1, rrqm_se-2,  wrqm_sec-3, r_s-4, w_s-5, rsec-6, wse-7, avgrq_s-8, avgqu_sz-9, await-10, svctm-11,  util-12
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/rrqm "  "N:"  $2 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/wrqm "  "N:"  $3 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/rs "  "N:"  $4 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/ws "  "N:"  $5 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/rsec "  "N:"  $6 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/wsec "  "N:"  $7 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/avgrqsz "  "N:"  $8 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/avgqusz "  "N:"  $9 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/await "  "N:"  $10 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/svctm "  "N:"  $11 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/disk/"  $1  "/util "  "N:"   $12 ;
}'
}

iostat_cpu() {
iostat -c 1| awk -v HOSTNAME=$HOSTNAME '!/~|Linux|Time:|avg-cpu|Device|^$/{
#avg-cpu:  user-2   nice-3 system-4 iowait-5  steal-6   idle-7
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/user "  "N:"  $2 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/nice "  "N:"  $3 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/system "  "N:"  $4 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/iowait "  "N:"  $5 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/steal "  "N:"  $6 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/idle "  "N:"  $7 ;
            print "PUTVAL "  HOSTNAME  "/iostatplugin/cpu/"  $1  "/util "  "N:"  $2 + $4 ;
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

