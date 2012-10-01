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

public class Granite.Widgets.CellRendererExpander : Gtk.CellRenderer {
    public signal void toggled (string path);

    public bool arrow_visible { get; set; default = true; }
    private int arrow_size = 8;

    public CellRendererExpander () {
        mode = Gtk.CellRendererMode.ACTIVATABLE;
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void get_preferred_width (Gtk.Widget widget,
                                              out int minimum_size,
                                              out int natural_size)
    {
        if (widget is Gtk.TreeView)
            widget.style_get ("expander-size", out arrow_size);

        minimum_size = natural_size = arrow_size;
    }

    public override void get_preferred_height_for_width (Gtk.Widget widget, int width,
                                                         out int minimum_height,
                                                         out int natural_height)
    {
        minimum_height = natural_height = arrow_size;
    }

    public override void render (Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle bg_area,
                                 Gdk.Rectangle cell_area, Gtk.CellRendererState flags)
    {
        if (!arrow_visible || !is_expander)
            return;

        bool is_expandable = (flags & Gtk.CellRendererState.EXPANDABLE) != 0;

        if (is_expandable) {
            var ctx = widget.get_style_context ();
            ctx.save ();

            const Gtk.StateFlags EXPANDED_FLAG = Gtk.StateFlags.ACTIVE;
            var state = ctx.get_state ();
            ctx.set_state (is_expanded ? state | EXPANDED_FLAG : state & ~EXPANDED_FLAG);

            int offset = arrow_size / 2;
            int x = cell_area.x + cell_area.width / 2 - offset;
            int y = cell_area.y + cell_area.height / 2 - offset;
            ctx.render_expander (context, x, y, arrow_size, arrow_size);

            // Restore original state
            ctx.restore ();
        }
    }

    public override bool activate (Gdk.Event event, Gtk.Widget widget, string path,
                                   Gdk.Rectangle background_area, Gdk.Rectangle cell_area,
                                   Gtk.CellRendererState flags)
    {
        toggled (path);
        return true;
    }

    // XXX @deprecated. Not used
    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                   out int x_offset, out int y_offset,
                                   out int width, out int height)
    {
        x_offset = y_offset = width = height = 0;
    }
}
