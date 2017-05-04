// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class AvatarView : Gtk.Grid {
    construct {
        var avatar_menu = new Granite.Widgets.Avatar ();

        var avatar_large_toolbar = new Granite.Widgets.Avatar ();

        var avatar_dnd = new Granite.Widgets.Avatar ();

        var avatar_dialog = new Granite.Widgets.Avatar ();

        var avatar_default_menu = new Granite.Widgets.Avatar ();
        avatar_default_menu.show_default (16);

        var avatar_default_large_toolbar = new Granite.Widgets.Avatar ();
        avatar_default_large_toolbar.show_default (24);

        var avatar_default_dnd = new Granite.Widgets.Avatar ();
        avatar_default_dnd.show_default (32);

        var avatar_default_dialog = new Granite.Widgets.Avatar ();
        avatar_default_dialog.show_default (48);

        var scale = get_style_context ().get_scale ();
        var username = GLib.Environment.get_user_name ();
        var iconfile = @"/var/lib/AccountsService/icons/$username";

        try {
            var pixbuf = new Gdk.Pixbuf.from_file (iconfile);
            avatar_menu.pixbuf = pixbuf.scale_simple (16 * scale, 16 * scale, Gdk.InterpType.BILINEAR);
            avatar_large_toolbar.pixbuf = pixbuf.scale_simple (24 * scale, 24 * scale, Gdk.InterpType.BILINEAR);
            avatar_dnd.pixbuf = pixbuf.scale_simple (32 * scale, 32 * scale, Gdk.InterpType.BILINEAR);
            avatar_dialog.pixbuf = pixbuf.scale_simple (48 * scale, 48 * scale, Gdk.InterpType.BILINEAR);
        } catch (Error e) {
            warning(e.message);
        }

        column_spacing = 12;
        row_spacing = 6;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        attach (avatar_menu, 0, 0, 1, 1);
        attach (avatar_default_menu, 0, 1, 1, 1);
        attach (new Gtk.Label ("16px"), 0, 2, 1, 1);
        attach (avatar_large_toolbar, 1, 0, 1, 1);
        attach (avatar_default_large_toolbar, 1, 1, 1, 1);
        attach (new Gtk.Label ("24px"), 1, 2, 1, 1);
        attach (avatar_dnd, 2, 0, 1, 1);
        attach (avatar_default_dnd, 2, 1, 1, 1);
        attach (new Gtk.Label ("32px"), 2, 2, 1, 1);
        attach (avatar_dialog, 3, 0, 1, 1);
        attach (avatar_default_dialog, 3, 1, 1, 1);
        attach (new Gtk.Label ("48px"), 3, 2, 1, 1);
    }
}
