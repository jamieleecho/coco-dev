FROM ubuntu:16.04

MAINTAINER Jamie Cho version: 0.12

# Setup sources
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  bison \
  build-essential \
  curl \
  default-jdk \
  dos2unix \
  ffmpeg \
  flex \
  fuse \
  g++ \
  git \
  libfuse-dev \
  libmagickwand-dev \
  mame-tools \
  markdown \
  python \
  python-dev \
  python-pip \
  python-setuptools \
  ruby \
  software-properties-common \
  vim

# Install useful Python tools
RUN pip install \
  numpy \
  Pillow \
  pypng \
  wand

# Install CoCo Specific stuff
RUN add-apt-repository ppa:tormodvolden/m6809
RUN echo deb http://ppa.launchpad.net/tormodvolden/m6809/ubuntu trusty main >> /etc/apt/sources.list.d/tormodvolden-m6809-trusty.list && \
  echo deb http://ppa.launchpad.net/tormodvolden/m6809/ubuntu precise main >> /etc/apt/sources.list.d/tormodvolden-m6809-trusty.list
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  cmoc=0.1.56-0~tormod \
  gcc6809=4.6.4-0~lw9a~trusty \
  lwtools=4.16-0~tormod~trusty \
  toolshed=2.2-0~tormod

# Install CoCo image conversion scripts
WORKDIR /root
RUN git config --global core.autocrlf input && \
  git clone https://github.com/jamieleecho/coco-tools.git && \
  (cd coco-tools && python setup.py install)

# Install milliluk-tools
WORKDIR /root
RUN git config --global core.autocrlf input && \
  git clone https://github.com/milliluk/milliluk-tools.git && \
  (cd milliluk-tools && git checkout 454e7247c892f7153136b9e5e6b12aeeecc9dd36 && \
  dos2unix < cgp220/cgp220.py > /usr/local/bin/cgp220.py && \
  chmod a+x /usr/local/bin/cgp220.py)

# Install boisy/cmoc_os9
RUN git clone https://github.com/tlindner/cmoc_os9.git
WORKDIR cmoc_os9/lib
RUN git checkout 9f9dfda1406d152f137131f0670c94d105b9b072 && \
  make
WORKDIR ../cgfx
RUN make
WORKDIR ..
RUN mkdir -p /usr/share/cmoc/lib/os9 && \
  mkdir -p /usr/share/cmoc/include/os9/cgfx && \
  cp lib/libc.a cgfx/libcgfx.a /usr/share/cmoc/lib/os9 && \
  cp -R include/* /usr/share/cmoc/include/os9 && \
  cp -R cgfx/include/* /usr/share/cmoc/include/os9
WORKDIR ..

# Install java grinder
RUN git clone https://github.com/mikeakohn/naken_asm.git && \
  git clone https://github.com/mikeakohn/java_grinder
WORKDIR naken_asm
RUN git checkout d646de9731302e6187f0199304b8a640282326ef && \
  ./configure && make && make install
WORKDIR ../java_grinder
RUN git checkout a9bcc8f4c4856d64356f50bc0b6234359977cb43 && \
  make && \
  cp java_grinder /usr/local/bin/
WORKDIR ..

# Clean up
RUN apt-get clean

# Convenience for Mac users
RUN ln -s /home /Users
