#!/bin/bash

set -x
set -e

help() {
    cat <<HSD
The command line arguments are as follows:
    -2, -3               Use Python 2 or Python 3
    -s, --source         Location of wheels
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

if [ $# -lt 5 -o "$1" == "-h" -o "$1" == "--help" ]; then
    help;
fi

while (( "$#" )); do
    case "$1" in
        -2)
            py=2; shift;;
        -3)
            py=3; shift;;
        -s|--source)
            checkpath $2
            SRC=$2; shift;;
        -d|--dest)
            checkpath $2
            DEST=$2; shift;;
        *)
            shift;;
    esac
done

VENV=$(mktemp -d)
virtualenv-${py} $VENV

source $VENV/bin/activate
pip${py} install -U pip wheel

pip${py} install --target=${DEST} $SRC/*.whl

# Cleanup
deactivate
rm -Rf $VENV
