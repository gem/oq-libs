#!/bin/bash
set -x
PKG_NAME=python-oq-libs
if [ $# -ne 1 ]; then
    echo "pass version as argument"
    exit 1
fi
if [ "$DEBEMAIL" = "" -o "$DEBFULLNAME" = "" ]; then
    echo "env vars DEBEMAIL and/or DEBFULLNAME not set"
    exit 1
fi
PKG_VERS=$1
BDIR=$(mktemp -d)
PDIR=${BDIR}/transdeb/${PKG_NAME}-${PKG_VERS}
mkdir -p ${PDIR}/debian

cat <<EOF >${PDIR}/debian/rules
#!/usr/bin/make -f

%:
	dh \$@
EOF
chmod a+x ${PDIR}/debian/rules

echo "9" >${PDIR}/debian/compat

cat <<EOF >${PDIR}/debian/control
Source: python-oq-libs
Section: python
Priority: optional
Maintainer: $DEBFULLNAME <$DEBEMAIL>
Build-Depends: debhelper (>=9)
Standards-Version: 3.9.6

Package: python-oq-libs
Architecture: amd64
Depends: python3-oq-libs, ${misc:Depends}
Description: transitional package
  This is a transitional package. It can safely be removed.

Package: python-oq-libs-extra
Architecture: amd64
Depends: python3-oq-libs-extra, ${misc:Depends}
Description: transitional package
  This is a transitional package. It can safely be removed.

EOF

mkdir ${PDIR}/tree

cd ${PDIR}

for distro in trusty xenial; do 
    cat <<EOF >debian/changelog
$PKG_NAME ($PKG_VERS~${distro}01) ${distro}; urgency=medium

  * Transitional package.

 -- $DEBFULLNAME <$DEBEMAIL>  $(date -R)

EOF

    debuild -S
done

echo "Files to be uploaded are at ${BDIR}/transdeb"

exit 0
