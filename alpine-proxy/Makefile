# 
# Build docker image
#
#

NAME=qgis3-map-service

BUILDID=$(shell date +"%Y%m%d%H%M")
COMMITID=$(shell git rev-parse --short HEAD)

VERSION=1.1-proxy-alpine
VERSION_SHORT=1-proxy-alpine

VERSION_TAG=$(VERSION)

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif

ifndef PYPISERVER
PYPISERVER=pypi.snap.lizlan
endif

BUILD_ARGS += --build-arg pypi_server=$(PYPISERVER)

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
	docker build --rm --force-rm --no-cache $(BUILD_ARGS) -t $(BUILDIMAGE) .

test:
	@echo No tests defined !

archive:
	docker save $(BUILDIMAGE) | bzip2 > $(FACTORY_ARCHIVE_PATH)/$(ARCHIVENAME).bz2

deliver: tag push

tag:
	docker tag $(BUILDIMAGE) $(REGISTRY_URL)/$(NAME):$(VERSION)
	docker tag $(BUILDIMAGE) $(REGISTRY_URL)/$(NAME):$(VERSION_SHORT)

push:
	docker push $(REGISTRY_URL)/$(NAME):$(VERSION)
	docker push $(REGISTRY_URL)/$(NAME):$(VERSION_SHORT)

clean:
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)

TEST_HTTP_PORT:=8080
QGSRV_USER:=$(shell id -u)

run:
	docker run --rm -p $(TEST_HTTP_PORT):8080 --net mynet --name map-proxy-$(COMMITID) \
       -e QGSRV_USER=$(QGSRV_USER) \
       -e QGSRV_LOGGING_LEVEL=DEBUG \
       $(BUILDIMAGE) 

