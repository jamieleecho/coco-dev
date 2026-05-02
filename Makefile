.DEFAULT_GOAL := help
.PHONY: help build test push clean

IMAGE := jamieleecho/coco-dev
VERSION := $(shell sed -nE 's/.*"version" *: *"([^"]+)".*/\1/p' package.json)
TAG ?= $(IMAGE):$(VERSION)

help:
	@echo "coco-dev Makefile targets:"
	@echo ""
	@echo "  make build  Build the docker image and tag as $(TAG)"
	@echo "  make test   Run smoke tests inside the built image"
	@echo "  make push   Push the image to Docker Hub"
	@echo "  make clean  Remove the local image"
	@echo "  make help   Show this help (default)"
	@echo ""
	@echo "Override the tag with TAG=...  (e.g. make test TAG=jamieleecho/coco-dev:0.79)"

build:
	docker compose -f docker-compose.build.yml build

test:
	docker run --rm -v "$(CURDIR)/tests:/sources:ro" $(TAG) bash -euc '\
		work=$$(mktemp -d); \
		cp /sources/* $$work/; \
		cd $$work; \
		echo "[1/4] java_grinder -> .bin"; \
		javac Hello.java; \
		java_grinder Hello.class Hello.asm trs80_coco; \
		naken_asm -l -type bin -o Hello.bin Hello.asm; \
		test -s Hello.bin; \
		echo "[2/4] basto6809todsk -> .DSK"; \
		basto6809todsk HELLO.BAS; \
		test -s HELLO.DSK; \
		echo "[3/4] mcbasic -> .c10"; \
		mcbasic MC10HELLO.BAS; \
		test -s MC10HELLO.c10; \
		echo "[4/4] cmoc --os9 -> OS-9 module"; \
		cmoc --os9 hello.c; \
		test -s hello; \
		echo "All smoke tests passed."'

push:
	docker push $(TAG)

clean:
	-docker rmi $(TAG)
