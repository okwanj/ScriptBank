#!/bin/bash
set -u
set -e

export PATH=/opt/java8/bin/:$PATH
export LC_ALL="zh_CN.utf8"
source common_func.sh

function usage {
    echo "Usage: "
    echo "   start service: bash run.sh start dev/prod"
    echo "   stop  service: bash run.sh stop  dev/prod"
    exit 1
}

if [ $# -ne 2 ]
then
    usage
fi

runCmd=$1
checkParameter $runCmd "start stop"
mode=$2
checkParameter $mode "dev prod"


confDir=../conf/
mainConfFile=$confDir/conf.txt.$mode
log4jConfFile=$confDir/log4j.properties
jarDir=../lib/
port=`grep "\[addr\]" $mainConfFile -A2 | grep port | sed 's/port[ \t]*=[ \t]*//g'`

name=app_name
logDir=/var/log/$name
nohupLogFile=$logDir/nohup.log
gcLogFile=$logDir/gc.log
pidFile=/tmp/$name.pid

checkVar $port
checkDir $jarDir
checkDir $confDir
checkFile $log4jConfFile
checkFile $mainConfFile
checkDir $logDir

mainClass=com.okwanj.server.AppEngine

jars=`find $jarDir -name "*jar" | xargs | tr ' ' ':'`
heapSize="300m"
jvmSetting="-server \
    -XX:+UseConcMarkSweepGC \
    -XX:+UseParNewGC \
    -XX:CMSInitiatingOccupancyFraction=80 \
    -Xmx$heapSize \
    -Xms$heapSize "

gcLogSetting="-XX:+PrintGCDetails \
        -XX:+PrintGCDateStamps \
        -Xloggc:$gcLogFile "


case "$runCmd" in
  start)
        checkProcessNotExist $pidFile

        echo "Starting $name with"
        echo "   port:      $port"
        echo "   conf:      $mainConfFile"
        echo "   log4j:     $log4jConfFile"
        echo "   logDir:    $logDir"
        echo "   nohup:     $nohupLogFile"
        echo "   pidFile:   $pidFile"
        echo "   gcLogFile: $gcLogFile"
        echo "   jars:      $jars"
        echo "   pidFile:   $pidFile"
        echo "   jvm:       $jvmSetting"

        echo "java -Dlog4j.configuration=file:${log4jConfFile} \
                    -Dlogdir=$logDir \
                            -Dmyhostname=`hostname` \
                                    $jvmSetting \
                                            $gcLogSetting \
                                                    -cp $jars \
                                                            $mainClass $mainConfFile $port"
        nohup java -Dlog4j.configuration=file:$log4jConfFile \
        -Dlogdir=$logDir \
        -Dmyhostname=`hostname` \
        $jvmSetting \
        $gcLogSetting \
        -cp $jars \
        $mainClass $mainConfFile $port\
        > $nohupLogFile 2>&1 &

        pid=$!
        echo "$pid" > $pidFile
        checkProcessExist $pidFile
        echo "process is started. pid file: $pidFile, pid: $pid. "

        echo "Start $name successfully on port: $port"
        echo "the program may do initialization now, check logFile in dir: $logDir"
        echo "done!"
        ;;
  stop)
        echo -n "Stopping $name: "
        kill15Process $pidFile
        echo "Stop $name successfully"
        ;;
  *)
        usage
        ;;
esac

exit 0
