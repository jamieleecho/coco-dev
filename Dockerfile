FROM ubuntu:18.04

MAINTAINER Jamie Cho version: 0.23

# Store stuff in a semi-reasonable spot
WORKDIR /root

# Setup sources
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository ppa:deadsnakes/ppa && \
  add-apt-repository ppa:ubuntu-toolchain-r/test && \
  add-apt-repository ppa:tormodvolden/m6809 && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y \
    bison \
    build-essential \
    curl \
    default-jdk \
    dos2unix \
    ffmpeg \
    flex \
    fuse \
    g++-10 \
    git \
    imagemagick \
    libfuse-dev \
    libmagickwand-dev \
    mame-tools \
    markdown \
    mercurial \
    python \
    python-dev \
    python-pip \
    python3.6 \
    python3.6-dev \
    ruby \
    software-properties-common \
    vim

# Install useful Python tools
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && \
  curl https://bootstrap.pypa.io/get-pip.py | python3
RUN pip2 install \
  numpy==1.16.5 \
  Pillow==6.2.0 \
  pypng==0.0.20 \
  setuptools==41.6.0 \
  wand==0.5.7
RUN pip3 install \
  numpy==1.16.5 \
  Pillow==6.2.0 \
  pypng==0.0.20 \
  setuptools==46.1.1 \
  wand==0.5.7

# Install CoCo Specific stuff
RUN apt-get install -y \
  gcc6809=4.6.4-0~lw9a1~bionic3 \
  lwtools=4.17-0~tormod~bionic

# Install Toolshed
RUN hg clone http://hg.code.sf.net/p/toolshed/code toolshed-code && \
  (cd toolshed-code && \
   hg up v2_2 && \
   make -C build/unix install CC=gcc)

# Install CMOC
ADD http://perso.b2b2c.ca/~sarrazip/dev/cmoc-0.1.68.tar.gz cmoc-0.1.68.tar.gz
RUN tar -zxpvf cmoc-0.1.68.tar.gz && \
  (cd cmoc-0.1.68 && ./configure && make && make install)

# Make python3 the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2

# Install CoCo image conversion scripts
RUN git config --global core.autocrlf input && \
  git clone https://github.com/jamieleecho/coco-tools.git && \
  (cd coco-tools && git checkout 0.3) && \
  (cd coco-tools && python2 setup.py  install) && \
  (cd coco-tools && python3 setup.py install)

# Install milliluk-tools
RUN git config --global core.autocrlf input && \
  git clone https://github.com/milliluk/milliluk-tools.git && \
  (cd milliluk-tools && git checkout 454e7247c892f7153136b9e5e6b12aeeecc9dd36 && \
  dos2unix < cgp220/cgp220.py > /usr/local/bin/cgp220.py && \
  chmod a+x /usr/local/bin/cgp220.py)

# Install tlindner/cmoc_os9
RUN git clone https://github.com/jamieleecho/cmoc_os9.git && \
  (cd cmoc_os9/lib && \
  git checkout fix-cmoc-error && \
  make && \
  cd ../cgfx && \
  make && \
  cd .. && \
  mkdir -p /usr/local/share/cmoc/lib/os9 && \
  mkdir -p /usr/local/share/cmoc/include/os9/cgfx && \
  cp lib/libc.a cgfx/libcgfx.a /usr/local/share/cmoc/lib/os9 && \
  cp -R include/* /usr/local/share/cmoc/include/os9 && \
  cp -R cgfx/include/* /usr/local/share/cmoc/include/os9)

# Install java grinder
RUN git clone https://github.com/mikeakohn/naken_asm.git && \
  git clone https://github.com/mikeakohn/java_grinder && \
  (cd naken_asm && \
  git checkout aa692552769c831cf4f937915bb96f618fc04e7e && \
  ./configure && make && make install && \
  cd ../java_grinder && \
  git checkout 3aac128792d3293270e19b28d9da6c0b99423fab && \
  make && make java && \
  (cd samples/trs80_coco && make grind) && \
  cp java_grinder /usr/local/bin/)

# Install tasm and mcbasic
RUN git clone https://github.com/gregdionne/tasm6801.git && \
  git clone https://github.com/gregdionne/mcbasic.git && \
  (cd tasm6801 && \
  git checkout edf31f10d5a9a2d093d83c3a501e65348f19a223 && \
  cd src && \
  g++ *.cpp -o tasm6801 && \
  cp tasm6801 /usr/local/bin) && \
  (cd mcbasic && \
  git checkout f378f03a8132fcb74cb424d14230e7161c1af217 && \
  cd src && \
  g++-10 -std=c++20 *.cpp -o mcbasic && \
  cp mcbasic /usr/local/bin)

# Clean up
RUN ln -s /home /Users && \
    apt-get clean

# For java_grinder
ENV CLASSPATH=/root/java_grinder/build/JavaGrinder.jar
