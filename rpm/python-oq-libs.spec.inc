%define oqstable ##_stable_##
%define oqrepo ##_repo_##
%define oqversion ##_version_##
%define oqrelease ##_release_##
%define oqname python-%{oqrepo}
%define oqtimestamp ##_timestamp_##
%define oquser openquake

Summary: Libraries for OpenQuake
Name: %{oqname}
Version: %{oqversion}
License: AGPLv3
Group: Applications/Engineering
%if %{oqstable} == 1
Release: %{oqrelease}
Source0: %{oqrepo}-%{oqversion}.tar.gz
BuildRoot: %{_tmppath}/%{oqname}-%{oqversion}-buildroot
%else
Release: %{oqtimestamp}_%{oqrelease}
Source0: %{oqrepo}-%{oqversion}-%{oqrelease}.tar.gz
BuildRoot: %{_tmppath}/%{oqname}-%{oqversion}-%{oqrelease}-buildroot
%endif
Prefix: %{_prefix}
Vendor: The GEM OpenQuake team <devops@openquake.org>
Url: http://github.com/gem/oq-libs

Requires: python
BuildRequires: python unzip

AutoReqProv: no
AutoReq: no
AutoProv: no

%description

OpenQuake is an open source application that allows users to
compute seismic hazard and seismic risk of earthquakes on a global scale.

Copyright (C) 2010-2016 GEM Foundation

%prep
%if %{oqstable} == 1
%setup -n %{oqrepo}-%{oqversion} -n %{oqrepo}-%{oqversion}
%else
%setup -n %{oqrepo}-%{oqversion}-%{oqrelease} -n %{oqrepo}-%{oqversion}-%{oqrelease}
%endif

%install
mkdir -p %{buildroot}/opt/openquake/lib/python2.7/site-packages
bin/whlsetup.sh -2 -d %{buildroot}/opt/openquake/lib/python2.7/site-packages -s py27

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/opt/openquake

%changelog
%if %{oqstable} == 1
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqrelease}
– Stable release of %{oqname}
%else
* %(date -d @%{oqtimestamp} '+%a %b %d %Y') GEM Automatic Packager <gem-autopack@openquake.org> %{oqversion}-%{oqtimestamp}_%{oqrelease}
– Unstable release of %{oqname}
%endif
