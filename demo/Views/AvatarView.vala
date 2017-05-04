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
        var username = GLib.Environment.get_user_name ();
        var iconfile = @"/var/lib/AccountsService/icons/$username";

        var avatar_menu = new Granite.Widgets.Avatar.from_file (iconfile, 16);

        var avatar_large_toolbar = new Granite.Widgets.Avatar.from_file (iconfile, 24);

        var avatar_dnd = new Granite.Widgets.Avatar.from_file (iconfile, 32);

        var avatar_dialog = new Granite.Widgets.Avatar.from_file (iconfile, 48);

        var avatar_default_menu = new Granite.Widgets.Avatar.with_default_icon (16);

        var avatar_default_large_toolbar = new Granite.Widgets.Avatar.with_default_icon (24);

        var avatar_default_dnd = new Granite.Widgets.Avatar.with_default_icon (32);

        var avatar_default_dialog = new Granite.Widgets.Avatar.with_default_icon (48);

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
