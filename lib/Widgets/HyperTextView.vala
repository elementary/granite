/*
 *  Copyright (C) 2012–2021 elementary, Inc.
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
     * This class enables navigatable URLs in Gtk.TextView
     */
    public class HyperTextView : Gtk.TextView {

        private GLib.SList<Gtk.TextTag> uri_text_tags;
        private Regex uri_regex;

        construct {
            uri_text_tags = new GLib.SList<Gtk.TextTag> ();
            try {
                uri_regex = new Regex ("([^\\s]+:\\/\\/)?[^\\s]{2,}\\.[^\\s]{2,}");
            } catch (GLib.RegexError e) {
                critical ("RegexError while constructing URI regex: %s", e.message);
            }

            buffer.changed.connect (on_buffer_changed);
            button_press_event.connect_after (on_after_button_press_event);
            motion_notify_event.connect (on_motion_notify_event);
        }

        private void on_buffer_changed () {
            uri_text_tags.foreach ((tag) => {
                buffer.tag_table.remove (tag);
            });
            uri_text_tags = new GLib.SList<Gtk.TextTag> ();

            GLib.MatchInfo match_info;

            var buffer_text = buffer.text;
            uri_regex.match (buffer_text, 0, out match_info);

            while (match_info.matches ()) {
                Gtk.TextIter start, end;
                int start_pos, end_pos;
                string text = match_info.fetch (0);
                match_info.fetch_pos (0, out start_pos, out end_pos);
                buffer.get_iter_at_offset (out start, start_pos);
                buffer.get_iter_at_offset (out end, end_pos);

                var tag = buffer.create_tag ("%i-%i".printf (start_pos, end_pos), "underline", Pango.Underline.SINGLE);
                if (!text.contains ("://")) {
                    text = "http://" + text;
                }
                tag.set_data ("uri", text);
                buffer.apply_tag (tag, start, end);
                uri_text_tags.append (tag);

                try {
                    match_info.next ();
                } catch (GLib.RegexError e) {
                    warning ("RegexError while scanning for the next URI match: %s", e.message);
                }
            }
        }

        private bool on_after_button_press_event () {
            Gtk.TextIter text_iter;
            buffer.get_iter_at_mark (out text_iter, buffer.get_insert ());
            
            var tags = text_iter.get_tags ();
            foreach (var tag in tags) {
                if (tag.get_data<string?> ("uri") != null) {
                    var uri = tag.get_data<string> ("uri");

                    try {
                        GLib.AppInfo.launch_default_for_uri (uri, null);
                    } catch (GLib.Error e) {
                        warning ("Unable to open URI '%s': %s", uri, e.message);

                        var error_dialog = new Granite.MessageDialog (
                            _("Unable to open URI"),
                            e.message,
                            new ThemedIcon ("dialog-error"),
                            Gtk.ButtonsType.CLOSE
                        );
                        error_dialog.run ();
                        error_dialog.destroy ();
                    }
                    break;
                }
            }
            return Gdk.EVENT_PROPAGATE;
        }

        private bool was_hovering = false;

        private bool on_motion_notify_event (Gtk.Widget widget, Gdk.EventMotion event) {
            var window = get_window (Gtk.TextWindowType.TEXT);

            if (window != null) {
                bool is_hovering = false;
            
                int x, y;
                window_to_buffer_coords (Gtk.TextWindowType.WIDGET, (int) event.x, (int) event.y, out x, out y);

                Gtk.TextIter text_iter;
                if (get_iter_at_location (out text_iter, x, y)) {
                    var tags = text_iter.get_tags ();

                    foreach (var tag in tags) {
                        if (tag.get_data<string?> ("uri") != null) {
                            is_hovering = true;
                            break;
                        }
                    }
                }

                if (is_hovering && !was_hovering) {
                    window.cursor = new Gdk.Cursor.from_name (get_display (), "pointer");
                    was_hovering = is_hovering;

                } else if (!is_hovering && was_hovering) {
                    window.cursor = new Gdk.Cursor.from_name (get_display (), "text");
                    was_hovering = is_hovering;
                }
            }
            return Gdk.EVENT_PROPAGATE;
        }
    }
}
