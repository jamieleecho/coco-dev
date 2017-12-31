FROM ubuntu:16.04

MAINTAINER Jamie Cho version: 0.1

RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y build-essential g++ bison flex curl fuse libfuse-dev markdown python ruby python-setuptools python-dev python-pip libmagickwand-dev
RUN apt-get install -y vim mame-tools git dos2unix

# Install useful Python tools
RUN pip install Pillow wand numpy pypng

WORKDIR /root

# Download, build and install LWTOOLS
RUN curl http://lwtools.projects.l-w.ca/releases/lwtools/lwtools-4.14.tar.gz -o lwtools-4.14.tar.gz
RUN tar -zxpvf lwtools-4.14.tar.gz
RUN (cd lwtools-4.14 && make && make install)

# Download, build and install ToolShed
RUN curl -L "https://downloads.sourceforge.net/project/toolshed/ToolShed/ToolShed%202.2/toolshed-2.2.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Ftoolshed%2F&ts=1514690206&use_mirror=cytranet" -o toolshed-2.2.tar.gz
RUN tar -zxpvf toolshed-2.2.tar.gz
RUN (cd toolshed-2.2/build/unix/ && make && make install)

# Download, build and install CMOC
RUN curl http://perso.b2b2c.ca/~sarrazip/dev/cmoc-0.1.45.tar.gz -o cmoc-0.1.45.tar.gz
RUN tar -zxpvf cmoc-0.1.45.tar.gz
RUN (cd cmoc-0.1.45 && ./configure && make -j && make install)

# Install CoCo image conversion scripts
COPY scripts/* /usr/local/bin/

# Install milliluk-tools
RUN git config --global core.autocrlf input
RUN git clone https://github.com/milliluk/milliluk-tools.git
RUN (cd milliluk-tools && git checkout 454e7247c892f7153136b9e5e6b12aeeecc9dd36 && dos2unix < cgp220/cgp220.py > /usr/local/bin/cgp220.py && dos2unix < max2png/max2png.py > /usr/local/bin/max2png.py)
RUN chmod a+x /usr/local/bin/cgp220.py /usr/local/bin/max2png.py 
