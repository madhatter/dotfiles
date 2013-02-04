#!/bin/bash
hbase-daemon.sh stop regionserver 
hbase-daemon.sh stop master 
hadoop-daemon.sh stop jobtracker 
hadoop-daemon.sh stop tasktracker 
hadoop-daemon.sh stop namenode 
hadoop-daemon.sh stop datanode 
zkServer.sh stop 
