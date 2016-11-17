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
            echo "Unsupported" 1>&2; exit 1;;
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

# FIXME: never happens
if [ "$VENV" == "true" ]; then
    VENV=$(mktemp -d)
    virtualenv $VENV

    source $VENV/bin/activate
    pip install --target=${DEST} $SRC/*.whl

    # Cleanup
    deactivate
    rm -Rf $VENV
else
    for w in $SRC/*.whl; do
        unzip $w -d $DEST
    done
fi
