# Need docker above v17-05.0-ce
ARG REGISTRY_PREFIX=''
ARG QGIS_VERSION=latest

FROM  ${REGISTRY_PREFIX}qgis-platform:${QGIS_VERSION}
MAINTAINER David Marteau <david.marteau@3liz.com>
LABEL Description="QGIS3 Python Server" Vendor="3liz.org" Version="1."

RUN apt-get update && apt-get install -y --no-install-recommends unzip gosu curl make && rm -rf /var/lib/apt/lists/*

ARG server_version=master
ARG server_archive=https://github.com/3liz/py-qgis-server/archive/${server_version}.zip

# Install server
RUN echo $server_archive \
    && curl -Ls -X GET  $server_archive --output python-server.zip \
    && unzip -q python-server.zip \
    && rm python-server.zip \
    && make -C py-qgis-server-${server_version} dist \
    && pip3 install --no-cache py-qgis-server-${server_version}/build/dist/*.tar.gz \
    && rm -rf py-qgis-server-${server_version}

COPY /docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh

COPY factory.manifest /build.manifest

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]


