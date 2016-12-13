#!/bin/bash

#set -x
set -e

help() {
    cat <<HSD
The command line arguments are as follows:
    -w, --wheelhouse     Destination target where Python code wil be installed
    -m, --mirror         Mirror to use
    -h, --help           This help
HSD
    exit 0
}


checkpath() {
    if [ ! -d $1 ]; then
        echo "ERROR: $1 path does not exist" 1>&2
        exit 1
    fi
    if [ ! -f $1/requirements.txt ]; then
        echo "ERROR: requirements.txt missing in $1" 1>&2
        exit 1
    fi
}

checkcmd() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "This script requires '$1' but it isn't available. Aborting."; exit 1; }
}

if [ $# -lt 2 -o "$1" == "-h" -o "$1" == "--help" ]; then
    help;
fi

MIRROR='http://ftp.openquake.org/wheelhouse/linux'
declare -a WH

while (( "$#" )); do
    case "$1" in
        -w|--wheelhouse)
            checkpath $2
            WH+=("$2"); shift;;
        -m|--mirror)
            MIRROR="$2"; shift;;
        *)
            shift;;
    esac
done

checkcmd curl

for d in "${WH[@]}"; do
    cd $d
    while read l
    do
        url=${MIRROR}/${d}/${l}
        echo "Downloading $url"
        curl -LOsz $l $url || echo >&2 "Download of $url failed"
    done < requirements.txt
    cd ..
done

