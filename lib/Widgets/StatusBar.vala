/*
 * Copyright (c) 2012 Granite Developers
 *
 * This is a free software; you can redistribute it and/or
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
 *
 * Authored by: Victor Eduardo <victoreduardm@gmail.com>
 */

public class Granite.Widgets.StatusBar : Gtk.Toolbar {

    protected Gtk.Label status_label;
    protected Gtk.Box left_box;
    protected Gtk.Box right_box;

    protected const int ITEM_SPACING = 3;

    internal Gtk.CssProvider style_provider;
    internal Gtk.StyleContext context;

    /* This prevents the huge vertical padding */
    private const string STATUSBAR_STYLESHEET = """
        GraniteWidgetsStatusBar {
            border-bottom-width: 0;
            border-right-width: 0;
            border-left-width: 0;
            -GtkWidget-window-dragging: false;
        }

        GraniteWidgetsStatusBar .button {
            padding: 0px;
        }
    """;

    public StatusBar () {

        style_provider = new Gtk.CssProvider ();

        try {
            style_provider.load_from_data (STATUSBAR_STYLESHEET, -1);
        }
        catch (Error err) {
            warning (err.message);
        }

        /* Get rid of the "toolbar" class to avoid inheriting its style,
           since we want the widget to look more like a normal statusbar. */
        get_style_context ().remove_class (Gtk.STYLE_CLASS_TOOLBAR);

        context = new Gtk.StyleContext ();
        context.add_provider_for_screen (get_screen (), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);

        status_label = new Gtk.Label ("");
        status_label.set_justify (Gtk.Justification.CENTER);

        left_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        right_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        var left_item = new Gtk.ToolItem ();
        var status_label_item = new Gtk.ToolItem ();
        var right_item = new Gtk.ToolItem ();

        left_item.add (left_box);
        status_label_item.add (status_label);
        right_item.add (right_box);

        status_label_item.set_expand (true);

        status_label_item.halign = Gtk.Align.CENTER;
        left_item.valign = right_item.valign = status_label_item.valign = Gtk.Align.CENTER;

        this.insert (left_item, 0);
        this.insert (status_label_item, 1);
        this.insert (right_item, 2);
    }

    public void insert_widget (Gtk.Widget widget, bool? use_left_side = false) {
        if (use_left_side)
            left_box.pack_start (widget, false, false, ITEM_SPACING);
        else
            right_box.pack_start (widget, false, false, ITEM_SPACING);
    }
}

