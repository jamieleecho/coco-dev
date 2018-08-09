FROM ubuntu:16.04

MAINTAINER Jamie Cho version: 0.8

# Setup sources
RUN apt-get update && apt-get install -y \
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
  cmoc=0.1.52-0~tormod \
  gcc6809=4.6.4-0~lw9a~trusty \
  lwtools=4.15-0~tormod~trusty \
  toolshed=2.2-0~tormod

# Install CoCo image conversion scripts
COPY scripts/* /usr/local/bin/

# Install milliluk-tools
WORKDIR /root
RUN git config --global core.autocrlf input && \
  git clone https://github.com/milliluk/milliluk-tools.git && \
  (cd milliluk-tools && git checkout 454e7247c892f7153136b9e5e6b12aeeecc9dd36 && \
  dos2unix < cgp220/cgp220.py > /usr/local/bin/cgp220.py && \
  dos2unix < max2png/max2png.py > /usr/local/bin/max2png.py) && \
  chmod a+x /usr/local/bin/cgp220.py /usr/local/bin/max2png.py 

# Install boisy/cmoc_os9
RUN git clone https://github.com/tlindner/cmoc_os9.git
WORKDIR cmoc_os9/lib
RUN git checkout f843083a3c260d51d8ca118eca0565a50530a36f && \
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
RUN git checkout 79d8eb05b77f23f4225282f635c9ee8ec9398ca6 && \
  ./configure && make && make install
WORKDIR ../java_grinder
RUN git checkout 7d5e279c8b52c99414ded785b0ef8065dead55eb && \
  make && cp java_grinder /usr/local/bin/
WORKDIR ..

# Clean up
RUN apt-get clean
