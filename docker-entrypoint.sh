#!/bin/bash

set -e

QGSRV_USER=${QGSRV_USER:-"9001:9001"}

if [ "$1" = "qgisserver-proxy" ]; then
    shift
    echo "Running Qgis server proxy"
    exec gosu $QGSRV_USER qgisserver --proxy $@
fi 

QGSRV_DISPLAY_XVFB=${QGSRV_DISPLAY_XVFB:-ON}

# Qgis need a HOME
export HOME=/home/qgssrv

if [ "$(id -u)" = '0' ]; then
   mkdir -p $HOME
   chown -R $QGSRV_USER $HOME
   #
   # Set up xvfb
   # https://www.x.org/archive/X11R7.6/doc/man/man1/Xvfb.1.xhtml
   # see https://www.x.org/archive/X11R7.6/doc/man/man1/Xserver.1.xhtml
   #
   XVFB_DEFAULT_ARGS="-screen 0 1024x768x24 -ac +extension GLX +render -noreset"
   XVFB_ARGS=${QGSRV_XVFB_ARGS:-":99 $XVFB_DEFAULT_ARGS"}

   if [[ "$QGSRV_DISPLAY_XVFB" == "ON" ]]; then
     # RUN Xvfb in the background
     echo "Running XXvfb"
     /usr/bin/Xvfb $XVFB_ARGS &
     export DISPLAY=":99"
   fi
   exec gosu $QGSRV_USER  "$BASH_SOURCE" "$@"
fi

# See https://github.com/qgis/QGIS/pull/5337
export QGIS_DISABLE_MESSAGE_HOOKS=1
export QGIS_NO_OVERRIDE_IMPORT=1

if [ "$1" = "qgisserver-worker" ]; then
    shift
    echo "Running Qgis server worker"
    exec qgisserver-worker --host=$ROUTER_HOST $@
else
    exec qgisserver $@
fi

