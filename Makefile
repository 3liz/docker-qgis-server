# 
# Build docker image
#
#

NAME=qgis-map-server

BUILDID=$(shell date +"%Y%m%d%H%M")
COMMITID=$(shell git rev-parse --short HEAD)

SERVER_BRANCH=master

VERSION=1.1
VERSION_SHORT=1

VERSION_TAG=$(VERSION)

ifdef PYPISERVER
BUILD_ARGS=--build-arg pypi_server=$(PYPISERVER)
DOCKERFILE=-f Dockerfile.pypi
else
BUILD_ARGS=--build-arg server_version=$(SERVER_BRANCH)
endif

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif


BUILDIMAGE=$(NAME):$(VERSION_TAG)-$(COMMITID)
ARCHIVENAME=$(shell echo $(NAME):$(VERSION_TAG)|tr '[:./]' '_')

MANIFEST=factory.manifest

all:
	@echo "Usage: make [build|archive|deliver|clean]"

manifest:
	echo name=$(NAME) > $(MANIFEST) && \
    echo version=$(VERSION)   >> $(MANIFEST) && \
    echo version_short=$(VERSION_SHORT) >> $(MANIFEST) && \
    echo buildid=$(BUILDID)   >> $(MANIFEST) && \
    echo commitid=$(COMMITID) >> $(MANIFEST) && \
    echo archive=$(ARCHIVENAME) >> $(MANIFEST)

build: manifest
	docker build --rm --force-rm --no-cache $(BUILD_ARGS) -t $(BUILDIMAGE) $(DOCKERFILE) .

test:
	@echo No tests defined !

archive:
	docker save $(BUILDIMAGE) | bzip2 > $(FACTORY_ARCHIVE_PATH)/$(ARCHIVENAME).bz2

deliver: tag push

tag:
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):latest
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(VERSION)
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(VERSION_SHORT)

push:
	docker push $(REGISTRY_URL)/$(NAME):latest
	docker push $(REGISTRY_URL)/$(NAME):$(VERSION)
	docker push $(REGISTRY_URL)/$(NAME):$(VERSION_SHORT)

clean:
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)

TEST_HTTP_PORT:=8080
QGSRV_USER:=$(shell id -u)

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

