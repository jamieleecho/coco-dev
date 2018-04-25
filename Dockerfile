FROM ubuntu:16.04

MAINTAINER Jamie Cho version: 0.8

# Setup sources
RUN apt-get update
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:tormodvolden/m6809
RUN echo deb http://ppa.launchpad.net/tormodvolden/m6809/ubuntu trusty main >> /etc/apt/sources.list.d/tormodvolden-m6809-trusty.list
RUN echo deb http://ppa.launchpad.net/tormodvolden/m6809/ubuntu precise main >> /etc/apt/sources.list.d/tormodvolden-m6809-trusty.list
RUN apt-get update
RUN apt-get upgrade -y

# Install common essentials
RUN apt-get install -y build-essential g++ bison flex curl fuse libfuse-dev markdown python ruby python-setuptools python-dev python-pip libmagickwand-dev default-jdk
RUN apt-get install -y vim mame-tools git dos2unix ffmpeg

# Install CoCo Specific stuff
RUN apt-get install -y gcc6809=4.6.4-0~lw9a~trusty
RUN apt-get install -y lwtools=4.15-0~tormod~trusty
RUN apt-get install -y toolshed=2.2-0~tormod
RUN apt-get install -y cmoc=0.1.51-0~tormod

# Install useful Python tools
RUN pip install Pillow wand numpy pypng

# Install CoCo image conversion scripts
COPY scripts/* /usr/local/bin/

# Install milliluk-tools
WORKDIR /root
RUN git config --global core.autocrlf input
RUN git clone https://github.com/milliluk/milliluk-tools.git
RUN (cd milliluk-tools && git checkout 454e7247c892f7153136b9e5e6b12aeeecc9dd36 && dos2unix < cgp220/cgp220.py > /usr/local/bin/cgp220.py && dos2unix < max2png/max2png.py > /usr/local/bin/max2png.py)
RUN chmod a+x /usr/local/bin/cgp220.py /usr/local/bin/max2png.py 

# Install boisy/cmoc_os9
RUN git clone https://github.com/tlindner/cmoc_os9.git
WORKDIR cmoc_os9/lib
RUN git checkout b70df147169a9d76d88c1cd8114ada035ec15f62
RUN make
WORKDIR ../cgfx
RUN make
WORKDIR ..
RUN mkdir -p /usr/share/cmoc/lib/os9
RUN mkdir -p /usr/share/cmoc/include/os9/cgfx
RUN cp lib/libc.a cgfx/libcgfx.a /usr/share/cmoc/lib/os9
RUN cp -R include/* /usr/share/cmoc/include/os9
RUN cp -R cgfx/include/* /usr/share/cmoc/include/os9
WORKDIR ..

# Install java grinder
RUN git clone https://github.com/mikeakohn/naken_asm.git
RUN git clone https://github.com/mikeakohn/java_grinder
WORKDIR naken_asm
RUN git checkout 79d8eb05b77f23f4225282f635c9ee8ec9398ca6
RUN ./configure && make && make install
WORKDIR ../java_grinder
RUN git checkout 7d5e279c8b52c99414ded785b0ef8065dead55eb
RUN make && cp java_grinder /usr/local/bin/
WORKDIR ..

# Clean up
RUN apt-get clean
