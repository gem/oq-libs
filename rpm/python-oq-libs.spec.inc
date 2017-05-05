# Because of gunicorn:
# https://lists.fedoraproject.org/pipermail/devel/2010-April/135366.html
# http://stackoverflow.com/questions/25611140/syntax-error-installing-gunicorn
%global _python_bytecompile_errors_terminate_build 0
# Do not try to strip symbols from .so
# even if does not fail the build, mask it
%define __strip /bin/true

%define oqstable ##_stable_##
%define oqrepo ##_repo_##
%define oqversion ##_version_##
%define oqrelease ##_release_##
%define oqname python-%{oqrepo}
%define oqtimestamp ##_timestamp_##
%define oquser openquake

%if %{oqstable} == 1
%define oqformat %{oqrepo}-%{oqversion}
Release: %{oqrelease}
%else
%define oqformat %{oqrepo}-%{oqversion}-%{oqrelease}
Release: %{oqtimestamp}_%{oqrelease}
%endif

Summary: Libraries for OpenQuake
Name: %{oqname}
Version: %{oqversion}
License: AGPLv3
Group: Applications/Engineering
Source0: %{oqformat}.tar.gz
Source1: %{oqrepo}-whl-%{oqversion}.tar.gz
BuildRoot: %{_tmppath}/python-%{oqformat}-buildroot
Prefix: %{_prefix}
Vendor: The GEM OpenQuake team <devops@openquake.org>
Url: http://github.com/gem/oq-libs

Requires: python
BuildRequires: python python-virtualenv >= 15 sed

AutoReqProv: no
AutoReq: no
AutoProv: no

%description

Libraries for OpenQuake

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2017 GEM Foundation


%package extra
Summary:        Extra libraries for OpenQuake
Group:          Applications/Engineering
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description extra

Extra libraries for OpenQuake

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2017 GEM Foundation

%prep
%setup -n %{oqformat}
%setup -n %{oqformat} -T -D -a 1

%install
install -p -m 755 -d %{buildroot}/opt/openquake
helpers/whlsetup.sh -2 -d %{buildroot}/opt/openquake -s py -s py27 -s py27-extra
install -p -m 755 -d %{buildroot}/opt/openquake/lib/python2.7/site-packages/openquake/libs
install -p -m 644 openquake/__init__.py %{buildroot}/opt/openquake/lib/python2.7/site-packages/openquake
install -p -m 644 openquake/libs/__init__.py %{buildroot}/opt/openquake/lib/python2.7/site-packages/openquake/libs
install -p -m 644 openquake/__init__.py %{buildroot}/opt/openquake/lib/python2.7/site-packages/mpl_toolkits

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/opt/openquake
/opt/openquake/*
%exclude /opt/openquake/lib/python2.7/site-packages/basemap*
%exclude /opt/openquake/lib/python2.7/site-packages/mpl_toolkits*

%files extra
/opt/openquake/lib/python2.7/site-packages/basemap*
/opt/openquake/lib/python2.7/site-packages/mpl_toolkits*


%changelog
%if %{oqstable} == 1
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqrelease}
– Stable release of %{oqname}
%else
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqtimestamp}_%{oqrelease}
– Unstable release of %{oqname}
%endif
