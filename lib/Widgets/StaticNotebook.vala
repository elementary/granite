/*
 *  Copyright (C) 2011-2013 Lucas Baudin <xapantu@gmail.com>
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
     * This class provides an easy way to manage tabs.
     */
    [Deprecated (replacement = "Gtk.Stack", since = "0.3")]
    public class StaticNotebook : Gtk.Box {

        private Gtk.Notebook notebook;
        private ModeButton switcher;
        private Gtk.Box switcher_box;

        /**
         * The page switcher will NEVER be shown if this property is set to true
         */
        private bool switcher_hidden;

        /**
         * This currently selected page
         */
        public int page {
            set { switcher.selected = value; notebook.page = value; }
            get { return notebook.page; }
        }

        public signal void page_changed (int index);

        /**
         * This creates a new StaticNotebook
         * 
         * @param show_separator whether or not to show a seperator
         */
        public StaticNotebook (bool show_separator = true) {

            orientation = Gtk.Orientation.VERTICAL;
            switcher_hidden = false;

            notebook = new Gtk.Notebook();
            notebook.show_tabs = false;

            switcher = new ModeButton();

            switcher_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            
            if (show_separator) {
                var left_separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
                var right_separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
                switcher_box.pack_start(left_separator, true, true);
                switcher_box.pack_start(switcher, false, false);
                switcher_box.pack_end(right_separator, true, true);
            } else {
                switcher.halign = Gtk.Align.CENTER;
                switcher_box.pack_start(switcher, true, true);
            }

            switcher.set_margin_top(5);
            switcher.set_margin_bottom(5);

            pack_start(switcher_box, false, false);
            pack_start(notebook);

            switcher.mode_changed.connect(on_mode_changed);
        }

        public void set_switcher_visible (bool val) {
            switcher_box.set_no_show_all(!val);
            switcher_hidden = !val;
            update_switcher_visibility();
        }

        public int append_page (Gtk.Widget widget, Gtk.Label label) {
            int index = notebook.append_page(widget, null);
            label.set_margin_right(5);
            label.set_margin_left(5);
            switcher.append(label);

            if(switcher.selected == -1)
                switcher.selected = 0;

            update_switcher_visibility();

            return index;
        }

        void on_mode_changed (Gtk.Widget widget) {
            notebook.page = switcher.selected;
            page_changed(notebook.page);
        }

        public void remove_page (int number) {
            notebook.remove_page(number);
            switcher.remove(number);
            update_switcher_visibility();
        }

        void update_switcher_visibility () {
            if (switcher_hidden) {
                switcher_box.hide();
                return;
            }

            // Don't show tabs if there's only one page
            bool switcher_visible = notebook.get_n_pages() > 1;
            switcher_box.set_no_show_all (!switcher_visible);

            if (switcher_visible)
                switcher_box.show_all();
            else
                switcher_box.hide();
        }
    }
}

