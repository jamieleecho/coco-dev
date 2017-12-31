FROM ubuntu:16.04

MAINTAINER Jamie Cho version: 0.1

RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y build-essential g++ bison flex curl fuse libfuse-dev markdown python ruby python-setuptools python-dev python-pip libmagickwand-dev

# Install useful Python tools
RUN pip install Pillow wand numpy

WORKDIR /root

# Download, build and install lwtools
RUN curl http://lwtools.projects.l-w.ca/releases/lwtools/lwtools-4.14.tar.gz -o lwtools-4.14.tar.gz
RUN tar -zxpvf lwtools-4.14.tar.gz
RUN (cd lwtools-4.14 && make && make install)

# Download, build and install toolshed
RUN curl -L "https://downloads.sourceforge.net/project/toolshed/ToolShed/ToolShed%202.2/toolshed-2.2.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Ftoolshed%2F&ts=1514690206&use_mirror=cytranet" -o toolshed-2.2.tar.gz
RUN tar -zxpvf toolshed-2.2.tar.gz
RUN (cd toolshed-2.2/build/unix/ && make && make install)

# Download, build and install CMOC
RUN curl http://perso.b2b2c.ca/~sarrazip/dev/cmoc-0.1.45.tar.gz -o cmoc-0.1.45.tar.gz
RUN tar -zxpvf cmoc-0.1.45.tar.gz
RUN (cd cmoc-0.1.45 && ./configure && make -j && make install)

# Install coco image conversion scripts
COPY scripts/* /usr/local/bin/
