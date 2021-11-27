/*
 * Copyright 2019-2021 elementary, Inc. (https://elementary.io)
 * Copyright 2008–2013 Christian Hergert <chris@dronelabs.com>,
 * Copyright 2008–2013 Giulio Collura <random.cpp@gmail.com>,
 * Copyright 2008–2013 Victor Eduardo <victoreduardm@gmail.com>,
 * Copyright 2008–2013 ammonkey <am.monkeyd@gmail.com>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite.Widgets {

    /**
     * This widget is a multiple option modal switch
     *
     * {{../doc/images/ModeButton.png}}
     */
    public class ModeButton : Gtk.Box {

        private class Item : Gtk.ToggleButton {
            public int index { get; construct; }
            public Item (int index) {
                Object (index: index);
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

        }

        construct {
            homogeneous = true;
            spacing = 0;

            item_map = new Gee.HashMap<int, Item> ();

            var style = get_style_context ();
            style.add_class (Granite.STYLE_CLASS_LINKED);
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
            return append (new Gtk.Label (text));
        }

        /**
         * Appends icon to ModeButton
         *
         * @param icon_name name of icon to append
         * @return index of appended item
         */
        public int append_icon (string icon_name) {
            return append (new Gtk.Image.from_icon_name (icon_name));
        }

        /**
         * Appends given widget to ModeButton
         *
         * @param w widget to add to ModeButton
         * @return index of new item
         */
        public new int append (Gtk.Widget w) {
            int index;
            for (index = item_map.size; item_map.has_key (index); index++);
            assert (item_map[index] == null);

            var item = new Item (index);
            var scroll_controller = new Gtk.EventControllerScroll (
                Gtk.EventControllerScrollFlags.VERTICAL |
                Gtk.EventControllerScrollFlags.DISCRETE
            );

            scroll_controller.scroll.connect (on_scroll_event);
            item.add_controller (scroll_controller);
            item.child = w;

            item.toggled.connect (() => {
                if (item.active) {
                    selected = item.index;
                } else if (selected == item.index) {
                    // If the selected index still references this item, then it
                    // was toggled by the user, not programmatically.
                    // -> Reactivate the item to prevent an empty selection.
                    item.active = true;
                }
            });

            item_map[index] = item;

            base.append (item);

            mode_added (index, w);

            return index;
        }

        /**
         * Clear selected items
         */
        private void clear_selected () {
            // Update _selected before deactivating the selected item to let it
            // know that it is being deactivated programmatically, not by the
            // user.
            _selected = -1;

            foreach (var item in item_map.values) {
                if (item != null && item.active) {
                    item.set_active (false);
                }
            }
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

                if (_selected == new_active_index) {
                    return;
                }

                // Unselect the previous item
                var old_item = item_map[_selected] as Item;

                // Update _selected before deactivating the selected item to let
                // it know that it is being deactivated programmatically, not by
                // the user.
                _selected = new_active_index;

                if (old_item != null) {
                    old_item.set_active (false);
                }

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
            weak Gtk.Widget button = get_first_child ();
            while (button != null) {
                weak Gtk.Widget next_button = button.get_next_sibling ();

                button.hide ();
                if (button.get_parent () != null) {
                    base.remove (button);
                }

                button = next_button;
            }

            item_map.clear ();

            _selected = -1;
        }

        private bool on_scroll_event (double dx, double dy) {
            int offset;

            if (dy > 0) {
                offset = 1;
            } else {
                offset = -1;
            }

            var selected_item = item_map[selected];
            if (selected_item == null) {
                return false;
            }

            if (get_first_child () == null) {
                return false;
            }

            // Try to find a valid item, since there could be invisible items in
            // the middle and those shouldn't be selected. We use the children list
            // instead of item_map because order matters here.
            weak Gtk.Widget child = selected_item;
            while (child != null) {
                if (offset > 0) {
                    child = child.get_next_sibling ();
                } else {
                    child = child.get_prev_sibling ();
                }

                var item = child as Item;
                if (item != null && item.visible && item.sensitive) {
                    selected = item.index;
                    return true;
                }
            }

            return false;
        }
    }
}
