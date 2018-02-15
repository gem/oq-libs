# -*- coding: utf-8 -*-
# vim: syntax=spec
#
# Copyright (C) 2015-2018 GEM Foundation
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

# Make sure that the proper installation of python is used by macros
%define __python3 /opt/openquake/bin/python3
%define __python %{__python3}
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
%define oqname python3-%{oqrepo}
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

Requires: oq-python35
BuildRequires: oq-python35 sed

Provides: python-oq-libs

AutoReqProv: no
AutoReq: no
AutoProv: no

%description

Libraries for OpenQuake

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2018 GEM Foundation


%package extra
Summary:        Extra libraries for OpenQuake
Group:          Applications/Engineering
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description extra

Extra libraries for OpenQuake

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2018 GEM Foundation

%prep
%setup -n %{oqformat}
%setup -n %{oqformat} -T -D -a 1

%install
install -p -m 755 -d %{buildroot}/opt/openquake
install -p -m 755 -d %{buildroot}/opt/openquake/bin
helpers/whlsetup.sh -3 -b /opt/openquake/bin/python3.5 -d %{buildroot}/opt/openquake -s py -s py35 -s py35-extra
install -p -m 755 -d %{buildroot}/opt/openquake/lib/python3.5/site-packages/openquake/libs
install -p -m 644 openquake/libs/__init__.py %{buildroot}/opt/openquake/lib/python3.5/site-packages/openquake/libs
# These aren't required anymore, but leaving them in case of PYTHONPATH is used
install -p -m 644 openquake/__init__.py %{buildroot}/opt/openquake/lib/python3.5/site-packages/openquake
install -p -m 644 openquake/__init__.py %{buildroot}/opt/openquake/lib64/python3.5/site-packages/mpl_toolkits

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/opt/openquake
%exclude /opt/openquake/lib64/python3.5/site-packages/basemap*
%exclude /opt/openquake/lib64/python3.5/site-packages/mpl_toolkits*

%files extra
/opt/openquake/lib64/python3.5/site-packages/basemap*
/opt/openquake/lib64/python3.5/site-packages/mpl_toolkits*


%changelog
%if %{oqstable} == 1
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqrelease}
– Stable release of %{oqname}
%else
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqtimestamp}_%{oqrelease}
– Unstable release of %{oqname}
%endif
