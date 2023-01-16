# coco-dev
This repo implements a simplified environment for developing [Tandy
Color Computer](https://en.wikipedia.org/wiki/TRS-80_Color_Computer)
applications. It implements a Docker image that includes the following tools:
* CoCo Languages and Libraries
  * [CMOC 0.1.80](http://perso.b2b2c.ca/~sarrazip/dev/cmoc.html)
  * [KAOS.Assembler](https://github.com/ChetSimpson/KAOS.Assembler)
  * [KAOSToolkit-Prototype 1.0.0](https://github.com/ChetSimpson/KAOSToolkit-Prototype)
  * [Java Grinder](http://www.mikekohn.net/micro/java_grinder.php)
  * [LWTOOLS 4.20+](http://lwtools.projects.l-w.ca)
  * [naken](http://www.mikekohn.net/micro/naken_asm.php)
  * [nitros9/defs](https://sourceforge.net/p/nitros9/code/ci/default/tree/defs/)
  * [tlindner/cmoc\_os9](https://github.com/tlindner/cmoc_os9)

* CoCo Development Utilities
  * [coco-tools 0.5](https://github.com/jamieleecho/coco-tools)
  * [MAME Tools](https://packages.ubuntu.com/xenial/utils/mame-tools)
  * [milliluk-tools](https://github.com/milliluk/milliluk-tools)
  * [salvador](https://github.com/emmanuel-marty/salvador)
  * [ToolShed 2.2](https://sourceforge.net/p/toolshed/wiki/Home/)
  * [ZX0](https://github.com/einar-saukas/ZX0)

* MC-10
  * [mc10-tools 0.5](https://github.com/jamieleecho/mc10-tools)
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


### Using KAOS on coco-dev
This version of coco-dev includes support for KAOSToolkit-Prototype as
KAOS.Assembler. There are 4 command line tools that can be invoked using UNIX
calling conventions, particularly using lower case letters instead of
uppercase letters. Some examples:
```
./coco-dev kasm sprite1.asm
./coco-dev kaospp -opalette.asm -ppalette.gpl -ftc1014
./coco-dev kaostc --texture=sprite1.png --palette=palette.gpl --label-prefix=MySprite_ --pitch=128 --bpp=4 --cursor-register=Y --restore-cursor --output-file=sprite1.asm
./coco-dev kaostp --output-file texture.raw -t texture.png -p palette.gpl
```


## Building coco-dev
```
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
cd coco-dev
./build
```
