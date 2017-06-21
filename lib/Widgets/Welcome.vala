/*
 *  Copyright (C) 2011-2013 Maxwell Barvian <maxwell@elementaryos.org>,
 *                          Victor Eduardo <victoreduardm@gmal.com>
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

using Gtk;

/**
 * This class is for making a first-launch screen easily
 *
 * It can be used to create a list of one-time action items that need to be executed in order to setup the app.
 *
 * {{../../doc/images/Welcome.png}}
 */
public class Granite.Widgets.Welcome : Gtk.EventBox {

    // Signals
    public signal void activated (int index);

    /**
     * List of buttons for action items
     */
    protected new GLib.List<Gtk.Button> children = new GLib.List<Gtk.Button> ();
    /**
     * Box for action items
     */
    protected Gtk.Box options;

    /**
     * This is the title of the welcome widget.
     */
    public string title {
        get {
            return title_label.get_label ();
        }
        set {
            title_label.set_label (value);
        }
    }

    /**
     * This is the subtitle of the welcome widget.
     */
    public string subtitle {
        get {
            return subtitle_label.get_label ();
        }
        set {
            subtitle_label.set_label (value);
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

        // Options wrapper
        this.options = new Gtk.Box (Gtk.Orientation.VERTICAL, 9);
        options.halign = Gtk.Align.CENTER;
        options.margin = 12;

        var content = new Gtk.Grid ();
        content.expand = true;
        content.margin_top = 12;
        content.valign = Gtk.Align.CENTER;
        content.orientation = Gtk.Orientation.VERTICAL;
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
            children.nth_data(index).set_no_show_all (!val);
            children.nth_data(index).set_visible (val);
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
      * Appends new action item to welcome page with icon
      *
      * @param icon_name icon to be set as icon for action item
      * @param option_text text to be set as the header for action item
      * @param description_text text to be set as description for action item
      * @return index of new item
      */
    public int append (string icon_name, string option_text, string description_text) {
        var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        image.use_fallback = true;
        return append_with_image (image, option_text, description_text);
    }

     /**
      * Appends new action item to welcome page with Gtk.Pixbuf icon
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
      * Appends new action item to welcome page with Gtk.Image icon
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
        options.pack_start (button, false, false, 0);

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
