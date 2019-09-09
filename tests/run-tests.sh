#!/bin/bash

set -e

pip3 install -U --user setuptools
pip3 install -U --user pytest requests

export QGIS_DISABLE_MESSAGE_HOOKS=1
export QGIS_NO_OVERRIDE_IMPORT=1

export QGSRV_LOGGING_LEVEL=DEBUG

# Add /.local to path
export PATH=$PATH:/.local/bin

# Run the server locally
echo "Running server..."
qgisserver -b 127.0.0.1 -p 8080 --rootdir=$(pwd)/data -w1 &>/tests/__tests__.log &

# Wait for server to start
sleep 7
# Run new tests
#echo "Launching test"
py.test -v
kill $(jobs -p)

