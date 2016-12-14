#!/bin/bash

set -x
set -e

help() {
    cat <<HSD
The command line arguments are as follows:
    -2, -3               Use Python 2 or Python 3
    -s, --source         Location of wheels (can be used multiple times)
    -d, --dest           Destination target where Python code wil be installed
    -h, --help           This help
HSD
    exit 0
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

if [ $# -lt 5 -o "$1" == "-h" -o "$1" == "--help" ]; then
    help
fi

declare -a SRC

while (( "$#" )); do
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
    # a virtualenv is used to avoid systemwide changes on it.
    # Having a new version of pip, use of virtualenv can be skipped adding
    # some extra pip flags:
    # > pip install --force-reinstall --ignore-installed --upgrade --no-index \
    # > --prefix ${DEST} $SRC/*.whl
    #
    # See: https://pip.pypa.io/en/stable/user_guide/#installation-bundles

    checkcmd virtualenv

    VENV=$(mktemp -d)
    virtualenv $VENV
    source $VENV/bin/activate

    # lib64 is force to be a symlink to lib, like virtualenv does
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

else
    # FIXME: never happens
    checkcmd unzip
    for w in ${SRC[@]}; do
        unzip $w -d $DEST
    done
fi
