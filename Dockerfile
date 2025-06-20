FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="Jamie Cho"

# Store stuff in a semi-reasonable spot
WORKDIR /root

# Setup sources
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y curl && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y \
    bc \
    bison \
    build-essential \
    default-jdk \
    dos2unix \
    ffmpeg \
    flex \
    freeglut3-dev \
    fuse \
    g++-10 \
    git \
    imagemagick \
    libcurl4-openssl-dev \
    libfuse-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libglu1-mesa-dev \
    mame-tools \
    markdown \
    mesa-common-dev \
    p7zip \
    pipx \
    python-is-python3 \
    python3 \
    python3-dev \
    python3-tk \
    software-properties-common \
    vim \
    xvfb \
    zlib1g-dev && \
  apt-get clean


RUN python -m venv venv && \
    . venv/bin/activate
ENV VIRTUAL_ENV=/root/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install \
    coco-tools==0.24 \
    milliluk-tools==0.1 \
    mc10-tools==0.9 \
    mypy==1.15.0 \
    numpy==2.2.6 \
    pillow==11.2.1 \
    pypng==0.20220715.0 \
    ruff==0.11.11 \
    uv==0.1.32 \
    wand==0.6.13

# Install lwtools
ADD http://www.lwtools.ca/releases/lwtools/lwtools-4.24.tar.gz lwtools-4.24.tar.gz
RUN tar -zxpvf lwtools-4.24.tar.gz && \
  (cd lwtools-4.24 && make -j install CC=gcc && make clean)

# Install Toolshed
RUN git clone https://github.com/nitros9project/toolshed.git && \
  (cd toolshed && \
   git checkout v2_2 && \
   make -j -C build/unix install CC=gcc)

# Install CMOC
ADD http://sarrazip.com/dev/cmoc-0.1.91.tar.gz cmoc-0.1.91.tar.gz
RUN tar -zxpvf cmoc-0.1.91.tar.gz && \
  (cd cmoc-0.1.91 && ./configure && make && make install && make clean)

# Install key OS-9 defs from nitros-9
RUN git clone https://github.com/nitros9project/nitros9.git && \
  (cd nitros9 && \
  git checkout e490ce8 && \
  mkdir -p /usr/local/share/lwasm && \
  cp -R defs/* /usr/local/share/lwasm/)

# Install java grinder
RUN git clone https://github.com/mikeakohn/naken_asm.git && \
  git clone https://github.com/mikeakohn/java_grinder && \
  (cd naken_asm && \
  git checkout aa692552769c831cf4f937915bb96f618fc04e7e && \
  ./configure && make -j && make install && \
  cd ../java_grinder && \
  git checkout 3aac128792d3293270e19b28d9da6c0b99423fab && \
  make -j && make java && \
  (cd samples/trs80_coco && make -j grind) && \
  cp java_grinder /usr/local/bin/)

# Install tasm and mcbasic
RUN git clone https://github.com/gregdionne/tasm6801.git && \
  git clone https://github.com/gregdionne/mcbasic.git && \
  (cd tasm6801 && \
  git checkout 0820625 && \
  cd src && \
  make -j && \
  cp ../tasm6801 /usr/local/bin && \
  make -j) && \
  (cd mcbasic && \
  git checkout 1030ec4 && \
  make -j && \
  cp mcbasic /usr/local/bin && \
  make clean)

# Install ZX0 data compressor
RUN git clone https://github.com/einar-saukas/ZX0 && \
  (cd "ZX0/src" && \
  make -j CC=gcc CFLAGS=-O3 EXTENSION= && \
  cp zx0 dzx0 /usr/local/bin)

# Install salvador (fast near-optimal ZX0 compressor)
RUN git clone https://github.com/emmanuel-marty/salvador && \
  (cd salvador && \
  git checkout a1b10b03f690ab1fa2f3313d47c9111479114182 && \
  mkdir clang-hack && \
  ln -s /usr/bin/cc clang-hack/clang && \
  (PATH=./clang-hack:$PATH make -j) && \
  rm -r ./clang-hack && \
  cp salvador /usr/local/bin && \
  make clean)

# Create a user for installs
RUN adduser mrinstaller
USER mrinstaller
WORKDIR /home/mrinstaller

# Install qb64
RUN git clone https://github.com/QB64-Phoenix-Edition/QB64pe.git && \
    cd QB64pe && \
    git checkout 56990e1a605cb639acc1ecf30619ec6f4fbcd3fa && \
    ./setup_lnx.sh && \
    (yes | rm -r .git)

# Move qb64 to /root and Install BASIC-To-6809
USER root
WORKDIR /root
RUN mv /home/mrinstaller/QB64pe /root && \
    chown -R root:root /root/QB64pe && \
    (Xvfb :1 -screen 0 800x600x24+32 &) && \
    git clone https://github.com/nowhereman999/BASIC-To-6809.git && \
    export DISPLAY=:1 && \
    cd BASIC-To-6809 && \
    git checkout f0082b2b11dfc46798accca310577adf9a78fd94 && \
    sleep 1 && \
    ../QB64pe/qb64pe BasTo6809.bas -x -o basto6809 && \
    ../QB64pe/qb64pe BasTo6809.1.Tokenizer.bas -x -o BasTo6809.1.Tokenizer && \
    ../QB64pe/qb64pe BasTo6809.2.Compile.bas -x -o BasTo6809.2.Compile
ADD utils/basto6809todsk /usr/local/bin

# Clean up
RUN ln -s /home /Users

# For java_grinder
ENV CLASSPATH=/root/java_grinder/build/JavaGrinder.jar \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8
