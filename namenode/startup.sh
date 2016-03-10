#!/bin/bash

if [ ! -d /opt/jxtadoop-1.0.0/tmp/hadoop-root  ]; then
        /opt/jxtadoop-1.0.0/bin/hadoop namenode -format
fi

/opt/jxtadoop-1.0.0/bin//start-namenode.sh

sleep 10

tail -f /opt/jxtadoop-1.0.0/logs/hadoop--namenode-rendez-vous.log

