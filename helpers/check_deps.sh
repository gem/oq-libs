#!/bin/bash
# set -x
for f in py38/requirements-bin.txt; do
    IFS='
'
    for pkg in $(cat $f); do
        if echo "$pkg" | grep -q '^#' ; then
            continue
        fi
        pkg_name="$(echo "$pkg" | sed 's@-.*@@g')"
        oq_row=$(cat ../oq-engine/requirements-*py38-linux*.txt | grep "/${pkg_name}-")
        oq_pkg=$(echo "${oq_row}" | sed 's/ \+$//g' | sed "s@.*/${pkg_name}-@${pkg_name}-@g")
        if [ "$pkg" = "$oq_pkg" ]; then
            continue
        fi
        echo "xx $pkg yy"
        echo "yy $oq_pkg vv"
        echo
    done
done
