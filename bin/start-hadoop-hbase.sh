#!/bin/bash
hadoop-daemon.sh start namenode 
hadoop-daemon.sh start datanode 
hadoop-daemon.sh start jobtracker 
hadoop-daemon.sh start tasktracker 
zkServer.sh start 
hbase-daemon.sh start master 
hbase-daemon.sh start regionserver 
