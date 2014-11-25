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
 *
 *  Authors: Mathijs Henquet <mathijs.henquet@gmail.com>,
 *           ammonkey <am.monkeyd@gmail.com>
 */

/*
 * ToolButtonWithMenu
 * - support long click / right click with depressed button states
 * - activate a GtkAction if any or popup a menu.
 * (used in history navigation buttons next/prev, appmenu)
 *
 */

using Gdk;
using Gtk;

namespace Granite.Widgets {

    /**
     * ToolButtonWithMenu
     * - support long click / right click with depressed button states
     * - activate a GtkAction if any or popup a menu
     * (used in history navigation buttons and the AppMenu)
     */
    [Deprecated (replacement = "Gtk.MenuButton", since = "0.3")]
    public class ToolButtonWithMenu : Gtk.ToggleToolButton {

        public signal void right_click (Gdk.EventButton ev);

        /**
         * VMenuPosition:
         */
        public enum VMenuPosition {
            /**
             * TOP: Align the menu at top of button position.
             */
            TOP,
            /**
             * TOP: Align the menu at top of button position.
             */
            BOTTOM
        }

        /**
         * HMenuPosition:
         */
        public enum HMenuPosition {
            /**
             * LEFT: Left-align the menu relative to the button's position.
             */
            LEFT,
            /**
             * CENTER: Center-align the menu relative to the button's position.
             */
            CENTER,
            /**
             * RIGHT: Right-align the menu relative to the button's position.
             */
            RIGHT,
            /**
             * INSIDE_WINDOW: Keep the menu inside the GtkWindow. Center-align when possible.
             */
            INSIDE_WINDOW // center by default but move it the menu goes out of the window
        }

        public HMenuPosition horizontal_menu_position { get; set; default = HMenuPosition.CENTER; }
        public VMenuPosition vertical_menu_position { get; set; default = VMenuPosition.BOTTOM; }

        public Gtk.Action? myaction;
        public ulong toggled_sig_id;

        /** 
         * Delegate function used to populate menu 
         */
        public delegate Gtk.Menu MenuFetcher ();

        public MenuFetcher fetcher {
            set {
                _fetcher = value;
                has_fetcher = true;
            }
            get {
                return _fetcher;
            }
        }

        public Gtk.Menu menu {
            get {
                return _menu;
            }
            set {
                if (has_fetcher) {
                    warning ("Don't set the menu property on a ToolMenuButton when there is already a menu fetcher");
                }
                else {
                    _menu = value;
                    update_menu_properties ();
                }
            }
        }

        private int LONG_PRESS_TIME = Gtk.Settings.get_default ().gtk_double_click_time * 2;
        private int timeout = -1;
        private uint last_click_time = -1;
        private bool has_fetcher = false;

        private unowned MenuFetcher _fetcher;
        private Gtk.Menu _menu;
        private Gtk.Button button;

        public ToolButtonWithMenu.from_action (Gtk.Action action) {
            this.from_stock (action.stock_id, IconSize.MENU, action.label, new Gtk.Menu ());
            use_action_appearance = true;
            set_related_action (action);
            action.connect_proxy (this);
            myaction = action;
        }

        public ToolButtonWithMenu.from_stock (string stock_image, IconSize size, string label, Gtk.Menu menu) {
            Image image = new Image.from_stock (stock_image, size);
            this (image, label, menu);
        }

        private void update_menu_properties () {
            menu.attach_to_widget (this, null);
            menu.deactivate.connect ( () => {
                deactivate_menu ();
            });
            menu.deactivate.connect (popdown_menu);
        }

        public ToolButtonWithMenu (Image image, string label, Gtk.Menu menu)
        {           
            icon_widget = image;
            label_widget = new Gtk.Label (label);
            (label_widget as Gtk.Label).use_underline = true;
            can_focus = true;
            set_tooltip_text (label);

            this.menu = menu;

            mnemonic_activate.connect (on_mnemonic_activate);

            button = get_child () as Gtk.Button;
            button.events |= EventMask.BUTTON_PRESS_MASK
                          |  EventMask.BUTTON_RELEASE_MASK;

            button.button_press_event.connect (on_button_press_event);
            button.button_release_event.connect (on_button_release_event);
        }

        public override void show_all () {
            menu.show_all ();
            base.show_all ();
        }

        private void deactivate_menu () {
            if (myaction != null)
                myaction.block_activate ();

            active = false;

            if (myaction != null)
                myaction.unblock_activate ();
        }

        private void popup_menu_and_depress_button (Gdk.EventButton ev) {
            if (myaction != null)
                myaction.block_activate ();

            active = true;

            if (myaction != null)
                myaction.unblock_activate ();

            popup_menu (ev);
        }

        private bool on_button_release_event (Gdk.EventButton ev) {
            if (ev.time - last_click_time < LONG_PRESS_TIME) {
                if (myaction != null) {
                    myaction.activate ();
                } else {
                    active = true;
                    popup_menu (ev);
                }
            }

            if (timeout != -1) {
                Source.remove ((uint) timeout);
                timeout = -1;
            }

            return true;
        }

        private bool on_button_press_event (Gdk.EventButton ev) {
            // If the button is kept pressed, don't make the user wait when there's no action
            int max_press_time = (myaction != null)? LONG_PRESS_TIME : 0;

            if (timeout == -1 && ev.button == 1) {
                last_click_time = ev.time;
                timeout = (int) Timeout.add(max_press_time, () => {
                    // long click
                    timeout = -1;
                    popup_menu_and_depress_button (ev);
                    return false;
                });
            }

            if (ev.button == 3) {
                // right_click
                right_click (ev);

                if (myaction != null)
                    popup_menu_and_depress_button (ev);
            }

            return true;
        }

        private bool on_mnemonic_activate (bool group_cycling) {
            // ToggleButton always grabs focus away from the editor,
            // so reimplement Widget's version, which only grabs the
            // focus if we are group cycling.
            if (!group_cycling) {
                activate ();
            } else if (can_focus) {
                grab_focus ();
            }

            return true;
        }

        protected new void popup_menu (Gdk.EventButton? ev = null) {
            if (has_fetcher)
                fetch_menu ();

            try {
                menu.popup (null,
                            null,
                            get_menu_position,
                            (ev == null) ? 0 : ev.button,
                            (ev == null) ? get_current_event_time () : ev.time);
            } finally {
                // Highlight the parent
                if (menu.attach_widget != null)
                    menu.attach_widget.set_state_flags (StateFlags.SELECTED, true);

                menu.select_first (false);
            }
        }

        protected void popdown_menu () {
            menu.popdown ();

            // Unhighlight the parent
            if (menu.attach_widget != null)
                menu.attach_widget.set_state_flags (StateFlags.NORMAL, true);
        }

        private void fetch_menu () {
            _menu = fetcher ();
            update_menu_properties ();
        }

        private void get_menu_position (Gtk.Menu menu, out int x, out int y, out bool push_in) {
            Allocation menu_allocation;
            menu.get_allocation (out menu_allocation);

            if (menu.attach_widget == null ||
                menu.attach_widget.get_window () == null) {
                // Prevent null exception in weird cases
                x = 0;
                y = 0;
                push_in = true;
                return;
            }

            menu.attach_widget.get_window ().get_origin (out x, out y);
            
            Allocation allocation;
            menu.attach_widget.get_allocation (out allocation);

            /* Left, right or center??*/
            if (horizontal_menu_position == HMenuPosition.RIGHT) {
                x += allocation.x;

            } else if (horizontal_menu_position == HMenuPosition.CENTER) {
                x += allocation.x;
                x -= menu_allocation.width / 2;
                x += allocation.width / 2;
            }
            else {
                x += allocation.x;
                x -= menu_allocation.width;
                x += this.get_allocated_width();
            }

            /* Bottom or top?*/
            if (vertical_menu_position == VMenuPosition.TOP) {
                y -= menu_allocation.height;
                y -= this.get_allocated_height ();
            }

            int width, height;
            menu.get_size_request (out width, out height);

            if (horizontal_menu_position == HMenuPosition.INSIDE_WINDOW) {
                /* Get window geometry */
                var parent_widget = get_toplevel ();

                Gtk.Allocation window_allocation;
                parent_widget.get_allocation (out window_allocation);

                parent_widget.get_window ().get_origin (out x, out y);
                int parent_window_x0 = x;
                int parent_window_xf = parent_window_x0 + window_allocation.width;

                // Now check if the menu is outside the window and un-center it
                // if that's the case

                if (x + menu_allocation.width > parent_window_xf)
                    x = parent_window_xf - menu_allocation.width; // Move to left

                if (x < parent_window_x0)
                    x = parent_window_x0; // Move to right
            }

            y += allocation.y;

            if (y + height >= menu.attach_widget.get_screen ().get_height ())
                y -= height;
            else
                y += allocation.height;

            push_in = true;
        }
    }
}

