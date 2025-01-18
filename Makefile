COREUTILS_VERSION := 0.0.28
DROPBEAR_VERSION := 2024.86
DUFS_VERSION := 0.43.0
EVTEST_VERSION := 1.35
SDL2IMGSHOW_VERSION := 2d0120f396f881331a4bc77ba5f77c46d8325b19
SFTPGO_VERSION := 2.6.4
TERMSP_VERSION := 5116aeda84b8d4bb125a214464c131c177260140

clean:
	rm -rf bin/bash
	rm -rf bin/coreutils
	rm -rf bin/dropbear
	rm -rf bin/dufs
	rm -rf bin/evtest
	rm -rf bin/jq
	rm -rf bin/remote-term
	rm -rf bin/sdl2imgshow
	rm -rf bin/sftpgo
	rm -rf bin/termsp

build: bin bin/bash bin/coreutils bin/dropbear bin/dufs bin/evtest bin/jq bin/remote-term bin/sdl2imgshow bin/sftpgo bin/termsp

.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

bin:
	mkdir -p bin

bin/bash:
	curl -o bin/bash -sSL "https://github.com/robxu9/bash-static/releases/download/5.2.015-1.2.3-2/bash-linux-aarch64"
	chmod +x bin/bash

bin/coreutils: bin
	curl -sSL -o bin/coreutils.tar.gz "https://github.com/uutils/coreutils/releases/download/$(COREUTILS_VERSION)/coreutils-$(COREUTILS_VERSION)-aarch64-unknown-linux-gnu.tar.gz"
	tar -xzf bin/coreutils.tar.gz -C bin --strip-components=1
	rm bin/coreutils.tar.gz
	chmod +x bin/coreutils
	mv bin/LICENSE bin/coreutils.LICENSE
	rm bin/README.md bin/README.package.md || true
	echo $(COREUTILS_VERSION) > bin/coreutils.version

bin/dropbear: bin
	docker buildx build --platform linux/arm64 --load -f Dockerfile.dropbear --progress plain -t app/dropbear:latest --build-arg VERSION=$(DROPBEAR_VERSION) .
	docker container create --name dropbear-extract app/dropbear:latest
	docker container cp dropbear-extract:/go/src/github.com/mkj/dropbear/dropbear bin/dropbear
	docker container rm dropbear-extract
	chmod +x bin/dropbear
	echo $(DROPBEAR_VERSION) > bin/dropbear.version

bin/dufs: bin
	curl -sSL -o bin/dufs.tar.gz "https://github.com/sigoden/dufs/releases/download/v$(DUFS_VERSION)/dufs-v$(DUFS_VERSION)-aarch64-unknown-linux-musl.tar.gz"
	tar -xzf bin/dufs.tar.gz -C bin
	rm bin/dufs.tar.gz
	chmod +x bin/dufs
	echo $(DUFS_VERSION) > bin/dufs.version

bin/evtest: bin
	docker buildx build --platform linux/arm64 --load -f Dockerfile.evtest --progress plain -t app/evtest:latest --build-arg VERSION=$(EVTEST_VERSION) .
	docker container create --name evtest-extract app/evtest:latest
	docker container cp evtest-extract:/go/src/gitlab.freedesktop.org/freedesktop/evtest/evtest bin/evtest
	docker container rm evtest-extract
	chmod +x bin/evtest
	echo $(EVTEST_VERSION) > bin/evtest.version

bin/jq: bin
	curl -o bin/jq -sSL https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64
	chmod +x bin/jq

bin/remote-term: bin
	docker buildx build --platform linux/arm64 --load -f Dockerfile.remote-term --progress plain -t app/remote-term:latest .
	docker container create --name remote-term-extract app/remote-term:latest
	docker container cp remote-term-extract:/go/src/github.com/josegonzalez/go-remote-term/remote-term bin/remote-term
	docker container rm remote-term-extract
	chmod +x bin/remote-term

bin/sdl2imgshow: bin
	docker buildx build --platform linux/arm64 --load -f Dockerfile.sdl2imgshow --progress plain -t app/sdl2imgshow:latest --build-arg VERSION=$(SDL2IMGSHOW_VERSION) .
	docker container create --name sdl2imgshow-extract app/sdl2imgshow:latest
	docker container cp sdl2imgshow-extract:/go/src/github.com/kloptops/sdl2imgshow/build/sdl2imgshow bin/sdl2imgshow
	docker container rm sdl2imgshow-extract
	chmod +x bin/sdl2imgshow
	echo $(SDL2IMGSHOW_VERSION) > bin/sdl2imgshow.version

bin/sftpgo: bin
	docker buildx build --platform linux/arm64 --load -f Dockerfile.sftpgo --progress plain -t app/sftpgo:latest --build-arg VERSION=$(SFTPGO_VERSION) .
	docker container create --name sftpgo-extract app/sftpgo:latest
	docker container cp sftpgo-extract:/go/src/github.com/drakkan/sftpgo/sftpgo bin/sftpgo
	docker container rm sftpgo-extract
	chmod +x bin/sftpgo
	echo $(SFTPGO_VERSION) > bin/sftpgo.version

bin/termsp: bin
	docker buildx build --platform linux/arm64 --load -f Dockerfile.termsp --progress plain -t app/termsp:latest --build-arg VERSION=$(TERMSP_VERSION) .
	docker container create --name termsp-extract app/termsp:latest
	docker container cp termsp-extract:/go/src/github.com/Nevrdid/TermSP/build/TermSP bin/termsp
	docker container rm termsp-extract
	chmod +x bin/termsp
	echo $(TERMSP_VERSION) > bin/termsp.version
