#!/bin/bash
set -e
GEM_GIT_PACKAGE="oq-libs"
GEM_DEB_PACKAGE="python-${GEM_GIT_PACKAGE}"
rm -rf build-deb
mkdir build-deb
git archive --prefix ${GEM_GIT_PACKAGE}/ HEAD | (cd build-deb ; tar xv)
cd build-deb/${GEM_GIT_PACKAGE}
./helpers/whldownload.sh -w py -w py27
debuild -S -i
# debuild -b -us -uc -i
