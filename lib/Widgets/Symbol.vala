/*
* SPDX-License-Identifier: LGPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
*/

namespace Granite.SymbolState {
    // The default state
    public const string NORMAL = "normal";
    // Disabled state represented by a slash
    public const string DISABLED = "disabled";
    // e.g. paired, connected, needs attention
    public const string ACTIVE = "active";
}

public class Granite.Symbol : Granite.Bin {
    public string resource_path { get; construct; }

    public int pixel_size {
        get { return image.pixel_size; }
        set { image.pixel_size = value; }
    }

    public uint state_index {
        get { return svg.state; }
        set {
            uint length = -1;
            svg.get_state_names (out length);

            if (value > length - 1) {
                warning ("Granite.Symbol set to undefined state. Ignoring.");
                return;
            }

            svg.state = value;
            notify_property ("state");
        }
    }

    public string state {
        get {
            uint length = -1;
            return svg.get_state_names (out length)[state_index];
        }
        set {
            uint length = -1;
            var names = svg.get_state_names (out length);

            for (int i = 0; i < length; i++) {
                if (names[i] == value) {
                    state_index = i;
                    return;
                }
            }

            warning ("Granite.Symbol set to undefined state. Ignoring.");
        }
    }

    private Gtk.Image image;
    private Gtk.Svg svg;

    public Symbol (string resource_path) {
        Object (resource_path: resource_path);
    }

    construct {
        svg = new Gtk.Svg.from_resource (resource_path);

        image = new Gtk.Image.from_paintable (svg);

        child = image;

        child.realize.connect (() => {
            svg.set_frame_clock (get_frame_clock ());
            svg.play ();
        });
    }
}
