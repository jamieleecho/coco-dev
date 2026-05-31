# syntax=docker/dockerfile:1
#
# Multi-stage build.
#
# `foundation` holds everything shared by every later build: the apt packages,
# the Python venv, and the two foundational toolchain pieces (lwtools and
# toolshed) that other builds may rely on. Every remaining tool is built in its
# own stage `FROM foundation`, so BuildKit compiles them concurrently and a
# change to one tool no longer invalidates the others' cache. Each tool stage
# installs into an isolated `/staging` prefix; the `final` stage assembles the
# image with one `COPY --from=<tool> /staging/ /` per tool.
#
# Compile-heavy stages (mame, cmoc, java_grinder, lwtools, toolshed, zx0) use a
# ccache BuildKit cache mount, so recompiling the same source (e.g. after a
# cache-busting change or a `--no-cache` of an unrelated layer) is near-instant
# locally. CI passes a higher MAME_JOBS where the runner has the RAM for it.

FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04 AS foundation

LABEL org.opencontainers.image.authors="Jamie Cho"

# Setup sources
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y \
    bison \
    build-essential \
    ccache \
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

# Shared ccache directory for the compile-heavy stages below. The cache lives
# in a BuildKit cache mount (not the image); cap it so it can't grow unbounded
# across local rebuilds.
ENV CCACHE_DIR=/root/.ccache \
    CCACHE_MAXSIZE=2G

# --- Foundational toolchain (other build stages may depend on these) ---

# Install lwtools
RUN --mount=type=cache,target=/root/.ccache,sharing=shared \
  curl -O http://www.lwtools.ca/releases/lwtools/lwtools-4.24.tar.gz && \
  tar -zxpvf lwtools-4.24.tar.gz && \
  cd lwtools-4.24 && \
  make -j CC="ccache gcc" && \
  make install && \
  cd /root && rm -rf lwtools-4.24 lwtools-4.24.tar.gz

# Install Toolshed
RUN --mount=type=cache,target=/root/.ccache,sharing=shared \
  git clone https://github.com/nitros9project/toolshed.git && \
  cd toolshed && \
  git checkout v2_5 && \
  make -j -C build/unix CC="ccache gcc" && \
  make -C build/unix install && \
  cd /root && rm -rf toolshed


# ===========================================================================
# Parallel tool stages. Each is independent and FROM foundation, and installs
# into /staging (mirroring the final layout) so `final` can COPY it in.
# ===========================================================================

# Install preprocessor
FROM foundation AS preproc
RUN git clone https://github.com/yggdrasilradio/preprocessor.git && \
  (cd preprocessor && \
   git checkout 62c4ace79eeffa48817f429363816d79abea77c3 && \
   mkdir -p /staging/usr/local/bin && \
   cp decbpp /staging/usr/local/bin/) && \
  (yes | rm -r preprocessor)

# Install ZX0 data compressor
FROM foundation AS zx0
RUN --mount=type=cache,target=/root/.ccache,sharing=shared \
  git clone https://github.com/einar-saukas/ZX0 && \
  cd "ZX0/src" && \
  make -j CC="ccache gcc" CFLAGS=-O3 EXTENSION= && \
  mkdir -p /staging/usr/local/bin && \
  cp zx0 dzx0 /staging/usr/local/bin && \
  cd /root && rm -rf ZX0

# Install salvador (fast near-optimal ZX0 compressor)
FROM foundation AS salvador
RUN git clone https://github.com/emmanuel-marty/salvador && \
  cd salvador && \
  git checkout 1662b625a8dcd6f3f7e3491c88840611776533f5 && \
  mkdir clang-hack && \
  ln -s /usr/bin/cc clang-hack/clang && \
  (PATH=./clang-hack:$PATH make -j) && \
  rm -r ./clang-hack && \
  mkdir -p /staging/usr/local/bin && \
  cp salvador /staging/usr/local/bin && \
  cd /root && rm -rf salvador

# Install key OS-9 defs from nitros-9
FROM foundation AS nitros9
RUN git clone https://github.com/nitros9project/nitros9.git && \
  cd nitros9 && \
  git checkout 27c67d5c445db631abfd5b45d49870364d9eacb6 && \
  mkdir -p /staging/usr/local/share/lwasm && \
  cp -R defs/* /staging/usr/local/share/lwasm/ && \
  cd /root && rm -rf nitros9

# Install java grinder (and naken_asm, which builds it and runs the tests)
FROM foundation AS jgrinder
RUN --mount=type=cache,target=/root/.ccache,sharing=shared \
  git clone https://github.com/mikeakohn/naken_asm.git && \
  git clone https://github.com/mikeakohn/java_grinder && \
  cd naken_asm && \
  git checkout b6e83f1976a5fa0b1a371bd4d6db935a386b95ef && \
  ./configure && \
  make CC="ccache gcc" && \
  make install && \
  cd ../java_grinder && \
  git checkout 4dca222bae458766c320f045c015754aa6c17376 && \
  make -j CC="ccache gcc" CXX="ccache g++" && \
  make java && \
  (cd samples/trs80_coco && make -j grind) && \
  mkdir -p /staging/usr/local/bin /staging/usr/local/share/java_grinder && \
  cp /usr/local/bin/naken_asm /usr/local/bin/naken_util /staging/usr/local/bin/ && \
  cp -R /usr/local/share/naken_asm /staging/usr/local/share/ && \
  cp java_grinder /staging/usr/local/bin/ && \
  cp build/JavaGrinder.jar /staging/usr/local/share/java_grinder/ && \
  cd /root && rm -rf naken_asm java_grinder

# Install tasm6801
FROM foundation AS tasm
RUN git clone https://github.com/gregdionne/tasm6801.git && \
  cd tasm6801 && \
  git checkout 0820625bf8e78053ced348a3d747191d54e5e24f && \
  cd src && \
  make -j && \
  mkdir -p /staging/usr/local/bin && \
  cp ../tasm6801 /staging/usr/local/bin && \
  cd /root && rm -rf tasm6801

# Install mcbasic
FROM foundation AS mcbasic
RUN git clone https://github.com/gregdionne/mcbasic.git && \
  cd mcbasic && \
  git checkout 1030ec4413df400e07709a9aabffcaaf4772eb82 && \
  make -j && \
  mkdir -p /staging/usr/local/bin && \
  cp mcbasic /staging/usr/local/bin && \
  cd /root && rm -rf mcbasic

# Install CMOC
FROM foundation AS cmoc
RUN --mount=type=cache,target=/root/.ccache,sharing=shared \
  curl -LO http://sarrazip.com/dev/cmoc-0.1.98.tar.gz && \
  tar -zxpvf cmoc-0.1.98.tar.gz && \
  cd cmoc-0.1.98 && \
  ./configure CC="ccache gcc" CXX="ccache g++" && \
  make && \
  make install DESTDIR=/staging && \
  cd /root && rm -rf cmoc-0.1.98 cmoc-0.1.98.tar.gz

# Build and install BASIC-To-6809
FROM foundation AS basto
RUN git clone https://github.com/nowhereman999/BASIC-To-6809.git && \
     cd BASIC-To-6809 && \
     git checkout 0e60e91fae063324fb9608f0117f6e9ac0582125 && \
     mkdir -p /staging/usr/local/share/doc && \
     cp Manual.pdf /staging/usr/local/share/doc/basto6809.pdf && \
     cd Binary_Versions && \
     if [ "$(uname -m)" = "aarch64" ]; then \
       unzip BASIC-To-6809_v5.28_Linux_arm64.zip -d /tmp/basto6809 && \
       mv /tmp/basto6809/BASIC-To-6809_Linux_arm64 /staging/usr/local/share/basto6809; \
     else \
       unzip BASIC-To-6809_v5.28_Linux_x86_64.zip -d /tmp/basto6809 && \
       mv /tmp/basto6809/BASIC-To-6809_Linux_x86_64 /staging/usr/local/share/basto6809; \
     fi && \
     mv "/staging/usr/local/share/basto6809/BasTo6809.2.Compile copy" "/staging/usr/local/share/basto6809/BasTo6809.2.Compile" && \
     chmod -R o+rx /staging/usr/local/share/basto6809 && \
     cd /root && rm -rf BASIC-To-6809 /tmp/basto6809

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
# or raise it (e.g. --build-arg MAME_JOBS=4) when there is RAM to spare; CI
# passes MAME_JOBS=4 because the hosted runners have 16GB.
FROM foundation AS mame
ARG MAME_VERSION=0287
ARG MAME_JOBS=2
RUN --mount=type=cache,target=/root/.ccache,sharing=shared \
  git clone --depth 1 --branch mame$MAME_VERSION \
      https://github.com/mamedev/mame.git && \
  cd mame && \
  make -j"$MAME_JOBS" \
    SUBTARGET=coco \
    SOURCES=src/mame/trs/coco3.cpp \
    REGENIE=1 \
    TOOLS=0 \
    USE_QTDEBUG=0 \
    NO_USE_PORTAUDIO=1 \
    PYTHON_EXECUTABLE=python3 \
    OVERRIDE_CC="ccache gcc" \
    OVERRIDE_CXX="ccache g++" && \
  mkdir -p /staging/usr/local/bin && \
  (install -m 0755 coco /staging/usr/local/bin/mame 2>/dev/null || \
   install -m 0755 mamecoco /staging/usr/local/bin/mame) && \
  mkdir -p /staging/usr/local/share/mame && \
  cp -R plugins language /staging/usr/local/share/mame/ && \
  chmod -R o+rx /staging/usr/local/share/mame && \
  cd /root && rm -rf mame


# ===========================================================================
# Final image: foundation plus every tool's staged artifacts.
# ===========================================================================
FROM foundation AS final

COPY --from=preproc  /staging/ /
COPY --from=zx0      /staging/ /
COPY --from=salvador /staging/ /
COPY --from=nitros9  /staging/ /
COPY --from=jgrinder /staging/ /
COPY --from=tasm     /staging/ /
COPY --from=mcbasic  /staging/ /
COPY --from=cmoc     /staging/ /
COPY --from=basto    /staging/ /
COPY --from=mame     /staging/ /

COPY utils/basto6809todsk /usr/local/bin

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
