/*
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A dialog presenting a message or a question
 */
[Version (since = "9.0.0")]
public class Granite.AlertDialog : Gtk.Window {
    public signal void response (string response_id);

    /**
    * Describes the possible styles of {@link Granite.AlertDialog} response buttons
    */
    public enum ButtonStyle {
        // Default button appearance.
        DEFAULT,
        // The primary suggested affirmative action/
        SUGGESTED,
        // Used to draw attention to the potentially damaging consequences. This appearance acts as a warning.
        DESTRUCTIVE;

        public string to_string () {
            switch (this) {
                case DESTRUCTIVE:
                    return Granite.CssClass.DESTRUCTIVE;
                case SUGGESTED:
                    return Granite.CssClass.SUGGESTED;
                default:
                    return "";
            }
        }
    }

    /**
     * The secondary text, body of the dialog.
     */
    public string secondary_text { get; construct set; }

    /**
     * The {@link GLib.Icon} that is used to display the primary_icon representing the app making the request
     */
    public GLib.Icon primary_icon { get; set; }

    /**
     * The {@link GLib.Icon} that is used to display a secondary_icon representing the action to be performed
     */
    public GLib.Icon secondary_icon { get; set; }

    /**
     * The child widget for the content area
     */
    public Gtk.Widget content { get; set; }

    private Granite.Box button_box;
    private SimpleActionGroup action_group;

    /**
     * Constructs a new {@link Granite.AlertDialog}.
     * See {@link Granite.AlertDialog} for more details.
     *
     * @param title the title of the dialog
     * @param secondary_text the body of the dialog
     */
    public AlertDialog (string title, string secondary_text) {
        Object (
            title: title,
            secondary_text: secondary_text
        );
    }

    static construct {
        Granite.init ();
    }

    construct {
        var primary_icon = new Gtk.Image.from_icon_name ("") {
            halign = START,
            icon_size = LARGE
        };

        var secondary_icon = new Gtk.Image.from_icon_name ("") {
            halign = END,
            icon_size = LARGE
        };

        var overlay = new Gtk.Overlay () {
            child = secondary_icon,
            halign = CENTER
        };
        overlay.add_overlay (primary_icon);

        var header_label = new Granite.HeaderLabel ("") {
            size = H3
        };

        var header = new Granite.Box (VERTICAL);
        header.append (overlay);
        header.append (header_label);

        button_box = new Granite.Box (HORIZONTAL, HALF) {
            homogeneous = true
        };

        var toolbarview = new Granite.ToolBox () {
            vexpand = true
        };
        toolbarview.add_bottom_bar (button_box);
        toolbarview.add_top_bar (header);

        child = toolbarview;
        default_width = 325;
        modal = true;

        // We need to hide the title area
        titlebar = new Gtk.Grid () {
            visible = false
        };

        add_css_class ("dialog");
        add_css_class ("granite-alert");

        bind_property ("primary-icon", primary_icon, "gicon");
        bind_property ("secondary-icon", secondary_icon, "gicon");
        bind_property ("content", toolbarview, "content");
        bind_property ("title", header_label, "label", SYNC_CREATE);
        bind_property ("secondary-text", header_label, "secondary-text", SYNC_CREATE);

        action_group = new SimpleActionGroup ();

        insert_action_group ("dialog", action_group);

        // close_request.connect (() => { response (DELETE_EVENT); });
    }

    public void add_button (string label, string response_id, ButtonStyle button_style = DEFAULT) {
        var response_action = new SimpleAction (response_id, null);
        response_action.activate.connect (() => {
            response (response_id);
        });

        action_group.add_action (response_action);

        var button = new Gtk.Button.with_label (label) {
            action_name = "dialog." + response_id,
            use_underline = true
        };

        if (button_style != DEFAULT) {
            button.add_css_class (button_style.to_string ());
        }

        button_box.append (button);
    }

    /**
     * Set whether a response is enabled. The corresponding button will have {@link Gtk.Widget.sensitive} set accordingly.
     *
     * Responses are enabled by default
     */
    public void set_response_enabled (string response_id, bool enabled) {
        var action = (SimpleAction) action_group.lookup_action (response_id);
        action.set_enabled (enabled);
    }
}
