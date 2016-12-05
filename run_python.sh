#!/bin/bash
######################################################
# a script used to start/stop the bbs search service

######################################################
set -u 
set -e

#check the commandline parameter
export PATH=/opt/java7/bin/:$PATH
export LC_ALL="zh_CN.utf8"
source common_func.sh

function usage {
    echo "Usage: "
    echo "    start: bash run.sh start dev"
    echo "    start: bash run.sh start prod"
    echo "    stop:  bash run.sh stop"
    exit 1
}

# do stop command
if [ $# -lt 1 ]
then
    usage
fi
runCmd=$1
name="industryCrawl"
checkParameter $runCmd "start stop"
pidFile=/tmp/$name.pid

if [ "$runCmd" == "stop" ]; then
    echo -n "Stopping $name: "
    #killProcess $pidFile
    checkProcessExist $pidFile
    killProcess $pidFile
    rm -rf $pidFile
    ps -ef|grep phantomjs|grep -v grep|cut -c 9-15|xargs kill -9
    echo "Stop $name successfully"
    exit 0
fi

if [ $# -ne 2 ]
then
    usage
fi
runEnv=$2
checkParameter $runEnv "dev prod"

# make sure the process is not running
checkProcessNotExist $pidFile
#confFile=../conf/conf.txt.$runEnv
confFile=../conf/crawler/conf.txt.$runEnv
confFile=`pwd`/$confFile
srcDir=../src/crawler/
checkFile $confFile
checkDir $srcDir
logDir=`cat $confFile  | grep -A 2 "\[logger\]" | grep dataDir | sed 's/dataDir[ \t]*=[ \t]*//g' | sed 's/[ \t]*//g'`
checkDir $logDir
nohupLogFile=$logDir/nohup.log

echo "Starting $name"
echo "    confFile:  $confFile"
echo "    nohupFile: $nohupLogFile"
echo "    logDir:    $logDir"
echo "--------------confFile: $confFile detail-------------"
cat $confFile

cd $srcDir
mainProgram=crawlMain.py
nohup python -u $mainProgram  -c $confFile > $nohupLogFile 2>&1 &
pid=$!
echo "$pid" > $pidFile
sleep 5
checkProcessExist $pidFile
echo "process is started. pid file: $pidFile, pid: $pid. "
cd - > /dev/null

exit 0
