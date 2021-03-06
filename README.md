# A distibuted filesytem based on Hadoop & Jxta
This is a follow-up to this [post](http://besn0847.blogspot.com/2013/12/data-replication-in-multi-cloud.html) published about 2 years ago. There was no real explanation on how to quickly set-up Jxtadoop in a multi-network environment.

Since then, Docker has been significantly enhanced with networking and ability to create app based on Docker Compose. This is post is simply a guide on how to deploy and use Jxtadoop.

## Pre-requisites
You need to make you use at least the following :
* Docker Engine v1.10.2+
* Docker Compose v1.6.2+

All the test i did with lower versions, especially for Docker Compose failed, mainly because this requires the latest capabilites to build networks in the composer.

## Quickstart
Simply clone and start Docker Compose. First, clone the repository:

    git clone https://github.com/besn0847/jxtadoop-app.git

Start the containers (it will also create the networks):

    cd jxtadoop-app && docker-compose up -d


You should see the containers running. Just type 'docker-compose ps' and you should see:

    docker-compose ps
        Name              Command               State   Ports
        -----------------------------------------------------
        dn0a          /bin/sh -c /startup.sh   Up
        dn0b          /bin/sh -c /startup.sh   Up
        dn1a          /bin/sh -c /startup.sh   Up
        dn1b          /bin/sh -c /startup.sh   Up
        dn2a          /bin/sh -c /startup.sh   Up
        dn2b          /bin/sh -c /startup.sh   Up
        dn3a          /bin/sh -c /startup.sh   Up
        dn3b          /bin/sh -c /startup.sh   Up
        relay         /bin/sh -c /startup.sh   Up     0.0.0.0:19101->19101/tcp
        rendez-vous   /bin/sh -c /startup.sh   Up     0.0.0.0:19100->19100/tcp

Leave it running for 5 minutes so the P2P networks converges or tail the rendez-vous logs to detect datanode resgistration :

    docker logs -f rendez-vous
        ...
        2016-03-12 15:46:51,072 INFO org.apache.jxtadoop.hdfs.StateChange: BLOCK* NameSystem.registerDatanode: node registration from 59616261646162614E50472050325033DC4F9D1C75F77F20AE5CD6FAF5B7EFAE03 storage DS-1088764461-20.0.0.3-59616261646162614E50472050325033DC4F9D1C75F77F20AE5CD6FAF5B7EFAE03-1457797611067
        2016-03-12 15:46:51,073 INFO org.apache.jxtadoop.net.NetworkTopology: Adding a new node: /default-rack/59616261646162614E50472050325033DC4F9D1C75F77F20AE5CD6FAF5B7EFAE03
        ...

## Operations
There are 4 subnets (net0, net1, net2, net3) with 2 datanodes on each so 8 in total.

On net0, there is also the namenode as well a relaypeer in charge of forwarding P2P traffic between net1, net2, net3.

So if you connect to a node on net1 (say dn1a) and copy a file locally, it will then get replicated to other peers on different subnets. Note that if some blocks are replicated on net1, it will be done through multicast without being proxied by the relay.

. Step 0 : make sure all datanodes are connected to the P2P DFS

    docker exec -t -i rendez-vous /bin/bash
        bash-4.3# ./hadoop dfsadmin -report
            ...
            Datanodes available: 9 (9 total, 0 dead)
            ...
        exit

If not, then restart all datanodes :

    docker restart dn0a dn0b dn1a dn1b dn2a dn2b dn3a dn3a

. Step 1 : connect to the dn1a

    docker exec -t -i dn1a /bin/bash

. Step 2 : create a directory in the root of the filesystem

    cd /opt/jxtadoop-1.0.0
    bin/hadoop fs -mkdir /tmp

. Step 3 : upload a file to the Hadoop filesystem

    bin/hadoop fs -put /etc/hosts /tmp

. Step 4 : check the file has been correctly uploaded

    bin/hadoop fs -ls /tmp
        Found 1 items
        -rw-r--r--   3 root root        200 2016-03-12 15:58 /tmp/hosts

. Step 5 : exit from the dn1a

    exit

. Step 6 : now connect to dn3b and download the file 

    docker exec -t -i dn3b /bin/bash
        cd /opt/jxtadoop-1.0.0
        bin/hadoop fs -get /tmp/hosts /tmp/myfile
        cat /tmp/myfile
            ...

You can wait for few minutes until dn1a has replicated the file remotely, shut it down, wait for the namenode to detect dn1a is dead and then try again. Should work fine.

## References

* [Blogger](http://besn0847.blogspot.com/2013/12/data-replication-in-multi-cloud.html)
* [Binaries](https://sourceforge.net/projects/jxtadoop/)
* [Source](https://github.com/besn0847/Jxtadoop)
* [Release 1.0.0.](http://besn0847.blogspot.fr/2014/02/jxtadoop-release-100.html)

