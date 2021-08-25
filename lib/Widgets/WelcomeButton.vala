/*
 * Copyright 2014-2017 Artem Anufrij <artem.anufrij@live.de>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Granite.Widgets.WelcomeButton : Gtk.Button {

    Gtk.Label button_title;
    Gtk.Label button_description;
    Gtk.Image? _icon;
    Gtk.Grid button_grid;

    /**
     * Title property of the Welcome Button
     *
     * @since 0.3
     */
    public string title {
        get { return button_title.get_text (); }
        set { button_title.set_text (value); }
    }

    /**
     * Description property of the Welcome Button
     *
     * @since 0.3
     */
    public string description {
        get { return button_description.get_text (); }
        set { button_description.set_text (value); }
    }

    /**
     * Image of the Welcome Button
     *
     * @since 0.3
     */
    public Gtk.Image? icon {
        get { return _icon; }
        set {
            if (_icon != null) {
                _icon.destroy ();
            }
            _icon = value;
            if (_icon != null) {
                _icon.set_pixel_size (48);
                _icon.halign = Gtk.Align.CENTER;
                _icon.valign = Gtk.Align.CENTER;
                button_grid.attach (_icon, 0, 0, 1, 2);
            }
        }
    }

    public WelcomeButton (Gtk.Image? image, string option_text, string description_text) {
        Object (title: option_text, description: description_text, icon: image);
    }

    construct {
        // Title label
        button_title = new Gtk.Label (null);
        button_title.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        button_title.halign = Gtk.Align.START;
        button_title.valign = Gtk.Align.END;

        // Description label
        button_description = new Gtk.Label (null);
        button_description.halign = Gtk.Align.START;
        button_description.valign = Gtk.Align.START;
        button_description.set_line_wrap (true);
        button_description.set_line_wrap_mode (Pango.WrapMode.WORD);
        button_description.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        // Button contents wrapper
        button_grid = new Gtk.Grid ();
        button_grid.column_spacing = 12;

        button_grid.attach (button_title, 1, 0, 1, 1);
        button_grid.attach (button_description, 1, 1, 1, 1);
        this.add (button_grid);
    }
}
