################################################################################
###                             Project Info                                 ###
################################################################################
PROJECT_NAME := fury# unique namespace for project

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_COMMIT := $(shell git rev-parse HEAD)
GIT_COMMIT_SHORT := $(shell git rev-parse --short HEAD)

BRANCH_PREFIX := $(shell echo $(GIT_BRANCH) | sed 's/\/.*//g')# eg release, master, feat

EXACT_TAG := $(shell git describe --tags --exact-match 2> /dev/null)
RECENT_TAG := $(shell git describe --tags)

ifeq ($(BRANCH_PREFIX), release)
# we are on a release branch, set version to the last or current tag
VERSION := $(RECENT_TAG)# use current tag or most recent tag + number of commits + g + abbrivated commit
VERSION_NUMBER := $(shell echo $(VERSION) | sed 's/^v//')# drop the "v" prefix for versions
else ifeq ($(EXACT_TAG), $(RECENT_TAG))
# we have a tag checked out directly
VERSION := $(RECENT_TAG)# use exact tag
VERSION_NUMBER := $(shell echo $(VERSION) | sed 's/^v//')# drop the "v" prefix for versions
else
# we are not on a release branch, and do not have clean tag history (etc v0.19.0-xx-gxx will not make sense to use)
VERSION := $(GIT_COMMIT_SHORT)
VERSION_NUMBER := $(VERSION)
endif

TENDERMINT_VERSION := $(shell go list -m github.com/tendermint/tendermint | sed 's:.* ::')
COSMOS_SDK_VERSION := $(shell go list -m github.com/cosmos/cosmos-sdk | sed 's:.* ::')

.PHONY: print-git-info
print-git-info:
	@echo "branch $(GIT_BRANCH)\nbranch_prefix $(BRANCH_PREFIX)\ncommit $(GIT_COMMIT)\ncommit_short $(GIT_COMMIT_SHORT)"

.PHONY: print-version
print-version:
	@echo "fury $(VERSION)\ntendermint $(TENDERMINT_VERSION)\ncosmos $(COSMOS_SDK_VERSION)"

################################################################################
###                             Project Settings                             ###
################################################################################
LEDGER_ENABLED ?= true
DOCKER:=docker
DOCKER_BUF := $(DOCKER) run --rm -v $(CURDIR):/workspace --workdir /workspace bufbuild/buf
HTTPS_GIT := https://github.com/Incubus-Network/fury.git

################################################################################
###                             Machine Info                                 ###
################################################################################
OS_FAMILY := $(shell uname -s)
MACHINE := $(shell uname -m)

NATIVE_GO_OS := $(shell echo $(OS_FAMILY) | tr '[:upper:]' '[:lower:]')# Linux -> linux, Darwin -> darwin

NATIVE_GO_ARCH := $(MACHINE)
ifeq ($(MACHINE),x86_64)
NATIVE_GO_ARCH := amd64# x86_64 -> amd64
endif
ifeq ($(MACHINE),aarch64)
NATIVE_GO_ARCH := arm64# aarch64 -> arm64
endif

TARGET_GO_OS ?= $(NATIVE_GO_OS)
TARGET_GO_ARCH ?= $(NATIVE_GO_ARCH)
.PHONY: print-machine-info
print-machine-info:
	@echo "platform $(NATIVE_GO_OS)/$(NATIVE_GO_ARCH)"
	@echo "target $(TARGET_GO_OS)/$(TARGET_GO_ARCH)"

################################################################################
###                             PATHS                                        ###
################################################################################
BUILD_DIR := build# build files
BIN_DIR := $(BUILD_DIR)/bin# for binary dev dependencies
BUILD_CACHE_DIR := $(BUILD_DIR)/.cache# caching for non-artifact outputs
OUT_DIR := out# for artifact intermediates and outputs

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))# absolute path to root
export PATH := $(ROOT_DIR)/$(BIN_DIR):$(PATH)# add local bin first in path

.PHONY: print-path
print-path:
	@echo $(PATH)

.PHONY: print-paths
print-paths:
	@echo "build $(BUILD_DIR)\nbin $(BIN_DIR)\ncache $(BUILD_CACHE_DIR)\nout $(OUT_DIR)"



################################################################################
###                             Dev Setup                                    ###
################################################################################
# include $(BUILD_DIR)/deps.mk

# include $(BUILD_DIR)/proto.mk
# include $(BUILD_DIR)/proto-deps.mk

export GO111MODULE = on
# process build tags
build_tags = netgo
ifeq ($(LEDGER_ENABLED),true)
  ifeq ($(OS),Windows_NT)
    GCCEXE = $(shell where gcc.exe 2> NUL)
    ifeq ($(GCCEXE),)
      $(error gcc.exe not installed for ledger support, please install or set LEDGER_ENABLED=false)
    else
      build_tags += ledger
    endif
  else
    UNAME_S = $(shell uname -s)
    ifeq ($(UNAME_S),OpenBSD)
      $(warning OpenBSD detected, disabling ledger support (https://github.com/cosmos/cosmos-sdk/issues/1988))
    else
      GCC = $(shell command -v gcc 2> /dev/null)
      ifeq ($(GCC),)
        $(error gcc not installed for ledger support, please install or set LEDGER_ENABLED=false)
      else
        build_tags += ledger
      endif
    endif
  endif
endif

ifeq (cleveldb,$(findstring cleveldb,$(COSMOS_BUILD_OPTIONS)))
  build_tags += gcc
endif

ifeq (secp,$(findstring secp,$(COSMOS_BUILD_OPTIONS)))
  build_tags += libsecp256k1_sdk
endif

whitespace :=
whitespace += $(whitespace)
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))

# process linker flags

ldflags = -X github.com/cosmos/cosmos-sdk/version.Name=fury \
		  -X github.com/cosmos/cosmos-sdk/version.AppName=fury \
		  -X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION_NUMBER) \
		  -X github.com/cosmos/cosmos-sdk/version.Commit=$(GIT_COMMIT) \
		  -X "github.com/cosmos/cosmos-sdk/version.BuildTags=$(build_tags_comma_sep)" \
		  -X github.com/tendermint/tendermint/version.TMCoreSemVer=$(TENDERMINT_VERSION)

# DB backend selection
ifeq (cleveldb,$(findstring cleveldb,$(COSMOS_BUILD_OPTIONS)))
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=cleveldb
endif
ifeq (badgerdb,$(findstring badgerdb,$(COSMOS_BUILD_OPTIONS)))
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=badgerdb
  BUILD_TAGS += badgerdb
endif
# handle rocksdb
ifeq (rocksdb,$(findstring rocksdb,$(COSMOS_BUILD_OPTIONS)))
  CGO_ENABLED=1
  BUILD_TAGS += rocksdb
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=rocksdb
endif
# handle boltdb
ifeq (boltdb,$(findstring boltdb,$(COSMOS_BUILD_OPTIONS)))
  BUILD_TAGS += boltdb
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=boltdb
endif

ifeq (,$(findstring nostrip,$(COSMOS_BUILD_OPTIONS)))
  ldflags += -w -s
endif
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'
# check for nostrip option
ifeq (,$(findstring nostrip,$(COSMOS_BUILD_OPTIONS)))
  BUILD_FLAGS += -trimpath
endif

###############################################################################
###                                  Build                                  ###
###############################################################################

BUILD_TARGETS := build install

build: BUILD_ARGS=-o $(BUILDDIR)/
build-linux:
	GOOS=linux GOARCH=amd64 LEDGER_ENABLED=false $(MAKE) build

$(BUILD_TARGETS): go.sum $(BUILDDIR)/
	go $@ $(BUILD_FLAGS) $(BUILD_ARGS) ./...

$(BUILDDIR)/:
	mkdir -p $(BUILDDIR)/

build-reproducible: go.sum
	$(DOCKER) rm latest-build || true
	$(DOCKER) run --volume=$(CURDIR):/sources:ro \
        --env TARGET_PLATFORMS='linux/amd64' \
        --env APP=black \
        --env VERSION=$(VERSION) \
        --env COMMIT=$(COMMIT) \
        --env CGO_ENABLED=1 \
        --env LEDGER_ENABLED=$(LEDGER_ENABLED) \
        --name latest-build tendermintdev/rbuilder:latest
	$(DOCKER) cp -a latest-build:/home/builder/artifacts/ $(CURDIR)/


build-docker:
	# TODO replace with kaniko
	$(DOCKER) build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
	$(DOCKER) tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
	# docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${COMMIT_HASH}
	# update old container
	$(DOCKER) rm black || true
	# create a new container from the latest image
	$(DOCKER) create --name black -t -i ${DOCKER_IMAGE}:latest black
	# move the binaries to the ./build directory
	mkdir -p ./build/
	$(DOCKER) cp black:/usr/bin/black ./build/

push-docker: build-docker
	$(DOCKER) push ${DOCKER_IMAGE}:${DOCKER_TAG}
	$(DOCKER) push ${DOCKER_IMAGE}:latest

$(MOCKS_DIR):
	mkdir -p $(MOCKS_DIR)

distclean: clean tools-clean

clean:
	rm -rf \
    $(BUILDDIR)/ \
    artifacts/ \
    tmp-swagger-gen/

all: build

build-all: tools build lint test

.PHONY: distclean clean build-all

###############################################################################
###                          Tools & Dependencies                           ###
###############################################################################

TOOLS_DESTDIR  ?= $(GOPATH)/bin
STATIK         = $(TOOLS_DESTDIR)/statik
RUNSIM         = $(TOOLS_DESTDIR)/runsim

# Install the runsim binary with a temporary workaround of entering an outside
# directory as the "go get" command ignores the -mod option and will polute the
# go.{mod, sum} files.
#
# ref: https://github.com/golang/go/issues/30515
runsim: $(RUNSIM)
$(RUNSIM):
	@echo "Installing runsim..."
	@go get github.com/cosmos/tools/cmd/runsim@master)

statik: $(STATIK)
$(STATIK):
	@echo "Installing statik..."
	@go get github.com/rakyll/statik@v0.1.6)

docs-tools:
ifeq (, $(shell which yarn))
	@echo "Installing yarn..."
	@npm install -g yarn
else
	@echo "yarn already installed; skipping..."
endif

tools: tools-stamp
tools-stamp: docs-tools proto-tools statik runsim
	# Create dummy file to satisfy dependency and avoid
	# rebuilding when this Makefile target is hit twice
	# in a row.
	touch $@

tools-clean:
	rm -f $(RUNSIM)
	rm -f tools-stamp

docs-tools-stamp: docs-tools
	# Create dummy file to satisfy dependency and avoid
	# rebuilding when this Makefile target is hit twice
	# in a row.
	touch $@

.PHONY: runsim statik tools contract-tools docs-tools proto-tools  tools-stamp tools-clean docs-tools-stamp

go.sum: go.mod
	echo "Ensure dependencies have not been modified ..." >&2
	go mod verify
	go mod tidy

########################################
### Tools & dependencies

go-mod-cache: go.sum
	@echo "--> Download go modules to local cache"
	@go mod download
PHONY: go-mod-cache


########################################
### Linting

# Check url links in the repo are not broken.
# This tool checks local markdown links as well.
# Set to exclude riot links as they trigger false positives
link-check:
	@go get -u github.com/raviqqe/liche@f57a5d1c5be4856454cb26de155a65a4fd856ee3
	liche -r . --exclude "^http://127.*|^https://riot.im/app*|^http://fury-testnet*|^https://testnet-dex*|^https://fury3.data.fury.io*|^https://ipfs.io*|^https://apps.apple.com*|^https://fury.quicksync.io*"


lint:
	golangci-lint run
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" | xargs gofmt -d -s
	go mod verify
.PHONY: lint

format:
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -name '*.pb.go' | xargs gofmt -w -s
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -name '*.pb.go' | xargs misspell -w
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -name '*.pb.go' | xargs goimports -w -local github.com/tendermint
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -name '*.pb.go' | xargs goimports -w -local github.com/cosmos/cosmos-sdk
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -name '*.pb.go' | xargs goimports -w -local github.com/incubus-network/fury
.PHONY: format



###############################################################################
###                              Documentation                              ###
###############################################################################

update-swagger-docs: statik
	$(BINDIR)/statik -src=client/docs/swagger-ui -dest=client/docs -f -m
	@if [ -n "$(git status --porcelain)" ]; then \
        echo "\033[91mSwagger docs are out of sync!!!\033[0m";\
        exit 1;\
    else \
        echo "\033[92mSwagger docs are in sync\033[0m";\
    fi
.PHONY: update-swagger-docs

godocs:
	@echo "--> Wait a few seconds and visit http://localhost:6060/pkg/github.com/merlin-network/black-fury/types"
	godoc -http=:6060

# Start docs site at localhost:8080
docs-serve:
	@cd docs && \
	yarn && \
	yarn run serve

# Build the site into docs/.vuepress/dist
build-docs:
	@$(MAKE) docs-tools-stamp && \
	cd docs && \
	yarn && \
	yarn run build

# This builds a docs site for each branch/tag in `./docs/versions`
# and copies each site to a version prefixed path. The last entry inside
# the `versions` file will be the default root index.html.
build-docs-versioned:
	@$(MAKE) docs-tools-stamp && \
	cd docs && \
	while read -r branch path_prefix; do \
		(git checkout $${branch} && npm install && VUEPRESS_BASE="/$${path_prefix}/" npm run build) ; \
		mkdir -p ~/output/$${path_prefix} ; \
		cp -r .vuepress/dist/* ~/output/$${path_prefix}/ ; \
		cp ~/output/$${path_prefix}/index.html ~/output ; \
	done < versions ;

.PHONY: docs-serve build-docs build-docs-versioned

###############################################################################
###                                Localnet                                 ###
###############################################################################

# Build docker image and tag as fury/fury:local
docker-build:
	DOCKER_BUILDKIT=1 $(DOCKER) build -t fury/fury:local .

docker-build-rocksdb:
	DOCKER_BUILDKIT=1 $(DOCKER) build -f Dockerfile-rocksdb -t fury/fury:local .

build-docker-local-fury:
	@$(MAKE) -C networks/local

# Run a 4-node testnet locally
localnet-start: build-linux localnet-stop
	@if ! [ -f build/node0/fud/config/genesis.json ]; then docker run --rm -v $(CURDIR)/build:/fud:Z fury/furynode testnet --v 4 -o . --starting-ip-address 192.168.10.2 --keyring-backend=test ; fi
	docker-compose up -d

localnet-stop:
	docker-compose down

# Launch a new single validator chain
start:
	./contrib/devnet/init-new-chain.sh
	fury start

#proto-format:
#@echo "Formatting Protobuf files"
#@if docker ps -a --format '{{.Names}}' | grep -Eq "^${containerProtoFmt}$$"; then docker start -a $(containerProtoFmt); else docker run --name $(containerProtoFmt) -v $(CURDIR):/workspace --workdir /workspace tendermintdev/docker-build-proto \
#find ./ -not -path "./third_party/*" -name *.proto -exec clang-format -style=file -i {} \; ; fi

########################################
### Testing

# TODO tidy up cli tests to use same -Enable flag as simulations, or the other way round
# TODO -mod=readonly ?
# build dependency needed for cli tests
test-all: build
	# basic app tests
	@go test ./app -v
	# basic simulation (seed "4" happens to not unbond all validators before reaching 100 blocks)
	#@go test ./app -run TestFullAppSimulation        -Enabled -Commit -NumBlocks=100 -BlockSize=200 -Seed 4 -v -timeout 24h
	# other sim tests
	#@go test ./app -run TestAppImportExport          -Enabled -Commit -NumBlocks=100 -BlockSize=200 -Seed 4 -v -timeout 24h
	#@go test ./app -run TestAppSimulationAfterImport -Enabled -Commit -NumBlocks=100 -BlockSize=200 -Seed 4 -v -timeout 24h
	# AppStateDeterminism does not use Seed flag
	#@go test ./app -run TestAppStateDeterminism      -Enabled -Commit -NumBlocks=100 -BlockSize=200 -Seed 4 -v -timeout 24h

# run module tests and short simulations
test-basic: test
	@go test ./app -run TestFullAppSimulation        -Enabled -Commit -NumBlocks=5 -BlockSize=200 -Seed 4 -v -timeout 2m
	# other sim tests
	@go test ./app -run TestAppImportExport          -Enabled -Commit -NumBlocks=5 -BlockSize=200 -Seed 4 -v -timeout 2m
	@go test ./app -run TestAppSimulationAfterImport -Enabled -Commit -NumBlocks=5 -BlockSize=200 -Seed 4 -v -timeout 2m
	@# AppStateDeterminism does not use Seed flag
	@go test ./app -run TestAppStateDeterminism      -Enabled -Commit -NumBlocks=5 -BlockSize=200 -Seed 4 -v -timeout 2m

# run end-to-end tests (local docker container must be built, see docker-build)
test-e2e: docker-build
	go test -failfast -count=1 -v ./tests/e2e/...

test:
	@go test $$(go list ./... | grep -v 'contrib' | grep -v 'tests/e2e')

# Run cli integration tests
# `-p 4` to use 4 cores, `-tags cli_test` to tell go not to ignore the cli package
# These tests use the `fud` or `kvcli` binaries in the build dir, or in `$BUILDDIR` if that env var is set.
test-cli: build
	@go test ./cli_test -tags cli_test -v -p 4

# Run tests for migration cli command
test-migrate:
	@go test -v -count=1 ./migrate/...

# Kick start lots of sims on an AWS cluster.
# This submits an AWS Batch job to run a lot of sims, each within a docker image. Results are uploaded to S3
start-remote-sims:
	# build the image used for running sims in, and tag it
	docker build -f simulations/Dockerfile -t fury/fury-sim:master .
	# push that image to the hub
	docker push fury/fury-sim:master
	# submit an array job on AWS Batch, using 1000 seeds, spot instances
	aws batch submit-job \
		-—job-name "master-$(VERSION)" \
		-—job-queue “simulation-1-queue-spot" \
		-—array-properties size=1000 \
		-—job-definition fury-sim-master \
		-—container-override environment=[{SIM_NAME=master-$(VERSION)}]


.PHONY: all build-linux install clean build test test-cli test-all test-rest test-basic start-remote-sims
