/*
 *  Copyright (C) 2011-2015 Granite Developers (https://launchpad.net/granite)
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
 *
 *  Authored by: Corentin Noël <corentin@elementary.io>
 */
public class Granite.Widgets.StorageBar : Gtk.Box {
    public enum ItemDescription {
        OTHER,
        AUDIO,
        VIDEO,
        PHOTO,
        APP
    }

    private uint64 _storage = 0;
    public uint64 storage {
        get {
            return _storage;
        }
        set {
            _storage = value;
            update_size_description ();
        }
    }

    private Gtk.Label description_label;
    private GLib.HashTable<int, FillBlock> blocks;
    private int index = 0;
    private Gtk.Box fillblock_box;
    private Gtk.Box legend_box;

    public StorageBar (uint64 storage) {
        Object (storage: storage);
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        description_label = new Gtk.Label (null);
        description_label.hexpand = true;
        get_style_context ().add_class ("storage-bar");
        blocks = new GLib.HashTable<int, FillBlock> (null, null);
        fillblock_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        fillblock_box.hexpand = true;
        legend_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        legend_box.expand = true;
        fillblock_box.get_style_context ().add_class ("trough");
        var legend_scrolled = new Gtk.ScrolledWindow (null, null);
        legend_scrolled.vscrollbar_policy = Gtk.PolicyType.NEVER;
        legend_scrolled.hexpand = true;
        legend_scrolled.add (legend_box);
        var grid = new Gtk.Grid ();
        grid.attach (legend_scrolled, 0, 0, 1, 1);
        grid.attach (fillblock_box, 0, 1, 1, 1);
        grid.attach (description_label, 0, 2, 1, 1);
        set_center_widget (grid);
    }

    private void update_size_description () {
        uint64 user_size = 0;
        foreach (weak FillBlock block in blocks.get_values ()) {
            user_size += block.size;
        }

        uint64 free = storage - user_size;
        description_label.label = _("%s free out of %s").printf (GLib.format_size (free), GLib.format_size (storage));
    }

    public int create_block (uint64 size, string name, ItemDescription description = ItemDescription.OTHER) {
        var fill_block = new FillBlock (size, name, description);
        fillblock_box.add (fill_block);
        legend_box.add (fill_block.legend_item);

        blocks.set (index, fill_block);
        update_size_description ();
        index++;
        return index - 1;
    }

    public void update_block_size (int id, uint64 size) {
        var block = (FillBlock)blocks.get (id);
        if (block == null) {
            critical ("children with id %d doesn't exist.", id);
            return;
        }

        block.size = size;
        update_size_description ();
    }

    public void update_block_visibility (int id, bool visibility) {
        var block = (FillBlock)blocks.get (id);
        if (block == null) {
            critical ("children with id %d doesn't exist.", id);
            return;
        }

        block.no_show_all = visibility;
        block.visible = visibility;
    }

    public class FillBlock : Gtk.Label {
        private uint64 _size = 0;
        public uint64 size {
            get {
                return _size;
            }
            set {
                _size = value;
                size_label.label = GLib.format_size (_size);
                queue_resize ();
            }
        }

        public Gtk.Grid legend_item { public get; private set; }
        private Gtk.Label name_label;
        private Gtk.Label size_label;
        private Gtk.Label legend_fill;

        public FillBlock (uint64 size, string name, ItemDescription description = ItemDescription.OTHER) {
            Object (size: size);
            name_label.label = name;
            switch (description) {
                case ItemDescription.AUDIO:
                    get_style_context ().add_class ("audio");
                    legend_fill.get_style_context ().add_class ("audio");
                    break;
                case ItemDescription.VIDEO:
                    get_style_context ().add_class ("video");
                    legend_fill.get_style_context ().add_class ("video");
                    break;
                case ItemDescription.PHOTO:
                    get_style_context ().add_class ("photo");
                    legend_fill.get_style_context ().add_class ("photo");
                    break;
                case ItemDescription.APP:
                    get_style_context ().add_class ("app");
                    legend_fill.get_style_context ().add_class ("app");
                    break;
                default:
                    break;
            }
        }

        construct {
            get_style_context ().add_class ("fill-block");
            legend_item = new Gtk.Grid ();
            name_label = new Gtk.Label (null);
            size_label = new Gtk.Label (null);
            legend_fill = new Gtk.Label (null);
            legend_fill.get_style_context ().add_class ("fill-block");
            legend_item.attach (legend_fill, 0, 0, 1, 2);
            legend_item.attach (name_label, 1, 0, 1, 1);
            legend_item.attach (size_label, 1, 1, 1, 1);
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            base.get_preferred_width (out minimum_width, out natural_width);
            var storage_bar = parent as Granite.Widgets.StorageBar;
            if (storage_bar == null || storage_bar.storage == 0) {
                return;
            }
            Gtk.Allocation allocation;
            parent.get_allocation (out allocation);
            warning (storage_bar.storage.to_string ());
            warning ("%f", (double)storage_bar.storage);
            double ratio = ((double)size)/((double)storage_bar.storage);
            minimum_width = (int)GLib.Math.trunc (((double)minimum_width)*ratio);
            natural_width = (int)GLib.Math.trunc (((double)allocation.width)*ratio);
        }
    }
}
