.DEFAULT_GOAL := help
.PHONY: help build test shell lint size push clean

IMAGE := jamieleecho/coco-dev
VERSION := $(shell sed -nE 's/.*"version" *: *"([^"]+)".*/\1/p' package.json)
TAG ?= $(IMAGE):$(VERSION)
SHELLCHECK_IMAGE := koalaman/shellcheck-alpine:stable

help:
	@echo "coco-dev Makefile targets:"
	@echo ""
	@echo "  make build  Build the docker image and tag as $(TAG)"
	@echo "  make test   Run smoke tests inside the built image"
	@echo "  make shell  Drop into a one-off bash shell in the image"
	@echo "  make lint   Run shellcheck on the shell scripts"
	@echo "  make size   Print the size of the built image"
	@echo "  make push   Push the image to Docker Hub"
	@echo "  make clean  Remove the local image"
	@echo "  make help   Show this help (default)"
	@echo ""
	@echo "Override the tag with TAG=...  (e.g. make test TAG=jamieleecho/coco-dev:0.79)"

build:
	docker compose -f docker-compose.build.yml build \
		$(if $(MAME_JOBS),--build-arg MAME_JOBS=$(MAME_JOBS))

test:
	docker run --rm -v "$(CURDIR)/tests:/sources:ro" $(TAG) bash -euc '\
		echo "[1/5] java_grinder -> .bin"; \
		work=$$(mktemp -d); cp /sources/java_grinder/* $$work/; cd $$work; \
		javac Hello.java; \
		java_grinder Hello.class Hello.asm trs80_coco; \
		naken_asm -l -type bin -o Hello.bin Hello.asm; \
		test -s Hello.bin; \
		echo "[2/5] basto6809todsk -> .DSK"; \
		work=$$(mktemp -d); cp /sources/basto6809/* $$work/; cd $$work; \
		basto6809todsk HELLO.BAS; \
		test -s HELLO.DSK; \
		echo "[3/5] mcbasic -> .c10"; \
		work=$$(mktemp -d); cp /sources/mcbasic/* $$work/; cd $$work; \
		mcbasic MC10HELLO.BAS; \
		test -s MC10HELLO.c10; \
		echo "[4/5] cmoc --os9 -> OS-9 module"; \
		work=$$(mktemp -d); cp /sources/cmoc-os9/* $$work/; cd $$work; \
		cmoc --os9 hello.c; \
		test -s hello; \
		echo "[5/5] mame coco3 driver present + headless"; \
		mame -listfull coco3 | grep -qw coco3; \
		mame -validate coco3 >/dev/null; \
		echo "All smoke tests passed."'

shell:
	docker run --rm -it $(TAG) bash

lint:
	docker run --rm -v "$(CURDIR):/work" -w /work $(SHELLCHECK_IMAGE) \
		shellcheck coco-dev utils/basto6809todsk

size:
	@bytes=$$(docker image inspect --format='{{.Size}}' $(TAG)); \
	awk -v b=$$bytes 'BEGIN { printf "%s: %.2f MB\n", "$(TAG)", b/1024/1024 }'

push:
	docker push $(TAG)

clean:
	-docker rmi $(TAG)
