/*
 *  Copyright (C) 2011-2013 Mathijs Henquet
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

using Gtk;

using Granite.Services;

namespace Granite.Widgets {

	/**
	 * An App Menu is the gear menu that goes on the right of the toolbar.
	 */
    public class AppMenu : Gtk.MenuButton {

        /**
         * Menu item for about page.
         */
        public Gtk.MenuItem about_item;

        /**
         * Called when showing about.
         */
        public signal void show_about(Gtk.Widget w);

        /**
         * Makes new AppMenu.
         *
         * @param menu menu to be turned into an AppMenu.
         */
        public AppMenu (Gtk.Menu menu) {
            image = new Gtk.Image.from_icon_name ("open-menu", IconSize.MENU);
            tooltip_text = _("Menu");
        }

        /**
         * Makes new AppMenu with built-in about page.
         *
         * @param application application of AppMenu.
         * @param menu menu to be created.
         */
        public AppMenu.with_app (Granite.Application? application, Gtk.Menu menu) {
            image = new Gtk.Image.from_icon_name ("open-menu", IconSize.MENU);
            tooltip_text = _("Menu");

            this.add_items (menu);

            about_item.activate.connect (() => { show_about(get_toplevel()); });
        }

        /**
         * Create a new AppMenu, parameters are unused now.
         */
        [Version (deprecated = true, deprecated_since = "0.1", replacement = "")]
        public AppMenu.with_urls (Gtk.Menu menu, string help_url, string translate_url, string bug_url) {
            critical("This is a deprecated creation method: AppMenu.with_urls");
            image = new Gtk.Image.from_icon_name ("open-menu", IconSize.MENU);
            tooltip_text = _("Menu");
        }

        /**
         * This method adds makes a properly formatted App Menu menu from given menu
         *
         * @param menu menu to format
         */
        public void add_items (Gtk.Menu menu) {

            about_item = new Gtk.MenuItem.with_label (_("About"));

            if (menu.get_children ().length () > 0)
                menu.append (new SeparatorMenuItem ());
            menu.append (about_item);
        }

    }

}

