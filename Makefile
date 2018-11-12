# 
# Build docker image
#
#

NAME=qgis-map-server

BUILDID=$(shell date +"%Y%m%d%H%M")
COMMITID=$(shell git rev-parse --short HEAD)

VERSION:=release

ifdef PYPISERVER
BUILD_ARGS=--build-arg pypi_server=$(PYPISERVER)
DOCKERFILE=-f Dockerfile.pypi
else
BUILD_VERSION:=master
BUILD_ARGS=--build-arg server_version=$(BUILD_VERSION)
endif

BUILD_ARGS += --build-arg QGIS_VERSION=$(VERSION)

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif

BUILDIMAGE=$(NAME):$(VERSION)-$(COMMITID)

MANIFEST=factory.manifest

all:
	@echo "Usage: make [build|archive|deliver|clean]"

build: _build manifest

_build:
	docker build --rm --force-rm --no-cache $(BUILD_ARGS) -t $(BUILDIMAGE) $(DOCKERFILE) .

manifest: 
	{ \
	set -e; \
	version=`docker run --rm $(BUILDIMAGE) version`; \
	version_short=`echo $$version | cut -d. -f1-2`; \
	echo name=$(NAME) > $(MANIFEST) && \
    echo version=$$version >> $(MANIFEST) && \
    echo version_short=$$version_short >> $(MANIFEST) && \
    echo buildid=$(BUILDID)   >> $(MANIFEST) && \
    echo commitid=$(COMMITID) >> $(MANIFEST); }

deliver: tag push

tag:
	{ set -e; source factory.manifest; \
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$$version; \
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$$version_short; \
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(VERSION); \
	}

push:
	{ set -e; source factory.manifest; \
	docker push $(REGISTRY_URL)/$(NAME):$$version; \
	docker push $(REGISTRY_URL)/$(NAME):$$version_short; \
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(VERSION); \
	}

clean:
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)

TEST_HTTP_PORT:=8080
QGSRV_USER:=$(shell id -u)

ifndef LOCAL_HOME
LOCAL_HOME=$(shell pwd)
endif

test:
	mkdir -p $(HOME)/.local
	docker run --rm --name qgsserver-test-$(VERSION)-$(COMMITID) -u $(QGSRV_USER) \
		-w /tests \
		-v $$(pwd)/tests:/tests \
		-v $(LOCAL_HOME)/.local:/.local \
		-v $(LOCAL_HOME)/.cache/pip:/.pipcache \
		-e PIP_CACHE_DIR=/.pipcache \
		-e QGSRV_TEST_PROTOCOL=/tests/data \
		--entrypoint /tests/run-tests.sh $(BUILDIMAGE)

run:
	docker run -it --rm -p $(TEST_HTTP_PORT):8080 -v $(shell pwd)/tests/data:/projects \
       -e QGSRV_CACHE_ROOTDIR=/projects \
       -e QGSRV_USER=$(QGSRV_USER) \
       $(BUILDIMAGE) 

run-proxy:
	docker run --rm -p $(TEST_HTTP_PORT):8080 --net mynet --name map-proxy-$(COMMITID) \
       -e QGSRV_USER=$(QGSRV_USER) \
       -e QGSRV_LOGGING_LEVEL=DEBUG \
       $(BUILDIMAGE) qgisserver-proxy

run-worker:
	docker run --rm --net mynet -v $(shell pwd)/tests/data:/projects \
       --name qgis3-worker-$(COMMITID) \
       -e QGSRV_CACHE_ROOTDIR=/projects \
       -e QGSRV_USER=$(QGSRV_USER) \
       -e QGSRV_LOGGING_LEVEL=DEBUG \
       -e ROUTER_HOST=map-proxy-$(COMMITID) \
       $(BUILDIMAGE) qgisserver-worker

