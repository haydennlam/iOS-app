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

  GMAPS_API_KEY_FILE=GoogleMaps-API-Key.txt
  API_KEY=$(cat ${GMAPS_DIST_PATH}${GMAPS_API_KEY_FILE})
  if [ -e ${GMAPS_DIST_PATH}${GMAPS_API_KEY_FILE} ]; then
    API_KEY=$(cat ${GMAPS_DIST_PATH}${GMAPS_API_KEY_FILE})
  fi
  while [ "${API_KEY}"x == ""x ]; do
    API_KEY=$(osascript -e 'Tell application "System Events" to display dialog "Please select and then Copy the Google Maps API key and then hit Okay" buttons {"Okay"}' -e 'get the clipboard' 2>/dev/null)
    if [ $? -ne 0 ]; then exit -1; fi
    if echo ${API_KEY}|grep "^AIza">/dev/null && [ $(echo ${API_KEY}|wc -c|awk '{ print $1 }') -gt 30 ]; then
      true
    else
      osascript -e 'Tell application "System Events" to display dialog "No, really, this won'\''t work if you don'\''t give me the key..." buttons {"Okay","Cancel"}' >/dev/null 2>&1
      if [ $? -ne 0 ]; then exit -1; fi
      API_KEY=
    fi
  done
  if [ ! -e ${GMAPS_DIST_PATH}${GMAPS_API_KEY_FILE} ]; then
    echo $API_KEY > ${GMAPS_DIST_PATH}${GMAPS_API_KEY_FILE}
  fi
  sed -i "" -e "s|GOOGLE_MAPS_API_KEY|${API_KEY}|g" BarreForestGuide/AppDelegate.m
fi

exit 0
