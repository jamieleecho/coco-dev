# coco-dev
This repo implements a simplified environment for developing [Tandy
Color Computer](https://en.wikipedia.org/wiki/TRS-80_Color_Computer)
applications. It implements a Docker image that includes the following tools:
* [LWTOOLS 4.14](http://lwtools.projects.l-w.ca)
* [ToolShed 2.2](https://sourceforge.net/p/toolshed/wiki/Home/)
* [CMOC 0.1.45](http://perso.b2b2c.ca/~sarrazip/dev/cmoc.html)
* Image conversion scripts by Mathieu Bouchard
* Python and Ruby as well as some useful Python packages


## Motivation
This repo is motivated in part by the need to keep the tools in sync
between different computers. Because the Dockerfile contains all of the
dependencies in a single place creating and sharing a reproducible
development environment becomes possible.


## Requirements
* [macOS](https://www.apple.com/macos/high-sierra/) or
  [Linux](https://www.debian.org)
* [Docker 17](https://www.docker.com)

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
cd coco-dev
./coco-dev
```

This will create a Linux shell in your home directory. You can `cd` into
your target folder and use typical development commands such as `lwasm`,
`lwlink`, `decb`, `os9` and `cmoc`


## Building coco-dev
```
# Start the Docker application if it is not already running
git clone https://github.com/jamieleecho/coco-dev.git
cd coco-dev
docker-compose -f docker-compose.build build
```


