# coco-dev

This repo implements a simplified environment for developing [Tandy
Color Computer](https://en.wikipedia.org/wiki/TRS-80_Color_Computer)
applications. It implements a Docker image that includes the following tools:

* CoCo Languages and Libraries
  * [BasTo6809 V5.28](https://github.com/nowhereman999/BASIC-To-6809)
  * [CMOC 0.1.98](http://sarrazip.com/dev/cmoc.html)
  * [Java Grinder](http://www.mikekohn.net/micro/java_grinder.php)
  * [LWTOOLS 4.24](http://lwtools.projects.l-w.ca)
  * [naken](http://www.mikekohn.net/micro/naken_asm.php)
  * [nitros9/defs](https://github.com/nitros9project/nitros9/tree/main/defs)

* CoCo Development Utilities
  * [coco-tools 0.27](https://pypi.org/project/coco-tools/)
  * [MAME 0.287](https://www.mamedev.org) (headless, CoCo 3-only build)
  * [MAME Tools](https://packages.ubuntu.com/xenial/utils/mame-tools)
  * [milliluk-tools](https://github.com/milliluk/milliluk-tools)
  * [preprocessor](https://github.com/yggdrasilradio/preprocessor)
  * [salvador](https://github.com/emmanuel-marty/salvador)
  * [ToolShed 2.5](https://github.com/nitros9project/toolshed)
  * [ZX0](https://github.com/einar-saukas/ZX0)

* MC-10
  * [mc10-tools 0.10](https://pypi.org/project/mc10-tools/0.10)
  * [mcbasic](https://github.com/gregdionne/mcbasic)
  * [tasm6801](https://github.com/gregdionne/tasm6801)

* Python and some useful Python packages

## Motivation

This repo is motivated in part by the need to keep the tools in sync
between different computers. Because the Dockerfile contains all of the
dependencies in a single place creating and sharing a reproducible
development environment becomes possible.

## Requirements

* [macOS](https://www.apple.com/macos/high-sierra/) or
  [Linux](https://ubuntu.com)
* [Docker 20](https://www.docker.com)

On Mac systems you must share `/Users` with Docker. To do this:

* From the Docker menu select `Preferences...`
* Click on the `File Sharing` tab
* Click on `+`
* Select `/Users`
* Click `Apply & Restart`

## Using coco-dev

### Shell

```bash
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
coco-dev/coco-dev
```

This will create a Linux shell in your home directory. You can `cd` into
your target folder and use typical development commands such as `lwasm`,
`lwlink`, `decb`, `os9` and `cmoc`

### Dev Containers

coco-dev can be used as a base image for Visual Studio Code Dev Containers.
To get started, simply copy the example `.devcontainer` folder to the root of
your project folder and open the folder in VS Code. See the [documentation](https://code.visualstudio.com/docs/devcontainers/containers) for more information.

### Running MAME headlessly

The image includes a headless, CoCo 3-only build of MAME (the `mame` binary,
in addition to the `mame-tools` utilities). It is compiled with only the
`coco3` driver, so it boots a CoCo 3 but is much smaller than a full MAME
build. The container sets `SDL_VIDEODRIVER=dummy` and `SDL_AUDIODRIVER=dummy`
so MAME runs without a display or sound card.

**ROMs are not included.** The CoCo 3 system ROM is copyrighted and cannot be
distributed, so you must supply it at run time via `-rompath`. MAME expects a
`coco3.zip` containing the CoCo 3 ROM inside the rompath directory.

A typical non-interactive run that boots a disk image and exits after a fixed
amount of emulated time looks like:

```bash
mame coco3 \
  -rompath /path/to/roms \
  -flop1 /path/to/nos9.dsk \
  -flop2 /path/to/test.dsk \
  -video none -sound none \
  -seconds_to_run 60
```

Lua plugins and language files are installed under `/usr/local/share/mame`
(`-pluginspath /usr/local/share/mame/plugins`) for driving MAME with
`-autoboot_script`/`-script` automation.

## Building coco-dev

```bash
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
cd coco-dev
make build
```

Run `make help` to see the available targets. After building, `make test`
runs a quick smoke test that exercises CMOC, BasTo6809, mcbasic, Java
Grinder, and the CoCo 3 MAME build against the built image.

The image is a multi-stage build: a shared `foundation` stage (apt packages,
the Python venv, lwtools and toolshed) followed by one stage per tool, which
BuildKit compiles in parallel. Compile-heavy stages use a `ccache` cache mount,
so rebuilding unchanged sources locally is fast.

Building MAME from source is the slow part of the image build. A few of MAME's
core source files need ~2 GB of RAM each in the compiler, so the job count is
deliberately conservative: it defaults to `MAME_JOBS=2` (~4 GB peak). If your
Docker host has plenty of RAM you can speed the build up by raising it, e.g.:

```bash
make build MAME_JOBS=4
```

Because the tool stages build concurrently, MAME's compile now overlaps with
the other tools', so size `MAME_JOBS` against the RAM you have free *during*
the build, not in isolation. If the build is killed for memory, lower it (down
to `MAME_JOBS=1`) or increase the memory allotted to Docker (Docker Desktop →
Settings → Resources).
