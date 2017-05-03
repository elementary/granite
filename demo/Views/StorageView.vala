// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2011-2017 elementary LLC. (https://elementary.io)
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
 *
 * Authored by: Lucas Baudin <xapantu@gmail.com>
 *              Jaap Broekhuizen <jaapz.b@gmail.com>
 *              Victor Eduardo <victoreduardm@gmal.com>
 *              Tom Beckmann <tom@elementary.io>
 *              Corentin Noël <corentin@elementary.io>
 */

public class StorageView : Gtk.Grid {
    construct {
        var file_root = GLib.File.new_for_path ("/");

        try {
            var info = file_root.query_filesystem_info (GLib.FileAttribute.FILESYSTEM_SIZE, null);

            var size = info.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_SIZE);

            var storage = new Granite.Widgets.StorageBar.with_total_usage (size, size/2);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.AUDIO, size/40);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.VIDEO, size/30);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.APP, size/20);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.PHOTO, size/10);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.FILES, size/5);

            add (storage);
        } catch (Error e) {
            critical (e.message);
        }
    }
}
