FROM alpine
MAINTAINER Franck Besnard <franck@besnard.mobi>

RUN echo "http://dl-3.alpinelinux.org/alpine/v3.3/community/" >> /etc/apk/repositories &&\
	apk update &&\
	apk add openjdk8-jre-base bash

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV JRE_HOME /usr/lib/jvm/java-1.8-openjdk/jre

RUN cd /root &&\
	wget http://downloads.sourceforge.net/project/jxtadoop/jxtadoop-1.0.0-datanode.zip &&\
	mkdir /opt &&\
	cd /opt &&\
	unzip /root/jxtadoop-1.0.0-datanode.zip &&\
	rm /root/jxtadoop-1.0.0-datanode.zip &&\
	chmod +x /opt/jxtadoop-1.0.0/bin/*

ADD hdfs-p2p.xml  /opt/jxtadoop-1.0.0/etc/
ADD startup.sh /

RUN cd /opt/jxtadoop-1.0.0/etc/ &&\
	sed -i 's/__P2PNAMENODEPORT__/19100/g' hdfs-p2p.xml &&\
	sed -i 's/__P2PDATANODEPORT__/19101/g' hdfs-p2p.xml &&\
	sed -i 's/__P2PDFSCLIENTPORT__/19102/g' hdfs-p2p.xml &&\
	sed -i 's/__P2PCLIENTPORT__/19103/g' hdfs-p2p.xml &&\
	sed -i 's/__NAMENODEADDRR__:__NAMENODEPORT__/rendez-vous:19100/g' hdfs-p2p.xml &&\
	sed -i 's/__RELAYADDRR__:__RELAYNODEPORT__/relay:19100/g' hdfs-p2p.xml &&\
	chmod +x /startup.sh

CMD /startup.sh

