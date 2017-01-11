#!/bin/bash
#################################
# common bash function 
################################

set -e 
set -u 

function checkParameter {
    x=$1
    list=$2
    if [[ $list =~ $x ]]
    then
        echo "" > /dev/null
    else
        echo "parameter error: $x. Valid value is \"$list\""
        exit
    fi
}

function checkFile {
    if [ ! -f $1 ]; then
        echo "Error: File $1 doesn't exit"
        exit
    fi
}

function checkDir {
    if [ ! -d $1 ]; then
        echo "Error: Directory $1 doesn't exit"
        exit
    fi
}

function checkVar {
    if [ -z "$1" ]; then
        echo "Error: variable $2 is not set"
        exit
    fi
}

function checkProcessExist {
    pidFile=$1
    if [ ! -f "$pidFile" ]; then
        echo "Error: pidFile $pidFile doesn't exist"
        exit
    fi
    
    pid=`cat $pidFile`
    if [ -z "$pid" ]; then
        echo "Error: pid in pidFile $pidFile is empty"
        rm "$pidFile" || true
        exit
    fi

    pidDir="/proc/$pid"
    if [ ! -d $pidDir ]; then
        echo "Error: Process pid: $pid doesn't exit"
        rm "$pidFile" || true
        exit 1
    fi
}

function killProcess {
    pidFile=$1
    if [ -f $pidFile ]; then
        pid=`cat $pidFile`
        if [ -n "$pid" ]; then
            while [ 1 ]; do
                echo "killing the process: $pid"
                checkNum $pid
                kill $pid || true
                sleep 1 
                pidDir="/proc/$pid"
                if [ ! -d $pidDir ]; then
                    break
                fi
            done
        fi
        rm $pidFile
        echo "done! stop process: $pid"
    else
        echo "done! process doesn't exit"
    fi 
}

function waitProcessExist {
    pidFile=$1
    if [ -f "$1" ]; then
       pid=`cat $1`
       if [ -n "$pid" ]; then
           pidDir="/proc/$pid"
           echo -n "wait for process to exit: "
           while [ 1 ]
           do
               if [ -d $pidDir ]; then
                   echo -n "."
                   sleep 1
                else
                    break
               fi
            done
            echo ""
       fi
       rm -f $pidFile
    fi
}

function checkProcessNotExist {
    pidFile=$1
    if [ -f "$1" ]; then
       pid=`cat $1`
       if [ -n "$pid" ]; then
           pidDir="/proc/$pid"
           if [ -d $pidDir ]; then
               echo "Warning: Process is already running, pid: $pid, stop it first!"
               exit 1
           fi
       fi
       rm -f $pidFile
    fi
}

function checkNum {
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
       echo "pid is not numeric: $1"
       exit
    fi
}

function httpServerStartProgress {
    url=$1
    tmpFile=`mktemp`
    echo "checking server: $url"
    echo -n "progress:"
    set +e
    while [ 1 ]
    do
        echo -n "."
        wget "$url" -q --timeout=5  -O $tmpFile
        if [ -s "$tmpFile" ];then
            wget "$url" -q --timeout=5  -O $tmpFile
            echo -n "Succ!"
            echo ""
            break
        fi
        sleep 1
    done
    set -e
}

function installCron {
    cronSchedule="$1"
    cronscript="$2"
    cronscript=$(echo $cronscript | sed 's_/_\\/_g')
    tmp=`mktemp`
    crontab -l | sed "/$cronscript/d" > $tmp  
    echo "$cronSchedule" >> $tmp
    crontab < $tmp
    rm -f $tmp
}

function uninstallCron {
    cronscript="$1"
    cronscript=$(echo $cronscript | sed 's_/_\\/_g')
    tmp=`mktemp`
    crontab -l | sed "/$cronscript/d" > $tmp
    crontab < $tmp
    rm -f $tmp
}

function installCronIntoFile {
    cronSchedule="$1"
    cronscript="$2"
    cronFile="$3"
    cronscript=$(echo $cronscript | sed 's_/_\\/_g')
    touch "$cronFile"
    tmp=`mktemp`
    cat $cronFile | sed "/$cronscript/d" > $tmp  
    echo "$cronSchedule" >> $tmp
    mv $tmp $cronFile
}

function uninstallCronFromFile {
    cronscript="$1"
    cronFile="$2"
    cronscript=$(echo $cronscript | sed 's_/_\\/_g')
    touch "$cronFile"
    tmp=`mktemp`
    cat $cronFile | sed "/$cronscript/d" > $tmp
    mv $tmp $cronFile
}
