# OpenQuake Engine

![OpenQuake Logo](https://github.com/gem/oq-infrastructure/raw/master/logos/oq-logo.png)

The **OpenQuake Engine** is an open source application that allows users to compute **seismic hazard** and **seismic risk** of earthquakes on a global scale. It runs on Linux, macOS and Windows, on laptops, workstations, standalone servers and multi-node clusters.

## Libraries

This repo includes code to assemble the `python-oq-libs` packages (`deb` and `rpm`) and the index of libraries used by other installers (`macOS` and `Windows`). The `python-oq-libs` package provides the python code and binary libraries needed to run the OpenQuake software.

## License

The OpenQuake code is released under the **[GNU Affero Public License 3](https://github.com/gem/oq-libs/blob/master/LICENSE)**.
Binary packages include third-parties code: a list of licenses for each library is provided under [doc/licenses](doc/licenses). 
