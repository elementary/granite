/*
 *  Copyright 2019 elementary, Inc. (https://elementary.io)
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

public class AccelLabelView : Gtk.Grid {
    construct {
        var accellabel_label = new Gtk.Label ("AccelLabel:");
        accellabel_label.halign = Gtk.Align.END;

        var copy_label = new Granite.AccelLabel ("Copy", "<Ctrl>C");

        var popover_label = new Gtk.Label ("In a Popover:");
        popover_label.halign = Gtk.Align.END;

        var lock_button = new Gtk.ModelButton ();
        lock_button.get_child ().destroy ();
        lock_button.add (new Granite.AccelLabel ("Lock", "<Super>L"));

        var logout_button = new Gtk.ModelButton ();
        logout_button.get_child ().destroy ();
        logout_button.add (new Granite.AccelLabel ("Log Out…", "<Ctrl><Alt>Delete"));

        var popover_grid = new Gtk.Grid ();
        popover_grid.margin_top = popover_grid.margin_bottom = 3;
        popover_grid.orientation = Gtk.Orientation.VERTICAL;
        popover_grid.add (lock_button);
        popover_grid.add (logout_button);
        popover_grid.show_all ();

        var popover = new Gtk.Popover (null);
        popover.add (popover_grid);

        var popover_button = new Gtk.MenuButton ();
        popover_button.popover = popover;

        var undo_menuitem = new Gtk.MenuItem ();
        undo_menuitem.add (new Granite.AccelLabel ("Undo", "<Ctrl>Z"));

        var redo_menuitem = new Gtk.MenuItem ();
        redo_menuitem.add (new Granite.AccelLabel ("Redo", "<Ctrl><Shift>Z"));

        var menu_label = new Gtk.Label ("In a Menu:");
        menu_label.halign = Gtk.Align.END;

        var menu = new Gtk.Menu ();
        menu.add (undo_menuitem);
        menu.add (redo_menuitem);
        menu.show_all ();

        var menu_button = new Gtk.MenuButton ();
        menu_button.popup = menu;

        column_spacing = 12;
        row_spacing = 12;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        attach (accellabel_label, 0, 0);
        attach (copy_label, 1, 0);
        attach (popover_label, 0, 1);
        attach (popover_button, 1, 1);
        attach (menu_label, 0, 2);
        attach (menu_button, 1, 2);
    }
}
