# Granite
[![Packaging status](https://repology.org/badge/tiny-repos/granite.svg)](https://repology.org/metapackage/granite)
[![Translation status](https://l10n.elementary.io/widgets/desktop/granite/svg-badge.svg)](https://l10n.elementary.io/projects/desktop/granite/?utm_source=widget)

## Building, Testing, and Installation

You'll need the following dependencies:
* cmake
* gobject-introspection
* libgee-0.8-dev
* libgirepository1.0-dev
* libgtk-3-dev
* valac

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make all test` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`

    sudo make install

To see a demo app of Granite's widgets, use 'granite-demo'

    granite-demo

## Documentation

Documentation for all of the classes and functions in Granite is available [on Valadoc](https://valadoc.org/granite/Granite.html)

To generate Vala documentation from this repository, use `make valadocs`

    make valadocs

To generate C documentation from this repository, use `make cdocs`

    make cdocs

To generate both C and Vala documentation at once, use `make docs`

    make docs
