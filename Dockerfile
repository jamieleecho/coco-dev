FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04

LABEL org.opencontainers.image.authors="Jamie Cho"

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


# Store stuff in a semi-reasonable spot
USER vscode
WORKDIR /home/vscode

# Install qb64
RUN git clone https://github.com/QB64-Phoenix-Edition/QB64pe.git && \
    cd QB64pe && \
    git checkout v4.2.0 && \
    ./setup_lnx.sh && \
    (yes | rm -r .git)

# Setup default python environment
RUN python -m venv venv && \
    . venv/bin/activate
ENV VIRTUAL_ENV=/home/vscode/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install \
    coco-tools==0.24 \
    milliluk-tools==0.1 \
    mc10-tools==0.9 \
    mypy==1.15.0 \
    numpy==2.2.6 \
    pillow==11.2.1 \
    pypng==0.20220715.0 \
    ruff==0.14.3 \
    uv==0.9.24 \
    wand==0.6.13

# Install preprocessor
RUN git clone https://github.com/yggdrasilradio/preprocessor.git && \
  (cd preprocessor && \
   git checkout 62c4ace79eeffa48817f429363816d79abea77c3 && \
   (sudo cp decbpp /usr/local/bin/)) && \
  (yes | rm -r preprocessor)

# Install ZX0 data compressor
RUN git clone https://github.com/einar-saukas/ZX0 && \
  (cd "ZX0/src" && \
   make -j CC=gcc CFLAGS=-O3 EXTENSION= && \
   (sudo cp zx0 dzx0 /usr/local/bin))

# Install salvador (fast near-optimal ZX0 compressor)
RUN git clone https://github.com/emmanuel-marty/salvador && \
  (cd salvador && \
   git checkout 1662b625a8dcd6f3f7e3491c88840611776533f5 && \
   mkdir clang-hack && \
   ln -s /usr/bin/cc clang-hack/clang && \
   (PATH=./clang-hack:$PATH make -j) && \
   rm -r ./clang-hack && \
   (sudo cp salvador /usr/local/bin) && \
   make clean)

# Install lwtools
RUN curl -O http://www.lwtools.ca/releases/lwtools/lwtools-4.24.tar.gz && \
  tar -zxpvf lwtools-4.24.tar.gz && \
  (cd lwtools-4.24 && \
   make -j CC=gcc && \
   (sudo make install) && \
   make clean)

# Install Toolshed
RUN git clone https://github.com/nitros9project/toolshed.git && \
  (cd toolshed && \
   git checkout v2_4_2 && \
   make -j -C build/unix CC=gcc && \
   (sudo make -C build/unix install))

# Install key OS-9 defs from nitros-9
RUN git clone https://github.com/nitros9project/nitros9.git && \
  (cd nitros9 && \
   git checkout 27c67d5c445db631abfd5b45d49870364d9eacb6 && \
   (sudo mkdir -p /usr/local/share/lwasm) && \
   (sudo cp -R defs/* /usr/local/share/lwasm/))

# Install java grinder
RUN git clone https://github.com/mikeakohn/naken_asm.git && \
  git clone https://github.com/mikeakohn/java_grinder && \
  (cd naken_asm && \
   git checkout b6e83f1976a5fa0b1a371bd4d6db935a386b95ef && \
   ./configure && \
   make -j && \
   (sudo make install) && \
   cd ../java_grinder && \
   git checkout 4dca222bae458766c320f045c015754aa6c17376 && \
   make -j && \
   make java && \
   (cd samples/trs80_coco && make -j grind) && \
   (sudo cp java_grinder /usr/local/bin/))

# Install tasm and mcbasic
RUN git clone https://github.com/gregdionne/tasm6801.git && \
  git clone https://github.com/gregdionne/mcbasic.git && \
  (cd tasm6801 && \
   git checkout 0820625 && \
   cd src && \
   make -j && \
   (sudo cp ../tasm6801 /usr/local/bin) && \
   make -j) && \
   (cd mcbasic && \
    git checkout 1030ec4 && \
    make -j && \
    (sudo cp mcbasic /usr/local/bin) && \
   make clean)

# Install CMOC
RUN curl -LO http://sarrazip.com/dev/cmoc-0.1.97.tar.gz && \
  tar -zxpvf cmoc-0.1.97.tar.gz && \
  (cd cmoc-0.1.97 && \
   ./configure && \
   make && \
   (sudo make install) && \
   make clean)

# Build and install BASIC-To-6809
RUN (Xvfb :1 -screen 0 800x600x24+32 &) && \
     git clone https://github.com/nowhereman999/BASIC-To-6809.git && \
     export DISPLAY=:1 && \
     cd BASIC-To-6809 && \
     git checkout 2e97cc0f52bb5163a14358248142ecc854b86c8c && \
     sleep 1 && \
     ../QB64pe/qb64pe BasTo6809.bas -x -f:OptimizeCppProgram=false -o basto6809 && \
     ../QB64pe/qb64pe BasTo6809.1.Tokenizer.bas -x -f:OptimizeCppProgram=false -o BasTo6809.1.Tokenizer && \
     ../QB64pe/qb64pe BasTo6809.2.Compile.bas -x -f:OptimizeCppProgram=false -o BasTo6809.2.Compile && \
     ../QB64pe/qb64pe cc1sl.bas -x -f:OptimizeCppProgram=false -o cc1sl && \
     ../QB64pe/qb64pe PNGtoCC3Playfield.bas -x -f:OptimizeCppProgram=false -o PNGtoCC3Playfield && \
     ../QB64pe/qb64pe PNGtoCCSB.bas -x -f:OptimizeCppProgram=false -o PNGtoCCSB && \
     (sudo cp Manual.pdf /usr/local/share/doc/basto6809.pdf)
  ADD utils/basto6809todsk /usr/local/bin

# Link so things work nicely with macOS
RUN sudo ln -s /home /Users

# For java_grinder
ENV CLASSPATH=/home/vscode/java_grinder/build/JavaGrinder.jar \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8
