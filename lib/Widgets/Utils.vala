// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*
 * Copyright (c) 2012 Granite Developers
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public enum Granite.TextStyle {
    /**
     * TITE: Highest level header
     */
    TITLE,
    
    /**
     * H1: Second highest header
     */
    H1,
    
    /**
     * H2: Third highest header
     */
    H2,
    
    /**
     * H3: Fourth Highest Header
     */
    H3;

    /**
     * Gets style sheet of text style
     *
     * @return CSS of text style
     */
    public string get_stylesheet (out string style_class = null) {
        switch (this) {
            case TITLE:
                style_class = "title";
                return @".$style_class { font: raleway 36; }";
            case H1:
                style_class = "h1";
                return @".$style_class { font: open sans bold 24; }";
            case H2:
                style_class = "h2";
                return @".$style_class { font: open sans light 18; }";
            case H3:
                style_class = "h3";
                return @".$style_class { font: open sans bold 12; }";
            default:
                assert_not_reached ();
        }
    }
}

/**
 * This class helps to apply CSS to widgets.
 */
namespace Granite.Widgets.Utils {

    [CCode (cname="get_close_pixbuf")]
    public extern Gdk.Pixbuf get_close_pixbuf ();


    /**
     * Applies the stylesheet to the widget
     * 
     * @param widget widget to apply style to
     * @param stylesheet style to apply to screen
     * @param class_name class name to add style to
     * @param priority priorty of change
     */
    public Gtk.CssProvider? set_theming (Gtk.Widget widget, string stylesheet,
                              string? class_name, int priority) {
        var css_provider = get_css_provider (stylesheet);

        var context = widget.get_style_context ();

        if (css_provider != null)
            context.add_provider (css_provider, priority);

        if (class_name != null && class_name.strip () != "")
            context.add_class (class_name);

        return css_provider;
    }

    /**
     * Applies a stylesheet to the given screen. This will affects all the
     * widgets which are part of that screen.
     * 
     * @param screen Screen to apply style to
     * @param stylesheet style to apply to screen
     * @param priority priorty of change
     */
    public Gtk.CssProvider? set_theming_for_screen (Gdk.Screen screen, string stylesheet, int priority) {
        var css_provider = get_css_provider (stylesheet);

        if (css_provider != null)
            Gtk.StyleContext.add_provider_for_screen (screen, css_provider, priority);

        return css_provider;
    }

    /**
     * @return a new {@link Gtk.CssProvider}, or null in case the parsing of
     *         //stylesheet// failed.
     */
    public Gtk.CssProvider? get_css_provider (string stylesheet) {
        Gtk.CssProvider provider = new Gtk.CssProvider ();

        try {
            provider.load_from_data (stylesheet, -1);
        }
        catch (Error e) {
            warning ("Could not create CSS Provider: %s\nStylesheet:\n%s",
                     e.message, stylesheet);
            return null;
        }

        return provider;
    }


    /**
     * This method applies given text style to given label
     * 
     * @param text_style text style to apply
     * @param label label to apply style to
     */

    public void apply_text_style_to_label (TextStyle text_style, Gtk.Label label) {
        var style_provider = new Gtk.CssProvider ();
        var style_context = label.get_style_context ();

        string style_class, stylesheet;
        stylesheet = text_style.get_stylesheet (out style_class);
        style_context.add_class (style_class);

        try {
            style_provider.load_from_data (stylesheet, -1);
        } catch (Error err) {
            warning ("Couldn't apply style to label: %s", err.message);
            return;
        }

        style_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }
}
