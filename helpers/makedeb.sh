#!/bin/bash
#
# makedeb.sh  Copyright (C) 2016-2019 GEM Foundation
#
# OpenQuake is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenQuake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with OpenQuake.  If not, see <http://www.gnu.org/licenses/>

if [ $GEM_SET_DEBUG ]; then
    set -x
fi
set -e

export PATH="/opt/openquake/bin:$PATH"
GEM_GIT_PACKAGE="oq-libs"
GEM_DEB_PACKAGE="python3-${GEM_GIT_PACKAGE}"

if [ "$1" = "check_versions" ]; then
    vers_python="$(python3 -c "from openquake.libs import __version__ ; print(__version__)")"
    vers_debian="$(head -n 1 debian/changelog  | sed 's/^.*(//g;s/).*//g;s/[-~].*//g')"

    if [ "$vers_python" != "$vers_debian" ]; then
        echo "Python version (openquake/libs/__init__.py) and debian version are different ($vers_python != $vers_debian)"
        exit 1
    fi
    exit 0
fi

# rm -rf build-deb
# mkdir build-deb
# git archive --prefix ${GEM_GIT_PACKAGE}/ HEAD | (cd build-deb ; tar xv)
# cd build-deb/${GEM_GIT_PACKAGE}
./helpers/whldownload.sh -w py -w py36 -w py36-extra
