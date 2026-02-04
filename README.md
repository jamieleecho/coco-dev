# coco-dev

This repo implements a simplified environment for developing [Tandy
Color Computer](https://en.wikipedia.org/wiki/TRS-80_Color_Computer)
applications. It implements a Docker image that includes the following tools:

* CoCo Languages and Libraries
  * [BasTo6809 V4.43](https://github.com/nowhereman999/BASIC-To-6809)
  * [CMOC 0.1.97](http://sarrazip.com/dev/cmoc.html)
  * [Java Grinder](http://www.mikekohn.net/micro/java_grinder.php)
  * [LWTOOLS 4.24](http://lwtools.projects.l-w.ca)
  * [naken](http://www.mikekohn.net/micro/naken_asm.php)
  * [nitros9/defs](https://github.com/nitros9project/nitros9/tree/main/defs)

* CoCo Development Utilities
  * [coco-tools 0.26](https://pypi.org/project/coco-tools/)
  * [MAME Tools](https://packages.ubuntu.com/xenial/utils/mame-tools)
  * [milliluk-tools](https://github.com/milliluk/milliluk-tools)
  * [preprocessor](https://github.com/yggdrasilradio/preprocessor)
  * [salvador](https://github.com/emmanuel-marty/salvador)
  * [ToolShed 2.4.2](https://github.com/nitros9project/toolshed)
  * [ZX0](https://github.com/einar-saukas/ZX0)

* MC-10
  * [mc10-tools 0.9](https://pypi.org/project/mc10-tools/0.9)
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

## Building coco-dev

```bash
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
cd coco-dev
./build
```
