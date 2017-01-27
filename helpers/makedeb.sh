#!/bin/bash
set -e

GEM_GIT_PACKAGE="oq-libs"
GEM_DEB_PACKAGE="python-${GEM_GIT_PACKAGE}"

if [ "$1" = "check_versions" ]; then
    vers_python="$(python -c "from openquake.libs import __version__ ; print __version__")"
    vers_debian="$(head -n 1 debian/changelog  | sed 's/^.*(//g;s/).*//g')"

    if [ "$vers_python" != "$vers_debian" ]; then
        echo "Python version (openquake/libs/__init__.py) and debian version are different ($vers_python != $vers_debian)"
        exit 1
    fi
    exit 0
fi

rm -rf build-deb
mkdir build-deb
git archive --prefix ${GEM_GIT_PACKAGE}/ HEAD | (cd build-deb ; tar xv)
cd build-deb/${GEM_GIT_PACKAGE}
./helpers/whldownload.sh -w py -w py27
# use this line to build binaries
# debuild -b -i # -us -uc
debuild -S -i
