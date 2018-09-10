# Qgis 3 map  server

Setup a OGC WWS/WFS/WCS service.

Run the python qgis server from https://github.com/3liz/py-qgis-server in a docker container.

## Run example

```
docker run -p 8080:8080 \
       -v /path/to/qgis/projects:/projects \
       -e QGSRV_SERVER_WORKERS=2 \
       -e QGSRV_LOGGING_LEVEL=DEBUG  \
       -e QGSRV_CACHE_ROOTDIR=/projects \
       -e QGSRV_CACHE_SIZE=10 \
       3liz/qgis-map-server
```


## Passing MAP arguments

MAP arguments are treated as relative to the location given by  `QYWPS_CACHE_ROOTDIR`

### Qgis project Cache configuration

- QGSRV\_CACHE\_ROOTDIR: Absolute path to the qgis projects root directory
- QGSRV\_CACHE\_SIZE: Qgis projects cache size
- QGSRV\_LOGGING\_LEVEL: Logging level (DEBUG,INFO)
- QGSRV\_SERVER\_WORKERS: Number of qgis server instances

The cache hold projects, if the project timestamp change on disk then the project will be reloaded.

### Xvfb and Display support

Xvfb display support can be activate with `QGSRV_DISPLAY_XVFB=ON` which is the default behavior.

