#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2016-2018 GEM Foundation
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
    -2, -3               Use Python 2.7 or Python 3.5
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

while [ $# -gt 0 ]; do
    case "$1" in
        -2)
            python="python2.7"
            virtualenv="virtualenv"
            shift
            ;;
        -3)
            PATH="/opt/openquake/bin:$PATH"
            python="python3.5"
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
    if [ 0 -eq 1 ]; then
        VENV=$(mktemp -d)
        if [ "$virtualenv" == "virtualenv" ]; then
            if [ $(virtualenv --version | cut -d '.' -f 1) -ge 11 ]; then
                no_download="--no-download"
            else
                no_download="--never-download"
            fi
        fi
        
        $python -m $virtualenv $no_download $VENV
        source $VENV/bin/activate
        # lib64 is forced to be a symlink to lib, like virtualenv does
        # itself. This semplifies the use of PYTHONPATH since only one
        # path (the one with 'lib') must be added instead of two
        # For python3 this is not required
        if echo $python | grep -q 'python2'; then
            mkdir ${DEST}/lib
            ln -rs ${DEST}/lib ${DEST}/lib64
        fi
    fi

    pip install ${nodeps} --no-index --install-option="--install-layout=deb" --prefix ${DEST} ${SRC[@]}

    # Cleanup
    if [ 0 -eq 1 ]; then
        deactivate
        rm -Rf $VENV

        # replace scripts hashbang with the python executable provided
        # by the system, instead of the one provided by virtualenv
        find ${DEST} -type f -print0 | xargs -0 sed -i "s|${VENV}/bin/python.*|$python|g"
    fi
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
