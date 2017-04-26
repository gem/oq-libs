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
USAGE:

$0 [-m <mirror-url>] -w <dir1> [-w <dir2> []]
$0 -h

The command line arguments are as follows:
    -w, --wheelhouse     Destination target where Python code wil be installed
    -m, --mirror         Mirror to use
    -h, --help           This help
HSD
}

checkpath() {
    if [ ! -d $1 ]; then
        echo "ERROR: $1 path does not exist" 1>&2
        exit 1
    fi
    if [ ! -f $1/requirements-bin.txt ]; then
        echo "ERROR: requirements-bin.txt missing in $1" 1>&2
        exit 1
    fi
}

checkcmd() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "This script requires '$1' but it isn't available. Aborting."; exit 1; }
}

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    help
    exit 0
elif [ $# -lt 2 ]; then
    help
    exit 1
fi

MIRROR='http://ftp.openquake.org/wheelhouse/linux'
declare -a WH

while [ $# -gt 0 ]; do
    case "$1" in
        -w|--wheelhouse)
            checkpath $2
            WH+=("$2")
            shift 2
            ;;
        -m|--mirror)
            MIRROR="$2"
            shift 2
            ;;
        *)
            help
            exit 1
            ;;
    esac
done

checkcmd curl

for d in "${WH[@]}"; do
    cd $d
    cat requirements-bin.txt | while read l; do
        if [ ${l:0:1} == "#" ]; then
            continue
        fi
        url=${MIRROR}/${d%-*}/${l}
        echo "Downloading $url"
        curl -LOsz $l $url || { echo >&2 "Download of $url failed" ; exit 1; }
    done
    cd ..
done
