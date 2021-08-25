/*
 * Copyright 2012-2017 elementary, Inc. (https://elementary.io)
 * Copyright 2012-2017 Corentin Noël <corentin@elementary.io>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * The AlertView widget shows to the user that some actions are now restricted.
 *
 * It can be used to show an empty view or hiding a panel when this one is disabled.
 *
 * {{../doc/images/AlertView.png}}
 *
 * ''Example''<<BR>>
 * {{{
 * public class AlertViewView : Gtk.Grid {
 *     construct {
 *         var alert = new Granite.Widgets.AlertView ("Nothing here", "Maybe you can enable <b>something</b> to hide it but <i>otherwise</i> it will stay here", "dialog-warning");
 *         alert.show_action ("Hide this button");
 *
 *         alert.action_activated.connect (() => {
 *             alert.hide_action ();
 *         });
 *
 *         add (alert);
 *     }
 * }
 * }}}
 */
public class Granite.Widgets.AlertView : Gtk.Grid {
    public signal void action_activated ();

    /**
     * The first line of text, should be short and not contain markup.
     */
    public string title {
        get {
            return title_label.label;
        }
        set {
            title_label.label = value;
        }
    }

    /**
     * The second line of text, explaining why this alert is shown.
     * You may need to escape it with #escape_text or #printf_escaped
     */
    public string description {
        get {
            return description_label.label;
        }
        set {
            description_label.label = value;
        }
    }

    /**
     * The icon name
     */
    public string icon_name {
        owned get {
            return image.icon_name ?? "";
        }
        set {
            if (value != null && value != "") {
                image.set_from_icon_name (value, Gtk.IconSize.DIALOG);
                image.no_show_all = false;
                image.show ();
            } else {
                image.no_show_all = true;
                image.hide ();
            }
        }
    }

    private Gtk.Label title_label;
    private Gtk.Label description_label;
    private Gtk.Image image;
    private Gtk.Button action_button;
    private Gtk.Revealer action_revealer;

    /**
     * Makes new AlertView
     *
     * @param title the first line of text
     * @param description the second line of text
     * @param icon_name the icon to be shown
     */
    public AlertView (string title, string description, string icon_name) {
        Object (title: title, description: description, icon_name: icon_name);
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        title_label = new Gtk.Label (null);
        title_label.hexpand = true;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        title_label.max_width_chars = 75;
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        title_label.xalign = 0;

        description_label = new Gtk.Label (null);
        description_label.hexpand = true;
        description_label.max_width_chars = 75;
        description_label.wrap = true;
        description_label.use_markup = true;
        description_label.xalign = 0;
        description_label.valign = Gtk.Align.START;

        action_button = new Gtk.Button ();
        action_button.margin_top = 24;

        action_revealer = new Gtk.Revealer ();
        action_revealer.add (action_button);
        action_revealer.halign = Gtk.Align.END;
        action_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;

        image = new Gtk.Image ();
        image.margin_top = 6;
        image.valign = Gtk.Align.START;

        var layout = new Gtk.Grid ();
        layout.column_spacing = 12;
        layout.row_spacing = 6;
        layout.halign = Gtk.Align.CENTER;
        layout.valign = Gtk.Align.CENTER;
        layout.vexpand = true;
        layout.margin = 24;

        layout.attach (image, 1, 1, 1, 2);
        layout.attach (title_label, 2, 1, 1, 1);
        layout.attach (description_label, 2, 2, 1, 1);
        layout.attach (action_revealer, 2, 3, 1, 1);

        add (layout);

        action_button.clicked.connect (() => {action_activated ();});
    }

    /**
     * Creates the action button with the given label
     *
     * @param label the text of the action button
     */
    public void show_action (string? label = null) {
        if (label != null)
            action_button.label = label;

        if (action_button.label == null)
            return;

        action_revealer.set_reveal_child (true);
        action_revealer.show_all ();
    }

    /**
     * Hides the action button.
     */
    public void hide_action () {
        action_revealer.set_reveal_child (false);
    }
}
