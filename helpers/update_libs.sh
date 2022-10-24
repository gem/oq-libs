#!/bin/bash
IFILE=../oq-engine/requirements-py38-linux64.txt

cat $IFILE | sed 's@https://.*/py[0-9]*/@@g' | grep -v '^#' | grep -v '^GDAL-' | grep -v -- '-cp3[0-9]-' > py/requirements-bin.txt
cat $IFILE | sed 's@https://.*/py[0-9]*/@@g' | grep -v '^#' | grep -v '^GDAL-' | grep -- '-cp3[0-9]-' > py38/requirements-bin.txt
echo "### GDAL ###" > py38-extra/requirements-bin.txt
cat $IFILE | sed 's@https://.*/py[0-9]*/@@g' | grep '^GDAL-' >> py38-extra/requirements-bin.txt

