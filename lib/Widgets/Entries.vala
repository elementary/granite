/***
    Copyright (C) 2011-2013 Avi Romanoff <avi@elementaryos.org>,
                            Allen Lowe <allen@elementaryos.org>,
                            Maxwell Barvian <maxwell@elementaryos.org>,
                            Julien Spautz <spautz.julien@gmail.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/


namespace Granite.Widgets {

    /**
     * A text entry space with hint and clear icon
     */
    [Deprecated (since = "0.3", replacement = "Gtk.Entry.placeholder_text")]
    public class HintedEntry : Gtk.Entry {
        public bool has_clear_icon { get; set; default = false; }

        public string hint_string {
            get { return placeholder_text; }
            set { placeholder_text = value; }
        }

        /**
         * Makes new hinted entry
         *
         * @param hint_string hint for new entry
         */
        public HintedEntry (string hint_string) {
            this.hint_string = hint_string;

            this.icon_release.connect ((pos) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY)
                     text = "";
            });

            this.changed.connect (manage_icon);
            this.notify["has-clear-icon"].connect (manage_icon);
        }

        private void manage_icon () {
            if (has_clear_icon && text != "")
                set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
            else
                set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
        }

        /*
         * These 4 functions must be removed, they are only kept here
         * for API compatibility.
         */
        [Deprecated (since = "0.2")]
        protected void hint () {
        }

        [Deprecated (since = "0.2")]
        protected void unhint () {
        }

        [Deprecated (since = "0.2", replacement = "Gtk.Entry.get_text")]
        public new string get_text () {
            return text;
        }

        [Deprecated (since = "0.2", replacement = "Gtk.Entry.set_text")]
        public new void set_text (string text) {
            this.text = text;
        }
    }

    /**
     * A searchbar with hint-text.
     */
    [Deprecated (since = "0.3", replacement = "Gtk.SearchEntry")]
    public class SearchBar : HintedEntry {
        private uint timeout_id = 0;

        /**
         * This value handles how much time (in ms) should pass
         * after the user stops typing. By default it is set
         * to 300 ms.
         */
        public int pause_delay { get; set; default = 300; }

        /**
         * text_changed () signal is emitted after a short delay,
         * which depends on pause_delay.
         * If you need a synchronous signal without any delay,
         * use changed () method.
         */
        public signal void text_changed_pause (string text);

        /**
         * search_icon_release () signal is emitted after releasing the mouse button,
         * which depends on the SearchBar's icon.
         * It can be useful to show something on the icon press,
         * we can show a PopOver, for example.
         */
        public signal void search_icon_release ();

        /**
         * Makes new search bar
         *
         * @param hint_string hint for new search bar
         */
        public SearchBar (string hint_string) {
            base (hint_string);

            has_clear_icon = true;

            set_icon_from_gicon (Gtk.EntryIconPosition.PRIMARY,
                                 new ThemedIcon.with_default_fallbacks ("edit-find-symbolic"));

            // Signals and callbacks
            changed.connect_after (on_changed);
            icon_release.connect (on_icon_release);

            /* Pressing Escape should clear text */
            key_press_event.connect ((e) => {
                switch (e.keyval) {
                    case Gdk.Key.Escape:
                        text = "";
                        return true;
                }

                return false;
            });
        }

        private void on_icon_release (Gtk.EntryIconPosition position) {
            if (position == Gtk.EntryIconPosition.PRIMARY)
                search_icon_release (); // emit signal
        }

        private void on_changed () {
            if (timeout_id > 0)
                Source.remove (timeout_id);

            timeout_id = Timeout.add (pause_delay, emit_text_changed);
        }

        private bool emit_text_changed () {
            var terms = get_text ();
            text_changed_pause (terms); // Emit signal

            return Source.remove (timeout_id);
        }
    }
}
