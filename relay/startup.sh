#!/bin/bash

/opt/jxtadoop-1.0.0/bin//start-datanode.sh             

sleep 10
                                                       
tail -f /opt/jxtadoop-1.0.0/logs/hadoop--datanode-relay.log  
