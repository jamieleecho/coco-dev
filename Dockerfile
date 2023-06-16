FROM ubuntu:22.04

MAINTAINER Jamie Cho version: 0.49

# Store stuff in a semi-reasonable spot
WORKDIR /root

# Setup sources
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y curl && \
  curl https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb && \
  echo "deb http://security.ubuntu.com/ubuntu focal-security main" | tee /etc/apt/sources.list.d/focal-security.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y \
    bison \
    build-essential \
    default-jdk \
    dos2unix \
    dotnet-sdk-7.0 \
    ffmpeg \
    flex \
    fuse \
    g++-10 \
    git \
    imagemagick \
    libfuse-dev \
    libjpeg-dev \
    libmagickwand-dev \
    mame-tools \
    markdown \
    p7zip \
    python3 \
    python3-dev \
    python3-distutils \
    python3-tk \
    software-properties-common \
    vim \
    zlib1g-dev

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3.10 2 && \
  curl https://bootstrap.pypa.io/get-pip.py | python && \
  pip install \
    mercurial==6.2.2 \
    numpy==1.22.2 \
    Pillow==7.0.0 \
    pypng==0.0.20 \
    setuptools==60.9.3 \
    wand==0.5.7 \
    coco-tools==0.6 \
    milliluk-tools==0.1 \
    mc10-tools==0.5

# Install lwtools
RUN hg clone http://www.lwtools.ca/hg && \
  (cd hg && \
   hg checkout lwtools-4.21 && \
   make && \
   make install)

# Install Toolshed
RUN hg clone http://hg.code.sf.net/p/toolshed/code toolshed-code && \
  (cd toolshed-code && \
   hg up v2_2 && \
   make -C build/unix install CC=gcc)

# Install CMOC
ADD http://perso.b2b2c.ca/~sarrazip/dev/cmoc-0.1.82.tar.gz cmoc-0.1.82.tar.gz
RUN tar -zxpvf cmoc-0.1.82.tar.gz && \
  (cd cmoc-0.1.82 && ./configure && make && make install)

# Install key OS-9 defs from nitros-9
RUN hg clone http://hg.code.sf.net/p/nitros9/code nitros9-code && \
  (cd nitros9-code && \
  hg checkout 6b7a7b233925 && \
  mkdir -p /usr/local/share/lwasm && \
  cp -R defs/* /usr/local/share/lwasm/)

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
  git checkout 03aa546559a86f5ee66569c7c35c998023b1bfc7 && \
  cd src && \
  g++ *.cpp -o tasm6801 && \
  cp tasm6801 /usr/local/bin) && \
  (cd mcbasic && \
  git checkout 35e2a09e3abb22f97c60ac8b2a16f435265cac8a && \
  cd src && \
  g++ -std=c++14 -I. */*.cpp -o ../mcbasic && \
  cp ../mcbasic /usr/local/bin)

# Install ZX0 data compressor
RUN git clone https://github.com/einar-saukas/ZX0 && \
  (cd "ZX0/src" && \
  make CC=gcc CFLAGS=-O3 EXTENSION= && \
  cp zx0 dzx0 /usr/local/bin)

# Install salvador (fast near-optimal ZX0 compressor)
RUN git clone https://github.com/emmanuel-marty/salvador && \
  (cd salvador && \
  git checkout a1b10b03f690ab1fa2f3313d47c9111479114182 && \
  mkdir clang-hack && \
  ln -s /usr/bin/cc clang-hack/clang && \
  (PATH=./clang-hack:$PATH make) && \
  rm -r ./clang-hack && \
  cp salvador /usr/local/bin)

# Install KAOS.Assembler
RUN git clone https://github.com/ChetSimpson/KAOS.Assembler.git && \
  (cd KAOS.Assembler && \
  git checkout 4f61e3f859b76990dd78b56a99fe472e56b5684a && \
  gcc src/*.c -o /usr/local/bin/kasm)

# Install KAOS
RUN curl -L https://github.com/ChetSimpson/KAOSToolkit-Prototype/releases/download/1.0.0/KAOSTKPT.7z -o KAOSTKPT.7z && \
  7zr x KAOSTKPT.7z && \
  cp KAOSTKPT/*.dll KAOSTKPT/*.json /usr/local/bin
COPY kaos/* /usr/local/bin/

# Clean up
RUN ln -s /home /Users && \
    apt-get clean

# For java_grinder
ENV CLASSPATH=/root/java_grinder/build/JavaGrinder.jar \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8
