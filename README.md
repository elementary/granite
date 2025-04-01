# Granite
Granite is a companion library for GTK and GLib. Among other things, it
provides complex widgets and convenience functions designed for use in apps
built for elementary OS.

[![Packaging status](https://repology.org/badge/tiny-repos/granite.svg)](https://repology.org/metapackage/granite)
[![Translation status](https://l10n.elementary.io/widgets/desktop/-/granite/svg-badge.svg)](https://l10n.elementary.io/engage/desktop/?utm_source=widget)


## Building, Testing, and Installation

You'll need the following dependencies:
* meson >= 0.57.0
* gobject-introspection
* gettext
* libgee-0.8-dev
* libgirepository1.0-dev
* libgtk-4-dev >= 4.4.0
* sassc
* valac

To build the Demo you'll additionally need:
* libshumate-dev

Run `meson build` to configure the build environment:

    meson build --prefix=/usr

This command creates a `build` directory. For all following commands, change to
the build directory before running them.

To build granite, use `ninja`:

    ninja

To install, use `ninja install`

    ninja install

To see a demo app of Granite's widgets, run `granite-7-demo` after installing it:

    granite-7-demo


## Documentation

Documentation for all of the classes and functions in Granite is available
[on Valadoc](https://valadoc.org/granite-7/Granite.html)

The additional requirements for building the documentation are:

* valadoc
* gtk-doc

To generate gtk-doc and valadoc documentation for this project, pass the
additional `-Ddocumentation=true` flag to meson, and run `ninja` as before.

