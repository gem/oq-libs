#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2016 GEM Foundation
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
The command line arguments are as follows:
    -2, -3               Use Python 2 or Python 3
    -s, --source         Location of wheels (can be used multiple times)
    -d, --dest           Destination target where Python code wil be installed
    -h, --help           This help
HSD
}

checkpath() {
    if [ ! -d $1 ]; then
        echo "ERROR: $1 path does not exist" 1>&2
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
            py=2; shift;;
        -3)
            echo "Unsupported" 1>&2; exit 1;;
        -s|--source)
            checkpath $2
            SRC+=("$2/*.whl"); shift;;
        -d|--dest)
            checkpath $2
            DEST=$2; shift;;
        *)
            shift;;
    esac
done

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

    checkcmd virtualenv find

    VENV=$(mktemp -d)
    virtualenv $VENV
    source $VENV/bin/activate

    # lib64 is forced to be a symlink to lib, like virtualenv does
    # itself. This semplifies the use of PYTHONPATH since only one
    # path (the one with 'lib') must be added instead of two
    mkdir ${DEST}/lib
    ln -rs ${DEST}/lib ${DEST}/lib64

    pip install --no-index --prefix ${DEST} ${SRC[@]}

    # Cleanup
    deactivate
    rm -Rf $VENV

    # replace scripts hashbang with the python executable provided
    # by the system, instead of the one provided by virtualenv
    sed -i "s|${VENV}/bin/python.*|/usr/bin/env python|g" ${DEST}/bin/*
    find ${DEST} -name '*.pyc' -delete
else
    # FIXME: never happens
    checkcmd unzip
    for w in ${SRC[@]}; do
        unzip $w -d $DEST
    done
fi
