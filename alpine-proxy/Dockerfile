# Need docker above v17-05.0-ce
ARG REGISTRY_PREFIX=''

FROM  ${REGISTRY_PREFIX}python:3.6-alpine
MAINTAINER David Marteau <david.marteau@3liz.com>
LABEL Description="Map Service Proxy" Vendor="3liz.org" Version="1.1"

ARG pypi_server 
COPY requirements.txt /
RUN apk --no-cache add zeromq su-exec \
    && pip install --no-cache-dir -U pip setuptools wheel \
    && mkdir -p /.wheels \
    && pip download --no-cache-dir --no-index --no-deps --platform=alpine \
        --find-links=https://$pypi_server/packages --trusted-host=$pypi_server -d /.wheels -r requirements.txt  \
    && wheel install --force -l /.wheels/* \
    && wheel install --force /.wheels/* \
    && pip install  --no-cache-dir --no-index --no-deps \
        --trusted-host=$pypi_server  --find-links=https://$pypi_server/packages --no-deps py-qgis-server \
    && rm -rf /.wheels /root/.cache \
    && rm -rf /var/cache/apk/* \
    ;

COPY /docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh

COPY factory.manifest /build.manifest

ENTRYPOINT ["/docker-entrypoint.sh"]


