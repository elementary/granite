/*
 * Copyright 2018–2019 elementary, Inc. (https://elementary.io)
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
 *         welcome.append ("text-x-vala", "Visit Valadoc", "The canonical source for Vala API references.");
 *         welcome.append ("text-x-source", "Get Granite Source", "Granite's source code is hosted on GitHub.");
 *
 *         add (welcome);
 *
 *         welcome.activated.connect ((index) => {
 *             switch (index) {
 *                 case 0:
 *                     try {
 *                         AppInfo.launch_default_for_uri ("https://valadoc.org/granite/Granite.html", null);
 *                     } catch (Error e) {
 *                         warning (e.message);
 *                     }
 *
 *                     break;
 *                 case 1:
 *                     try {
 *                         AppInfo.launch_default_for_uri ("https://github.com/elementary/granite", null);
 *                     } catch (Error e) {
 *                         warning (e.message);
 *                     }
 *
 *                     break;
 *             }
 *         });
 *     }
 * }
 * }}}
 *
 */
public class Granite.Widgets.Welcome : Gtk.EventBox {

    public signal void activated (int index);

    /**
     * List of buttons for action items
     */
    protected new GLib.List<Gtk.Button> children = new GLib.List<Gtk.Button> ();

    /**
     * Grid for action items
     */
    protected Gtk.Grid options;

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
        Object (title: title_text, subtitle: subtitle_text);
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);

        title_label = new Gtk.Label (null);
        title_label.justify = Gtk.Justification.CENTER;
        title_label.hexpand = true;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        subtitle_label = new Gtk.Label (null);
        subtitle_label.justify = Gtk.Justification.CENTER;
        subtitle_label.hexpand = true;
        subtitle_label.wrap = true;
        subtitle_label.wrap_mode = Pango.WrapMode.WORD;

        var subtitle_label_context = subtitle_label.get_style_context ();
        subtitle_label_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        subtitle_label_context.add_class (Granite.STYLE_CLASS_H2_LABEL);

        options = new Gtk.Grid ();
        options.orientation = Gtk.Orientation.VERTICAL;
        options.row_spacing = 12;
        options.halign = Gtk.Align.CENTER;
        options.margin_top = 24;

        var content = new Gtk.Grid ();
        content.expand = true;
        content.margin = 12;
        content.orientation = Gtk.Orientation.VERTICAL;
        content.valign = Gtk.Align.CENTER;
        content.add (title_label);
        content.add (subtitle_label);
        content.add (options);

        add (content);
    }

     /**
      * Sets action item of given index's visiblity
      *
      * @param index index of action item to be changed
      * @param val value deteriming whether the action item is visible
      */
    public void set_item_visible (uint index, bool val) {
        if (index < children.length () && children.nth_data (index) is Gtk.Widget) {
            children.nth_data (index).set_no_show_all (!val);
            children.nth_data (index).set_visible (val);
        }
    }

     /**
      * Removes action item of given index
      *
      * @param index index of action item to remove
      */
    public void remove_item (uint index) {
        if (index < children.length () && children.nth_data (index) is Gtk.Widget) {
            var item = children.nth_data (index);
            item.destroy ();
            children.remove (item);
        }
    }

     /**
      * Sets action item of given index sensitivity
      *
      * @param index index of action item to be changed
      * @param val value deteriming whether the action item is senstitive
      */
    public void set_item_sensitivity (uint index, bool val) {
        if (index < children.length () && children.nth_data (index) is Gtk.Widget)
            children.nth_data (index).set_sensitive (val);
    }

     /**
      * Appends new action item to welcome page with a {@link Gtk.Image.from_icon_name}
      *
      * @param icon_name named icon to be set as icon for action item
      * @param option_text text to be set as the title for action item. It should use Title Case.
      * @param description_text text to be set as description for action item. It should use sentence case.
      * @return index of new item
      */
    public int append (string icon_name, string option_text, string description_text) {
        var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        image.use_fallback = true;
        return append_with_image (image, option_text, description_text);
    }

     /**
      * Appends new action item to welcome page with a {link Gdk.Pixbuf} icon
      *
      * @param pixbuf pixbuf to be set as icon for action item
      * @param option_text text to be set as the header for action item
      * @param description_text text to be set as description for action item
      * @return index of new item
      */
    public int append_with_pixbuf (Gdk.Pixbuf? pixbuf, string option_text, string description_text) {
        var image = new Gtk.Image.from_pixbuf (pixbuf);
        return append_with_image (image, option_text, description_text);
    }

     /**
      * Appends new action item to welcome page with a {@link Gtk.Image} icon
      *
      * @param image image to be set as icon for action item
      * @param option_text text to be set as the header for action item
      * @param description_text text to be set as description for action item
      * @return index of new item
      */
    public int append_with_image (Gtk.Image? image, string option_text, string description_text) {
        // Option label
        var button = new WelcomeButton (image, option_text, description_text);
        children.append (button);
        options.add (button);

        button.clicked.connect (() => {
            int index = this.children.index (button);
            activated (index); // send signal
        });

        return this.children.index (button);
    }

    /**
     * Returns a welcome button by index
     *
     * @param index index of action item to be returned
     * @return welcome button at //index//, or //null// if //index// is invalid.
     * @since 0.3
     */
    public Granite.Widgets.WelcomeButton? get_button_from_index (int index) {
        if (index >= 0 && index < children.length ())
            return children.nth_data (index) as WelcomeButton;

        return null;
    }
}
