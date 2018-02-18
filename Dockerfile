FROM ubuntu:16.04

MAINTAINER Jamie Cho version: 0.5

# Setup sources
RUN apt-get update
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:tormodvolden/m6809
RUN echo deb http://ppa.launchpad.net/tormodvolden/m6809/ubuntu trusty main >> /etc/apt/sources.list.d/tormodvolden-m6809-trusty.list
RUN echo deb http://ppa.launchpad.net/tormodvolden/m6809/ubuntu precise main >> /etc/apt/sources.list.d/tormodvolden-m6809-trusty.list
RUN apt-get update
RUN apt-get upgrade -y

# Install common essentials
RUN apt-get install -y build-essential g++ bison flex curl fuse libfuse-dev markdown python ruby python-setuptools python-dev python-pip libmagickwand-dev
RUN apt-get install -y vim mame-tools git dos2unix ffmpeg

# Install CoCo Specific stuff
RUN apt-get install -y gcc6809=4.6.4-0~lw6b~trusty
RUN apt-get install -y lwtools=4.14-0~tormod~trusty
RUN apt-get install -y toolshed=2.2-0~tormod
# RUN apt-get install -y cmoc=0.1.45-0~tormod

# Install CMOC directly from source
WORKDIR /root
ADD https://perso.b2b2c.ca/~sarrazip/dev/cmoc-0.1.48.tar.gz .
RUN tar -zxpvf cmoc-0.1.48.tar.gz
WORKDIR /root/cmoc-0.1.48
RUN ./configure
RUN make
RUN make install
WORKDIR /root

# Install useful Python tools
RUN pip install Pillow wand numpy pypng

# Install CoCo image conversion scripts
COPY scripts/* /usr/local/bin/

# Install milliluk-tools
RUN git config --global core.autocrlf input
RUN git clone https://github.com/milliluk/milliluk-tools.git
RUN (cd milliluk-tools && git checkout 454e7247c892f7153136b9e5e6b12aeeecc9dd36 && dos2unix < cgp220/cgp220.py > /usr/local/bin/cgp220.py && dos2unix < max2png/max2png.py > /usr/local/bin/max2png.py)
RUN chmod a+x /usr/local/bin/cgp220.py /usr/local/bin/max2png.py 

# Clean up
RUN apt-get clean
