FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04

LABEL org.opencontainers.image.authors="Jamie Cho"

# Setup sources
RUN export DEBIAN_FRONTEND=noninteractive && \
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
    freeglut3-dev \
    fuse \
    git \
    imagemagick \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfuse-dev \
    libglu1-mesa-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    mame-tools \
    markdown \
    mesa-common-dev \
    p7zip \
    pipx \
    python-is-python3 \
    python3 \
    python3-dev \
    python3-tk \
    vim \
    zlib1g-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /root

# Setup default python environment
RUN python -m venv venv
ENV VIRTUAL_ENV=/root/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install \
    coco-tools==0.27 \
    milliluk-tools==0.1 \
    mc10-tools==0.10 \
    mypy==1.20.2 \
    numpy==2.4.4 \
    pillow==12.2.0 \
    pypng==0.20220715.0 \
    ruff==0.15.12 \
    ty==0.0.34 \
    uv==0.11.8 \
    wand==0.7.0 && \
    chmod o+rx /root /root/venv

# Install preprocessor
RUN git clone https://github.com/yggdrasilradio/preprocessor.git && \
  (cd preprocessor && \
   git checkout 62c4ace79eeffa48817f429363816d79abea77c3 && \
   cp decbpp /usr/local/bin/) && \
  (yes | rm -r preprocessor)

# Install ZX0 data compressor
RUN git clone https://github.com/einar-saukas/ZX0 && \
  cd "ZX0/src" && \
  make -j CC=gcc CFLAGS=-O3 EXTENSION= && \
  cp zx0 dzx0 /usr/local/bin && \
  cd /root && rm -rf ZX0

# Install salvador (fast near-optimal ZX0 compressor)
RUN git clone https://github.com/emmanuel-marty/salvador && \
  cd salvador && \
  git checkout 1662b625a8dcd6f3f7e3491c88840611776533f5 && \
  mkdir clang-hack && \
  ln -s /usr/bin/cc clang-hack/clang && \
  (PATH=./clang-hack:$PATH make -j) && \
  rm -r ./clang-hack && \
  cp salvador /usr/local/bin && \
  cd /root && rm -rf salvador

# Install lwtools
RUN curl -O http://www.lwtools.ca/releases/lwtools/lwtools-4.24.tar.gz && \
  tar -zxpvf lwtools-4.24.tar.gz && \
  cd lwtools-4.24 && \
  make -j CC=gcc && \
  make install && \
  cd /root && rm -rf lwtools-4.24 lwtools-4.24.tar.gz

# Install Toolshed
RUN git clone https://github.com/nitros9project/toolshed.git && \
  cd toolshed && \
  git checkout v2_5 && \
  make -j -C build/unix CC=gcc && \
  make -C build/unix install && \
  cd /root && rm -rf toolshed

# Install key OS-9 defs from nitros-9
RUN git clone https://github.com/nitros9project/nitros9.git && \
  cd nitros9 && \
  git checkout 27c67d5c445db631abfd5b45d49870364d9eacb6 && \
  mkdir -p /usr/local/share/lwasm && \
  cp -R defs/* /usr/local/share/lwasm/ && \
  cd /root && rm -rf nitros9

# Install java grinder
RUN git clone https://github.com/mikeakohn/naken_asm.git && \
  git clone https://github.com/mikeakohn/java_grinder && \
  cd naken_asm && \
  git checkout b6e83f1976a5fa0b1a371bd4d6db935a386b95ef && \
  ./configure && \
  make -j && \
  make install && \
  cd ../java_grinder && \
  git checkout 4dca222bae458766c320f045c015754aa6c17376 && \
  make -j && \
  make java && \
  (cd samples/trs80_coco && make -j grind) && \
  cp java_grinder /usr/local/bin/ && \
  mkdir -p /usr/local/share/java_grinder && \
  cp build/JavaGrinder.jar /usr/local/share/java_grinder/ && \
  cd /root && rm -rf naken_asm java_grinder

# Install tasm and mcbasic
RUN git clone https://github.com/gregdionne/tasm6801.git && \
  git clone https://github.com/gregdionne/mcbasic.git && \
  cd tasm6801 && \
  git checkout 0820625bf8e78053ced348a3d747191d54e5e24f && \
  cd src && \
  make -j && \
  cp ../tasm6801 /usr/local/bin && \
  cd ../../mcbasic && \
  git checkout 1030ec4413df400e07709a9aabffcaaf4772eb82 && \
  make -j && \
  cp mcbasic /usr/local/bin && \
  cd /root && rm -rf tasm6801 mcbasic

# Install CMOC
RUN curl -LO http://sarrazip.com/dev/cmoc-0.1.98.tar.gz && \
  tar -zxpvf cmoc-0.1.98.tar.gz && \
  cd cmoc-0.1.98 && \
  ./configure && \
  make && \
  make install && \
  cd /root && rm -rf cmoc-0.1.98 cmoc-0.1.98.tar.gz

# Build and install BASIC-To-6809
RUN git clone https://github.com/nowhereman999/BASIC-To-6809.git && \
     cd BASIC-To-6809 && \
     git checkout 0e60e91fae063324fb9608f0117f6e9ac0582125 && \
     cp Manual.pdf /usr/local/share/doc/basto6809.pdf && \
     cd Binary_Versions && \
     if [ "$(uname -m)" = "aarch64" ]; then \
       unzip BASIC-To-6809_v5.28_Linux_arm64.zip -d /tmp/basto6809 && \
       mv /tmp/basto6809/BASIC-To-6809_Linux_arm64 /usr/local/share/basto6809; \
     else \
       unzip BASIC-To-6809_v5.28_Linux_x86_64.zip -d /tmp/basto6809 && \
       mv /tmp/basto6809/BASIC-To-6809_Linux_x86_64 /usr/local/share/basto6809; \
     fi && \
     mv "/usr/local/share/basto6809/BasTo6809.2.Compile copy" "/usr/local/share/basto6809/BasTo6809.2.Compile" && \
     chmod -R o+rx /usr/local/share/basto6809 && \
     cd /root && rm -rf BASIC-To-6809 /tmp/basto6809
COPY utils/basto6809todsk /usr/local/bin

# Build and install a headless, CoCo 3-only MAME.
#
# Only the coco3.cpp driver (and its dependencies) is compiled, which keeps
# the binary small compared to a full MAME build. The result runs headlessly
# (no display/audio needed) via `-video none -sound none` plus the SDL dummy
# drivers; see the README for the test-runner invocation. ROMs are NOT shipped
# (they are copyrighted) and must be supplied at run time with `-rompath`.
#
# MAME's core has several very large translation units (luaengine, emumem) that
# each need ~2GB of RAM in the compiler, so the job count is kept low to avoid
# the OOM killer (MAME_JOBS=2 needs ~4GB). Lower it to 1 on a RAM-starved host,
# or raise it (e.g. --build-arg MAME_JOBS=4) when there is RAM to spare.
ARG MAME_VERSION=0287
ARG MAME_JOBS=2
RUN git clone --depth 1 --branch mame$MAME_VERSION \
      https://github.com/mamedev/mame.git && \
  cd mame && \
  make -j"$MAME_JOBS" \
    SUBTARGET=coco \
    SOURCES=src/mame/trs/coco3.cpp \
    REGENIE=1 \
    TOOLS=0 \
    USE_QTDEBUG=0 \
    NO_USE_PORTAUDIO=1 \
    PYTHON_EXECUTABLE=python3 && \
  (install -m 0755 coco /usr/local/bin/mame 2>/dev/null || \
   install -m 0755 mamecoco /usr/local/bin/mame) && \
  mkdir -p /usr/local/share/mame && \
  cp -R plugins language /usr/local/share/mame/ && \
  chmod -R o+rx /usr/local/share/mame && \
  cd /root && rm -rf mame

# Link so things work nicely with macOS
RUN ln -s /home /Users

# For java_grinder
ENV CLASSPATH=/usr/local/share/java_grinder/JavaGrinder.jar \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Run MAME headlessly by default (no display/audio). Override these at run time
# if you ever attach a real display (e.g. X forwarding).
ENV SDL_VIDEODRIVER=dummy \
    SDL_AUDIODRIVER=dummy
