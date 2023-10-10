# -*- coding: utf-8 -*-
# vim: syntax=spec
#
# Copyright (C) 2015-2019 GEM Foundation
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

# Override default installation
%define _prefix /opt/openquake

# Make sure that the proper installation of python is used by macros
%define __python3 %{_bindir}/python3.6
%define __python %{__python3}

# Disable shebang checks
%define __brp_mangle_shebangs /bin/true

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

Requires: oq-python36
BuildRequires: oq-python36 sed

Provides: python-oq-libs
Obsoletes: python-oq-libs python2-oq-libs

AutoReqProv: no
AutoReq: no
AutoProv: no

%description

Libraries for OpenQuake

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2019 GEM Foundation


%package extra
Summary:        Extra libraries for OpenQuake
Group:          Applications/Engineering
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description extra

Extra libraries for OpenQuake

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2019 GEM Foundation

%prep
%setup -n %{oqformat}
%setup -n %{oqformat} -T -D -a 1

%install
install -p -m 755 -d %{buildroot}%{_prefix}
install -p -m 755 -d %{buildroot}%{_bindir}
GEM_SET_DEBUG=1 helpers/whlsetup.sh -36 -b %{__python3} -d %{buildroot}%{_prefix} -s py -s py36
install -p -m 755 -d %{buildroot}%{_prefix}/lib/python3.6/site-packages/openquake/libs
install -p -m 644 openquake/libs/__init__.py %{buildroot}%{_prefix}/lib/python3.6/site-packages/openquake/libs
# These aren't required anymore, but leaving them in case of PYTHONPATH is used
install -p -m 644 openquake/__init__.py %{buildroot}%{_prefix}/lib/python3.6/site-packages/openquake
install -p -m 644 openquake/__init__.py %{buildroot}%{_prefix}/lib64/python3.6/site-packages/mpl_toolkits

%clean
rm -rf %{buildroot}

# Convert lib64 symlink into a real dir to avoid transaction conflicts during upgrades.
# See: https://fedoraproject.org/wiki/Packaging:Directory_Replacement#Scriptlet_to_replace_a_symlink_to_a_directory_with_a_directory
%pretrans -p <lua>
path = "%{_libdir}"
st = posix.stat(path)
if st and st.type == "link" then
  os.remove(path)
end

%files
%defattr(-,root,root)
%{_prefix}

%files extra


%changelog
%if %{oqstable} == 1
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqrelease}
– Stable release of %{oqname}
%else
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqtimestamp}_%{oqrelease}
– Unstable release of %{oqname}
%endif
