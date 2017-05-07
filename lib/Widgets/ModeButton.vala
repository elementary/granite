/*
 *  Copyright (C) 2008-2013 Christian Hergert <chris@dronelabs.com>,
 *                          Giulio Collura <random.cpp@gmail.com>,
 *                          Victor Eduardo <victoreduardm@gmail.com>,
 *                          ammonkey <am.monkeyd@gmail.com>
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

namespace Granite.Widgets {

    /**
     * This widget is a multiple option modal switch
     *
     * {{../../doc/images/ModeButton.png}}
     */
    public class ModeButton : Gtk.Box {

        private class Item : Gtk.ToggleButton {
            public int index { get; construct; }
            public Item (int index) {
                Object (index: index);
                can_focus = false;
                add_events (Gdk.EventMask.SCROLL_MASK);
            }
        }

        public signal void mode_added (int index, Gtk.Widget widget);
        public signal void mode_removed (int index, Gtk.Widget widget);
        public signal void mode_changed (Gtk.Widget widget);

        /**
         * Index of currently selected item.
         */
        public int selected {
            get { return _selected; }
            set { set_active (value); }
        }

        /**
         * Read-only length of current ModeButton
         */
        public uint n_items {
            get { return item_map.size; }
        }

        private int _selected = -1;
        private Gee.HashMap<int, Item> item_map;

        /**
         * Makes new ModeButton
         */
        public ModeButton () {
            homogeneous = true;
            spacing = 0;
            can_focus = false;

            item_map = new Gee.HashMap<int, Item> ();

            var style = get_style_context ();
            style.add_class (Gtk.STYLE_CLASS_LINKED);
            style.add_class ("raised"); // needed for toolbars
        }

        /**
         * Appends Pixbuf to ModeButton
         *
         * @param pixbuf Gdk.Pixbuf to append to ModeButton
         */
        public int append_pixbuf (Gdk.Pixbuf pixbuf) {
            return append (new Gtk.Image.from_pixbuf (pixbuf));
        }

        /**
         * Appends text to ModeButton
         *
         * @param text text to append to ModeButton
         * @return index of new item
         */
        public int append_text (string text) {
            return append (new Gtk.Label(text));
        }

        /**
         * Appends icon to ModeButton
         *
         * @param icon_name name of icon to append
         * @param size desired size of icon
         * @return index of appended item
         */
        public int append_icon (string icon_name, Gtk.IconSize size) {
            return append (new Gtk.Image.from_icon_name (icon_name, size));
        }

        /**
         * Appends given widget to ModeButton
         *
         * @param w widget to add to ModeButton
         * @return index of new item
         */
        public int append (Gtk.Widget w) {
            int index;
            for (index = item_map.size; item_map.has_key (index); index++);
            assert (item_map[index] == null);

            var item = new Item (index);
            item.scroll_event.connect (on_scroll_event);
            item.add (w);

            item.toggled.connect (() => {
                if (item.active) {
                    selected = item.index;
                }
            });

            item_map[index] = item;

            add (item);
            item.show_all ();

            mode_added (index, w);

            return index;
        }

        /**
         * Clear selected items
         */
        private void clear_selected () {
            foreach (var item in item_map.values) {
                if (item != null && item.active)
                    item.set_active (false);
            }

            _selected = -1;
        }

        /**
         * Sets item of given index's activity
         *
         * @param new_active_index index of changed item
         */
        public void set_active (int new_active_index) {
            if (new_active_index <= -1) {
                clear_selected ();
                return;
            }

            return_if_fail (item_map.has_key (new_active_index));
            var new_item = item_map[new_active_index] as Item;

            if (new_item != null) {
                assert (new_item.index == new_active_index);
                new_item.set_active (true);

                if (_selected == new_active_index)
                    return;

                // Unselect the previous item
                var old_item = item_map[_selected] as Item;
                if (old_item != null)
                    old_item.set_active (false);

                _selected = new_active_index;

                mode_changed (new_item.get_child ());
            }
        }

        /**
         * Changes visibility of item of given index
         *
         * @param index index of item to be modified
         * @param val value to change the visiblity to
         */
        public void set_item_visible (int index, bool val) {
            return_if_fail (item_map.has_key (index));
            var item = item_map[index] as Item;

            if (item != null) {
                assert (item.index == index);
                item.no_show_all = !val;
                item.visible = val;
            }
        }

        /**
         * Removes item at given index
         *
         * @param index index of item to remove
         */
        public new void remove (int index) {
            return_if_fail (item_map.has_key (index));
            var item = item_map[index] as Item;

            if (item != null) {
                assert (item.index == index);
                item_map.unset (index);
                mode_removed (index, item.get_child ());
                item.destroy ();
            }
        }

        /**
         * Clears all children
         */
        public void clear_children () {
            foreach (weak Gtk.Widget button in get_children ()) {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }

            item_map.clear ();

            _selected = -1;
        }

        private bool on_scroll_event (Gtk.Widget widget, Gdk.EventScroll ev) {
            int offset;

            switch (ev.direction) {
                case Gdk.ScrollDirection.DOWN:
                case Gdk.ScrollDirection.RIGHT:
                    offset = 1;
                    break;
                case Gdk.ScrollDirection.UP:
                case Gdk.ScrollDirection.LEFT:
                    offset = -1;
                    break;
                default:
                    return false;
            }

            // Try to find a valid item, since there could be invisible items in
            // the middle and those shouldn't be selected. We use the children list
            // instead of item_map because order matters here.
            var children = get_children ();
            uint n_children = children.length ();

            var selected_item = item_map[selected];
            if (selected_item == null)
                return false;

            int new_item = children.index (selected_item);
            if (new_item < 0)
                return false;

            do {
                new_item += offset;
                var item = children.nth_data (new_item) as Item;

                if (item != null && item.visible && item.sensitive) {
                    selected = item.index;
                    break;
                }
            } while (new_item >= 0 && new_item < n_children);

            return false;
        }
    }
}
