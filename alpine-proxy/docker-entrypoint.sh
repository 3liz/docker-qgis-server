#!/bin/sh

set -e

QGSRV_USER=${QGSRV_USER:-"9001:9001"}

# Run server
exec su-exec $QGSRV_USER qgisserver --proxy $@

