//
//  Copyright (C) 2008 Christian Hergert <chris@dronelabs.com>
//  Copyright (C) 2011 Giulio Collura
//  Copyright (C) 2012 Victor Eduardo <victor@elementaryos.org>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Granite.Widgets {

    /**
     * This widget is a multiple option modal switch
     */
    public class ModeButton : Gtk.Box {

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
            get { return get_children ().length (); }
        }

        private int _selected = -1;

        /**
         * Makes new ModeButton
         *
         */
        public ModeButton () {
            homogeneous = true;
            spacing = 0;
            can_focus = false;

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
            var button = new Gtk.ToggleButton ();
            button.can_focus = false;
            button.add_events (Gdk.EventMask.SCROLL_MASK);
            button.scroll_event.connect (on_scroll_event);

            button.add (w);

            button.button_press_event.connect ( () => {
                set_active (get_children ().index (button));
                return true;
            });

            add (button);
            button.show_all ();

            var children = get_children ();
            int item_index = (int)children.length () - 1;
            mode_added (item_index, w);
            return item_index;
        }

        /**
         * Sets item of given index's activity 
         *
         * @param new_active_index index of changed item
         */
        public void set_active (int new_active_index) {
            var children = get_children ();
            return_if_fail (new_active_index >= 0 && new_active_index < children.length ());

            var new_item = children.nth_data (new_active_index) as Gtk.ToggleButton;

            if (new_item != null) {
                new_item.set_active (true);

                if (_selected == new_active_index)
                    return;

                // Unselect the previous item
                var old_item = children.nth_data (_selected) as Gtk.ToggleButton;
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
            var children = get_children ();
            return_if_fail (index >= 0 && index < children.length ());

            var item = children.nth_data (index);

            if (item != null) {
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
            var children = get_children ();
            return_if_fail (index >= 0 && index < children.length ());

            var item = children.nth_data (index) as Gtk.Bin;
            if (item != null) {
                mode_removed (index, item.get_child ());
                item.destroy ();
            }
        }

        /**
         * Clears all children
         *
         */
        public void clear_children () {
            foreach (weak Gtk.Widget button in get_children ()) {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }

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

            int new_item = selected;

            // Try to find a valid item, since there could be invisible items in the middle
            // and those shouldn't be selected
            var children = get_children ();
            uint n_children = children.length ();

            do {
                new_item += offset;
                var item = children.nth_data (new_item);
                if (item != null && item.visible) {
                    selected = new_item;
                    break;
                }
            } while (new_item >= 0 && new_item < n_children);

            return false;
        }
    }
}
