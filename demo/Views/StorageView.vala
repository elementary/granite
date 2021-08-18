/*
 * Copyright 2011–2019 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class StorageView : Gtk.Grid {
    construct {
        var file_root = GLib.File.new_for_path ("/");

        try {
            var info = file_root.query_filesystem_info (GLib.FileAttribute.FILESYSTEM_SIZE, null);

            var size = info.get_attribute_uint64 (GLib.FileAttribute.FILESYSTEM_SIZE);

            var storage = new Granite.Widgets.StorageBar.with_total_usage (size, size / 2);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.AUDIO, size / 40);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.VIDEO, size / 30);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.APP, size / 20);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.PHOTO, size / 10);
            storage.update_block_size (Granite.Widgets.StorageBar.ItemDescription.FILES, size / 5);

            add (storage);
        } catch (Error e) {
            critical (e.message);
        }
    }
}
