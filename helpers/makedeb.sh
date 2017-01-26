#!/bin/bash
GEM_GIT_PACKAGE="oq-libs"
GEM_DEB_PACKAGE="python-${GEM_GIT_PACKAGE}"
rm -rf build-deb
mkdir build-deb
git archive --prefix ${GEM_GIT_PACKAGE}/ HEAD | (cd build-deb ; tar xv)
cd build-deb/${GEM_GIT_PACKAGE}
debuild -S -i
# debuild -b -us -uc -i
