#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2016-2019 GEM Foundation
#
# OpenQuake is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenQuake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with OpenQuake. If not, see <http://www.gnu.org/licenses/>.

if [ $GEM_SET_DEBUG ]; then
    set -x
fi
set -e

help() {
    cat <<HSD
USAGE:

$0 -h
$0 -s <src_folder> [-s <src_folder2> [..]] -d <dest_folder>

The command line arguments are as follows:
    -3                   Use Python 3.5
    -b, --bin            Use a custom python binary, different from the one in \$PATH
    -s, --source         Location of wheels (can be used multiple times)
    -d, --dest           Destination target where Python code wil be installed
    -n, --no-deps        Skip pip dependecy resolution
    -c, --compile        Compile pyc files
    -h, --help           This help
HSD
}

checkpath() {
    if [ ! -d $1 ]; then
        echo "ERROR: $1 path does not exist" >&2
        exit 1
    fi
}

checkcmd() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "This script requires '$1' but it isn't available. Aborting."; exit 1; }
}

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    help
    exit 0
elif [ $# -lt 5 ]; then
    help
    exit 1
fi

declare -a SRC

python="/usr/bin/python3.9"
virtualenv="venv"

while [ $# -gt 0 ]; do
    case "$1" in
        -36)
            PATH="/opt/openquake/bin:$PATH"
            python="python3.6"
            virtualenv="venv"
            shift
            ;;
        -38)
            #PATH="/opt/openquake/bin:$PATH"
            python="/usr/bin/python3.8"
            virtualenv="venv"
            shift
            ;;
        -39)
            #PATH="/opt/openquake/bin:$PATH"
            python="/usr/bin/python3.9"
            virtualenv="venv"
            shift
            ;;
        -b|--bin)
            bin=$2
            shift 2
            ;;
        -s|--source)
            checkpath $2
            if ls $2/*.whl >/dev/null 2>&1 ; then
                SRC+=("$2/*.whl")
            fi
            shift 2
            ;;
        -d|--dest)
            checkpath $2
            DEST=$2
            shift 2
            ;;
        -n|--no-deps)
            nodeps="--no-deps"
            shift
            ;;
        -c|--compile)
            compile=y
            shift
            ;;
        *)
            help
            exit 1
            ;;
    esac
done

# Get absolute path of python
if [ "$bin" != "" ]; then
    python="${bin}"
else
    python=$(command -v $python)
fi

USE_PIP=true
if [ "$USE_PIP" == "true" ]; then
    # To avoid issues when the builder is not an ephimeral environment,
    # a virtualenv is used avoiding systemwide changes.
    # Having a new version of pip, use of virtualenv isn't mandatory:
    # pip can be used instead, adding some extra flags
    # > pip install --force-reinstall --ignore-installed --upgrade --no-index \
    # > --prefix ${DEST} $SRC/*.whl
    #
    # See: https://pip.pypa.io/en/stable/user_guide/#installation-bundles

    checkcmd $python find
    md5sum ${SRC[@]}
    #which pip3.9
	#created venv for openquake
	sudo -H python -m venv /opt/openquake/venv
     
    # required by some new wheel
    sudo -H /opt/openquake/venv/bin/pip3 install ./py/setuptools-56.0.0-py3-none-any.whl
    
    sudo -H /opt/openquake/venv/bin/pip3 install ${nodeps} --no-index --prefix ${DEST} ${SRC[@]}
   
    # Cleanup
    # find ${DEST} -name '*.pyc' -o -name '__pycache__' -exec rm -Rf {} \;
    find ${DEST} -name '*.pyc' -o -name '__pycache__' -print0 | xargs -0 rm -Rf

    if [ ! -z $compile ]; then
        # Python 2.7 is a bit fussy, compileall returns error even
        # because of warnings we then force exit code 0 to make Travis happy
        $python -m compileall $DEST || true
    fi
else
    # FIXME: never happens
    checkcmd unzip
    for w in ${SRC[@]}; do
        unzip $w -d $DEST
    done
fi
