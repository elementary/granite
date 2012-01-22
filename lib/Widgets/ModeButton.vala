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

        /* Style properties. Please note that style class names are for internal
           usage only. Theme developers should use GraniteWidgetsModeButton instead.
         */

        public static CssProvider style_provider;
        public static StyleContext widget_style;

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
                return get_children().length();
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
            set_visual (get_screen().get_rgba_visual());

            can_focus = true;
        }

        public void append_pixbuf (Gdk.Pixbuf? pixbuf) {
            if (pixbuf == null)
                return;

            var image = new Image.from_pixbuf (pixbuf);
            append (image);
        }

        public void append_text (string? text) {
            if (text == null)
                return;

            append (new Gtk.Label(text));
        }

        /**
         * This is the recommended function for adding icons to the ModeButton widget.
         * If you pass the name of a symbolic icon, it will be properly themed for
         * every state of the widget. That is, it will match the foreground color
         * defined by the theme for each state (active, prelight, insensitive, etc.)
         */
        public void append_icon (string icon_name, Gtk.IconSize size) {
            append_mode_button_item (null, icon_name, size);
        }

        public void append (Gtk.Widget w) {
            append_mode_button_item (w, null, null);
        }

        /**
         * This function adds the foreground style properties of the given style
         * context to the widget's icons. This is useful when you want to make the widget
         * adapt its symbolic icon color to that of the parent in case the GTK+
         * theme has not set them correctly. This function only affects the behavior
         * of icons added with append_icon().
         */
        public void set_icon_foreground_style (Gtk.StyleContext icon_style) {
            foreach (weak Widget button in get_children ()) {
                (button as ModeButtonItem).set_icon_foreground_style (icon_style);
            }
        }

        public void set_active (int new_active_index) {

            if (new_active_index >= get_children().length () || _selected == new_active_index)
                return;

            if (_selected >= 0)
                ((ToggleButton) get_children().nth_data(_selected)).set_active (false);

            _selected = new_active_index;
            ((ToggleButton) get_children().nth_data(_selected)).set_active (true);

            mode_changed(((ToggleButton) get_children().nth_data(_selected)).get_child());
        }

        public void set_item_visible(int index, bool val) {
            var item = get_children().nth_data(index);
            if(item == null)
                return;

            item.set_no_show_all(!val);
            item.set_visible(val);
        }

        public new void remove(int index)
        {
            mode_removed(index, (get_children().nth_data(index) as Gtk.Bin).get_child ());
            get_children().nth_data(index).destroy();
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
            if(ev.direction == Gdk.ScrollDirection.DOWN) {
                selected ++;
            }
            else if (ev.direction == Gdk.ScrollDirection.UP) {
                selected --;
            }

            return false;
        }

        private void append_mode_button_item (Gtk.Widget? w, string? icon_name, Gtk.IconSize? size) {
            var button = new ModeButtonItem ();

            /* Modifying properties */
            if (icon_name != null && size != null && w == null) {
                button.set_icon (icon_name, size);
            } else {
                button.add(w);
            }

            button.button_press_event.connect (() => {
                int selected = get_children().index (button);
                set_active (selected);
                return true;
            });

            add(button);
            button.show_all ();

            mode_added((int)get_children().length(), w);
        }

    }

    private class ModeButtonItem : Gtk.ToggleButton {

        /* The main purpose of this class is handling icon theming */

        private bool has_themed_icon;
        private StyleContext? icon_style;

        private string icon_name = "";
        private Gtk.IconSize? icon_size = null;

        private const int style_priority = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION;

        public ModeButtonItem () {
            can_focus = false;
            has_themed_icon = false;

            icon_style = null;

            get_style_context().add_class ("button");
            get_style_context().add_class ("raised");
            get_style_context().add_provider (ModeButton.style_provider, style_priority);

            /* We need to track state changes in order to modify the icon */
            state_flags_changed.connect ( () => {
                if (has_themed_icon)
                    load_icon ();
            });
        }

        public void set_icon_foreground_style (StyleContext? icon_style) {
            this.icon_style = icon_style;
        }

        public new void set_icon (string name, Gtk.IconSize size) {
            icon_name = name;
            icon_size = size;

            has_themed_icon = true;

            load_icon ();
        }

        public new void set_image (Gtk.Image? image) {
            if (image == null)
                return;

            /* Remove previous images */
            foreach (weak Widget _image in get_children ()) {
                if (this.get_parent () != null && _image is Gtk.Image)
                    _image.destroy();
            }

            /* Add new image */
            add (image);

            show_all ();
        }

        private void load_icon () {
            set_image (new Image.from_pixbuf (render_themed_icon()));
        }

        private Gdk.Pixbuf? render_themed_icon () {
            Gdk.Pixbuf? rv = null;

            int width = 0, height = 0;
            icon_size_lookup (icon_size, out width, out height);

            try {
                var themed_icon = new GLib.ThemedIcon.with_default_fallbacks (icon_name);
                Gtk.IconInfo? icon_info = IconTheme.get_default().lookup_by_gicon (themed_icon as GLib.Icon, height, Gtk.IconLookupFlags.GENERIC_FALLBACK);
                if (icon_info != null)
                    rv = icon_info.load_symbolic_for_context (icon_style ?? ModeButton.widget_style);
            }
            catch (Error err) {
                warning ("%s", err.message);
            }

            return rv;
        }
    }
}

