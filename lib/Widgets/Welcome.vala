/*
 * Copyright 2018–2021 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Maxwell Barvian <maxwell@elementaryos.org>
 * Copyright 2011–2013 Victor Eduardo <victoreduardm@gmal.com>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * This class is for making a first-launch screen easily
 *
 * It can be used to create a list of one-time action items that need to be executed in order to setup the app.
 *
 * Granite.Widgets.Welcome will get the style class `welcome`.
 *
 * {{../doc/images/Welcome.png}}
 *
 * ''Example''<<BR>>
 * {{{
 * public class WelcomeView : Gtk.Grid {
 *     construct {
 *         var welcome = new Granite.Widgets.Welcome ("Granite Demo", "This is a demo of the Granite library.");
 *         var valadoc_button = welcome.add_button ("text-x-vala", "Visit Valadoc",
 *              "The canonical source for Vala API references.");
 *         var github_button =welcome.add_button ("text-x-source", "Get Granite Source",
 *              "Granite's source code is hosted on GitHub.");
 *
 *         set_child (welcome);
 *
 *         valadoc_button.activate.connect (() => {
 *             try {
 *                  AppInfo.launch_default_for_uri ("https://valadoc.org/granite/Granite.html", null);
 *             } catch (Error e) {
 *                  warning (e.message);
 *             }
 *         });
 *
 *         github_button.activate.connect (() => {
 *             try {
 *                  AppInfo.launch_default_for_uri ("https://github.com/elementary/granite", null);
 *             } catch (Error e) {
 *                  warning (e.message);
 *             }
 *         });
 *
 *     }
 * }
 * }}}
 *
 */
public class Granite.Widgets.Welcome : Gtk.Box {

    public signal void activated (); // removed the index
    protected Gtk.Box options;

    /**
     * This is the title of the welcome widget. It should use Title Case.
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
     * This is the subtitle of the welcome widget. It should use sentence case.
     */
    public string subtitle {
        get {
            return subtitle_label.label;
        }
        set {
            subtitle_label.label = value;
        }
    }

    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;

    /**
     * Makes new Welcome Page
     *
     * @param title_text main title for new Welcome Page
     * @param subtitle_text subtitle text for new Welcome Page
     */
    public Welcome (string title_text, string subtitle_text) {
        Object (
            title: title_text,
            subtitle: subtitle_text
        );
    }

    construct {
        css_classes = { "welcome" };

        title_label = new Gtk.Label (null) {
            justify = Gtk.Justification.CENTER,
            hexpand = true,
            css_classes = { "h1" }
        };

        subtitle_label = new Gtk.Label (null) {
            justify = Gtk.Justification.CENTER,
            hexpand = true,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            css_classes = { "h2" }
        };

        options = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            halign = Gtk.Align.CENTER,
            margin_top = 24
        };

        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            hexpand = true,
            vexpand = true,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
            valign = Gtk.Align.CENTER
        };

        content.append (title_label);
        content.append (subtitle_label);
        content.append (options);

        append (content);
    }

     /**
      * Sets button visiblity
      *
      * @param WelcomeButton to be changed
      * @param val value deteriming whether the button is visible
      */
    public void set_button_visible (Granite.Widgets.WelcomeButton button, bool val) {
        button.set_visible (val);
    }

     /**
      * Removes a WelcomeButton
      *
      * @param WelcomeButton to remove
      */
    public void remove_button (Granite.Widgets.WelcomeButton button) {
            button.destroy ();
    }

     /**
      * Sets WelcomeButton's sensitivity
      *
      * @param WelcomeButton to be changed
      * @param val value deteriming whether the WelcomeButton is senstitive
      */
    public void set_button_sensitivity (Granite.Widgets.WelcomeButton button, bool val) {
        button.set_sensitive (val);
    }

     /**
      * Appends new WelcomeButton to welcome page with a {@link Gtk.Image.from_icon_name}
      *
      * @param icon_name named icon to be set as icon for WelcomeButton
      * @param option_text text to be set as the title for WelcomeButton. It should use Title Case.
      * @param description_text text to be set as description for WelcomeButton. It should use sentence case.
      * @return WelcomeButton
      */
    public new Granite.Widgets.WelcomeButton add_button (string icon_name, string option_text, string description_text) {
        var image = new Gtk.Image.from_icon_name (icon_name);
        image.use_fallback = true;
        return add_button_from_image (image, option_text, description_text);
    }

     /**
      * Appends new WelcomeButton to welcome page with a {link Gdk.Pixbuf} icon
      *
      * @param pixbuf pixbuf to be set as icon for WelcomeButton
      * @param option_text text to be set as the header for WelcomeButton
      * @param description_text text to be set as description for WelcomeButton
      * @return WelcomeButton
      */
    public Granite.Widgets.WelcomeButton add_button_with_pixbuf (Gdk.Pixbuf? pixbuf,
        string option_text, string description_text) {
        var image = new Gtk.Image.from_pixbuf (pixbuf);
        return add_button_from_image (image, option_text, description_text);
    }

     /**
      * Appends new WelcomeButton to welcome page with a {@link Gtk.Image} icon
      *
      * @param image to be set as icon for WelcomeButton
      * @param option_text text to be set as the header for WelcomeButton
      * @param description_text text to be set as description for WelcomeButton
      * @return WelcomeButton
      */
    public Granite.Widgets.WelcomeButton add_button_from_image (Gtk.Image? image,
        string option_text, string description_text) {
        // Option label
        var button = new WelcomeButton (image, option_text, description_text);
        options.append (button);

        button.clicked.connect (() => {
            activated (); // send signal
        });

        return button;
    }
}
