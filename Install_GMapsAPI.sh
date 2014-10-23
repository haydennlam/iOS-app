#!/bin/bash

if [ ! -e GoogleMaps.framework ]; then
  GMAPS_DIST_ZIP=GoogleMaps-iOS-1.8.1.zip
  if [ -r ${GMAPS_DIST_ZIP} ]; then
    GMAPS_DIST_PATH=""
  elif [ -r "../${GMAPS_DIST_ZIP}" ]; then
    GMAPS_DIST_PATH="../"
  elif [ -r "${HOME}/Desktop/${GMAPS_DIST_ZIP}" ]; then
    GMAPS_DIST_PATH="$HOME/Desktop/"
  elif [ -r "${HOME}/${GMAPS_DIST_ZIP}" ]; then
    GMAPS_DIST_PATH="$HOME/"
  fi
  if [ ! -r "${GMAPS_DIST_PATH}${GMAPS_DIST_ZIP}" ]; then
    (cd ..; curl -O "https://dl.google.com/geosdk/GoogleMaps-iOS-1.8.1.zip")
    GMAPS_DIST_PATH="../"
  fi
  unzip "${GMAPS_DIST_PATH}${GMAPS_DIST_ZIP}" GoogleMaps-iOS-1.8.1/GoogleMaps.framework/\*
  mv GoogleMaps-iOS-1.8.1/GoogleMaps.framework .
  rmdir GoogleMaps-iOS-1.8.1
fi

exit 0
