# coco-dev
This repo implements a simplified environment for developing [Tandy
Color Computer](https://en.wikipedia.org/wiki/TRS-80_Color_Computer)
applications. It implements a Docker image that includes the following tools:
* CoCo Languages and Libraries
  * [BasTo6809 V4.01]()
  * [CMOC 0.1.90](http://perso.b2b2c.ca/~sarrazip/dev/cmoc.html)
  * [Java Grinder](http://www.mikekohn.net/micro/java_grinder.php)
  * [LWTOOLS 4.22](http://lwtools.projects.l-w.ca)
  * [naken](http://www.mikekohn.net/micro/naken_asm.php)
  * [nitros9/defs](https://github.com/nitros9project/nitros9/tree/main/defs)

* CoCo Development Utilities
  * [coco-tools 0.19](https://github.com/jamieleecho/coco-tools)
  * [MAME Tools](https://packages.ubuntu.com/xenial/utils/mame-tools)
  * [milliluk-tools](https://github.com/milliluk/milliluk-tools)
  * [salvador](https://github.com/emmanuel-marty/salvador)
  * [ToolShed 2.2](https://sourceforge.net/p/toolshed/wiki/Home/)
  * [ZX0](https://github.com/einar-saukas/ZX0)

* MC-10
  * [mc10-tools 0.8](https://github.com/jamieleecho/mc10-tools)
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
  [Linux](https://www.debian.org)
* [Docker 20](https://www.docker.com)

On Mac systems you must share `/Users` with Docker. To do this:
* From the Docker menu select `Preferences...`
* Click on the `File Sharing` tab
* Click on `+`
* Select `/Users`
* Click `Apply & Restart`


## Using coco-dev
```
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
coco-dev/coco-dev
```
This will create a Linux shell in your home directory. You can `cd` into
your target folder and use typical development commands such as `lwasm`,
`lwlink`, `decb`, `os9` and `cmoc`


## Building coco-dev
```
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
cd coco-dev
./build
```
