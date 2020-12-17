#!/bin/bash
# set -x
for f in py36/requirements-bin.txt py36-extra/requirements-bin.txt; do
    IFS='
'
    for pkg in $(cat $f); do
        pkg_name="$(echo "$pkg" | sed 's@-.*@@g')"
        oq_row=$(cat ../oq-engine/requirements-*py36-linux*.txt | grep "/${pkg_name}-")
        oq_pkg=$(echo "${oq_row}" | sed "s@.*/${pkg_name}-@${pkg_name}-@g")
        if [ "$pkg" = "$oq_pkg" ]; then
            continue
        fi
        echo "xx $pkg yy zz"
        echo "yy $oq_pkg vv"
        echo
    done
done
