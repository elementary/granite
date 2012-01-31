//
//  Copyright (C) 2008 Christian Hergert <chris@dronelabs.com>
//  Copyright (C) 2011 Giulio Collura
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

using Gtk;
using Gdk;

namespace Granite.Widgets {

    public class ModeButton : Gtk.Box {

        public signal void mode_added (int index, Gtk.Widget widget);
        public signal void mode_removed (int index, Gtk.Widget widget);
        public signal void mode_changed (Gtk.Widget widget);

        // Style properties. Please note that style class names are for internal
        // use only. Theme developers should use GraniteWidgetsModeButton instead.
        internal static CssProvider style_provider;
        internal static StyleContext widget_style;
        private const int style_priority = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION;

        private const string STYLESHEET = """
            .GraniteModeButton .button {
                -GtkToolbar-button-relief: normal;
                border-radius: 0 0 0 0;
                border-style: solid;
                border-width: 1 0 1 1;

                -unico-outer-stroke-width: 1 0 1 0;
                -unico-outer-stroke-radius: 0 0 0 0;
            }

            .GraniteModeButton .button:active,
            .GraniteModeButton .button:insensitive {
                -unico-outer-stroke-width: 1 0 1 0;
            }

            .GraniteModeButton .button:first-child {
                border-radius: 3 0 0 3;
                border-width: 1 0 1 1;

                -unico-outer-stroke-width: 1 0 1 1;
            }

            .GraniteModeButton .button:last-child {
                border-radius: 0 3 3 0;
                border-width: 1;

                -unico-outer-stroke-width: 1 1 1 0;
            }
        """;

        private int _selected = -1;

        public int selected {
            get {
                return _selected;
            }
            set {
                set_active(value);
            }
        }

        public uint n_items {
            get {
                return get_children ().length ();
            }
        }

        public ModeButton () {

            if (style_provider == null)
            {
                style_provider = new CssProvider ();
                try {
                    style_provider.load_from_data (STYLESHEET, -1);
                } catch (Error e) {
                    warning ("GraniteModeButton: %s. The widget will not look as intended", e.message);
                }
            }

            widget_style = get_style_context ();
            widget_style.add_class ("GraniteModeButton");

            homogeneous = true;
            spacing = 0;
            app_paintable = true;
            set_visual (get_screen ().get_rgba_visual ());

            can_focus = true;
        }

        public int append_pixbuf (Gdk.Pixbuf? pixbuf) {
            if (pixbuf == null) {
                warning ("GraniteWidgetsModeButton: Attempt to add null pixbuf failed.");
                return -1;
            }

            var image = new Image.from_pixbuf (pixbuf);
            return append (image);
        }

        public int append_text (string? text) {
            if (text == null) {
                warning ("GraniteWidgetsModeButton: Attempt to add null text string failed.");
                return -1;
            }

            return append (new Gtk.Label(text));
        }

        /**
         * This is the recommended method for adding icons to the ModeButton widget.
         * If the name of a symbolic icon is passed, it will be properly themed for
         * each state of the widget. That is, it will match the foreground color
         * defined by the theme for each state (active, prelight, insensitive, etc.)
         */
        public int append_icon (string icon_name, Gtk.IconSize size) {
            return append (new Image.from_icon_name (icon_name, size));
        }

        public int append (Gtk.Widget w) {
            if (w == null) {
                warning ("GraniteWidgetsModeButton: Attempt to add null widget failed.");
                return -1;
            }

            var button = new ModeButtonItem ();

            button.add (w);

            button.button_press_event.connect (() => {
                int selected = get_children().index (button);
                set_active (selected);
                return true;
            });

            add (button);
            button.show_all ();

            int item_index = (int)get_children ().length ();
            mode_added (item_index, w); // Emit the added signal
            return item_index;
        }

        public void set_active (int new_active_index) {
            if (new_active_index >= get_children ().length () || _selected == new_active_index)
                return;

            if (_selected >= 0)
                ((ToggleButton) get_children ().nth_data (_selected)).set_active (false);

            _selected = new_active_index;
            ((ToggleButton) get_children ().nth_data (_selected)).set_active (true);

            mode_changed (((ToggleButton) get_children ().nth_data (_selected)).get_child ());
        }

        public void set_item_visible (int index, bool val) {
            var item = get_children ().nth_data (index);
            if (item == null)
                return;

            item.set_no_show_all (!val);
            item.set_visible (val);
        }

        public new void remove (int index) {
            mode_removed (index, (get_children ().nth_data (index) as Gtk.Bin).get_child ());
            get_children ().nth_data (index).destroy ();
        }

        public void clear_children () {
            foreach (weak Widget button in get_children ()) {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }

            _selected = -1;
        }

        protected override bool scroll_event (EventScroll ev) {
            if (ev.direction == Gdk.ScrollDirection.DOWN) {
                selected ++;
            }
            else if (ev.direction == Gdk.ScrollDirection.UP) {
                selected --;
            }

            return false;
        }
    }

    private class ModeButtonItem : Gtk.ToggleButton {
        public ModeButtonItem () {
            can_focus = false;

            const int style_priority = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION;

            get_style_context ().add_class ("raised");
            get_style_context ().add_provider (ModeButton.style_provider, style_priority);
        }
    }
}

