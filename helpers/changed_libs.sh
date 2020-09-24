#!/bin/bash
# to extract libraries name use something like:
#   for i in $(cat req_3.9.txt req_3.10.txt | grep '\.whl$'); \
#      do name="$(echo "$i" | sed 's/-.*//g')" ; echo $name ; done | sort | uniq > lista_whl
# where req_*.txt are complete list of deps for spec version of engine
for i in $(cat lista_whl); do
    r39="$(grep "${i}-" req_3.9.txt)"
    r310="$(grep "${i}-" req_3.10.txt)"
    if [ "$r39" != "" -a "$r310" == "" ]; then
        echo "  * removed $r39"
    elif [ "$r39" == "" -a "$r310" != "" ]; then
        echo "  * added $r310"
    else
        vv="$(echo "$r310" | sed 's/^[^-]\+-//g')"
        echo "  * update $i to version $vv"
    fi
    # ; echo "$i" ; echo "3.9  =>$r39" ; echo "3.10 =>$r310" ; 
done
