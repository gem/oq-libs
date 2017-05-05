## Engine + Hazardlib ##
- setuptools
- pkgconfig
- Cython==0.23.4
- mock==1.3.0
- coverage==3.7.1 (linux only)
- h5py==2.6.0
- nose==1.3.7
- numpy==1.11.1
- scipy==0.17.1
- psutil==3.4.2
- shapely==1.5.13
- docutils==0.12
- decorator==4.0.11
- funcsigs==1.0.2
- pbr==1.8.0
- six==1.10.0
- futures==3.0.5
- django==1.8.17
- requests==2.9.1
- pyshp==1.2.3
- Rtree==0.8.2 (linux only)
- python-prctl==1.6.1 (linux only)

### Celery support ###
- pytz
- anyjson==0.3.3
- amqp==1.4.9
- kombu==3.0.33
- billiard==3.3.0.22
- celery==3.1.20

### WebUI ###
- gunicorn
- python-pam (linux only)
- django-pam (linux only)

## HMTK ##
- Hazardlib
- PyYAML==3.12

### Plotting ###
- matplotlib==1.5.3
- pyparsing==2.1.10
- cycler==0.10.0
- python_dateutil==2.6.0
- basemap==1.1.0
- pyproj==1.9.5.1

## GMPE-SMTK ##
- Hazardlib
- PyYAML==3.12

## Platform Standalone ##

- Engine
- Hazardlib
- django==1.8.7

## Notes ##

Libraries in _italic_ are currently not packaged in rpm and deb packages.

### PyYAML ###
Xenial ships 3.11, but to be able to make a wheel 3.12 is needed and will be used

### Matplotlib ###
Xenial ships 1.5.1, but an official wheel exists for 1.5.3

### PyPROJ ###
Xenial ships 1.8.9, but pyproj 1.8.9 sources disappeared from upstream. We use 1.9.5.1

### Django ###
Xenial ships 1.8.7, but we'll use the latest release in 1.8 tree

### Basemap ###
Basemap stable is 1.0.7 but it's incompatible with wheels; we are using 1.1.0 from github.
Currently it is not included in `oq-libs` because of its size. The plan is to move it
in an 'extra' package.

### Decorator ###
Xenial ships 4.0.10, but it has a small issue with packaging. Using 4.0.11 instead.
