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

        private uint buffer_changed_debounce_timeout_id = 0;
        private int buffer_cursor_position_when_change_started = 0;

        private GLib.HashTable<string, Gtk.TextTag> uri_text_tags;
        private Regex uri_regex;

        private bool is_control_key_pressed = false;
        private Gtk.Window? toplevel_window = null;

        construct {
            uri_text_tags = new GLib.HashTable<string, Gtk.TextTag> (str_hash, direct_equal);
            try {
                uri_regex = new Regex ("([^\\(\\[\\s\\.\"'`<>]+:\\/\\/)?[^\\(\\[\\s\"'`<>]{2,}\\.[^\\)\\]\\s\"'`<>]{2,}");
            } catch (GLib.RegexError e) {
                critical ("RegexError while constructing URI regex: %s", e.message);
            }

            buffer.notify["cursor-position"].connect (on_buffer_cursor_position_changed);
            buffer.paste_done.connect (on_paste_done);
            buffer.changed.connect_after (on_after_buffer_changed);

            button_release_event.connect (on_button_release_event);
            motion_notify_event.connect (on_motion_notify_event);
            focus_out_event.connect (on_focus_out_event);

            /**
             * Binding key_press/key_release signals to toplevel window
             * if possible enables us to detect when the Control key
             * is pressed even when HyperTextView is not focused.
             */

            foreach (unowned var window in Gtk.Window.list_toplevels ()) {
                if (window.get_parent_window () == null) {
                    toplevel_window = window;
                    break;
                }
            }

            if (toplevel_window != null) {
                toplevel_window.key_press_event.connect (on_key_press_event);
                toplevel_window.key_release_event.connect (on_key_release_event);
            } else {
                // bind to this as a fallback
                key_press_event.connect (on_key_press_event);
                key_release_event.connect (on_key_release_event);
            }
        }

        private void on_buffer_cursor_position_changed () {
            if (buffer_cursor_position_when_change_started == 0) {
                buffer_cursor_position_when_change_started = buffer.cursor_position;
            }
        }

        private void on_paste_done (Gtk.Clipboard clipboard) {
            // force rescan of whole buffer:
            buffer_cursor_position_when_change_started = -1;
        }

        private void on_after_buffer_changed () {
            if (buffer_changed_debounce_timeout_id != 0) {
                Source.remove (buffer_changed_debounce_timeout_id);
                buffer_changed_debounce_timeout_id = 0;
            }

            buffer_changed_debounce_timeout_id = GLib.Timeout.add (300, () => {
                buffer_changed_debounce_timeout_id = 0;

                var change_start_offset = buffer_cursor_position_when_change_started;
                var change_end_offset = buffer.cursor_position;

                buffer_cursor_position_when_change_started = 0;

                if (change_start_offset < 0) {
                    change_start_offset = 0;
                    change_end_offset = buffer.text.length;
                }

                update_tags_in_buffer_for_range.begin (
                    int.min (change_start_offset, change_end_offset),
                    int.max (change_start_offset, change_end_offset)
                );

                return GLib.Source.REMOVE;
            });
        }

        private async void update_tags_in_buffer_for_range (int buffer_start_offset, int buffer_end_offset) {
            Gtk.TextIter buffer_start_iter, buffer_end_iter;
            buffer.get_iter_at_offset (out buffer_start_iter, buffer_start_offset);
            buffer_start_iter.backward_line ();
            buffer_start_offset = buffer_start_iter.get_offset ();

            buffer.get_iter_at_offset (out buffer_end_iter, buffer_end_offset);
            buffer_end_iter.forward_line ();
            buffer_end_offset = buffer_end_iter.get_offset ();

            // Delete all tags in buffer for range [start_iter.offset,end_iter.offset]
            lock (uri_text_tags) {
                foreach (var tag_key in uri_text_tags.get_keys ()) {
                    int tag_start_offset, tag_end_offset;
                    tag_key.scanf ("[%i,%i]", out tag_start_offset, out tag_end_offset);

                    if (
                        tag_start_offset > buffer_start_offset && tag_start_offset < buffer_end_offset
                        ||
                        tag_end_offset > buffer_start_offset && tag_end_offset < buffer_end_offset
                    ) {
                        buffer.tag_table.remove (uri_text_tags.take (tag_key));
                    }
                }
            }

            /**
             * Character counts are usually referred to as offsets, while byte counts are called indexes.
             * If you confuse these two, things will work fine with ASCII, but as soon as your
             * buffer contains multibyte characters, bad things will happen.
             * https://developer.gnome.org/gtk3/stable/TextWidget.html
             */
            var buffer_start_index = buffer.text.index_of_nth_char (buffer_start_offset);
            var buffer_end_index = buffer.text.index_of_nth_char (buffer_end_offset);
            var buffer_substring = buffer.text.substring (buffer_start_index, buffer_end_index - buffer_start_index);

            if (buffer_substring.strip () == "") {
                // if the substring is empty, we do not have anything to do...
                return;
            }

            // Add new tags in buffer for range [start_iter.offset,end_iter.offset]
            GLib.MatchInfo match_info;
            uri_regex.match (buffer_substring, 0, out match_info);

            while (match_info.matches ()) {
                string match_text = match_info.fetch (0);

                /**
                 * Character counts are usually referred to as offsets, while byte counts are called indexes.
                 * If you confuse these two, things will work fine with ASCII, but as soon as your
                 * buffer contains multibyte characters, bad things will happen.
                 * https://developer.gnome.org/gtk3/stable/TextWidget.html
                 */
                int match_start_index, match_end_index;
                match_info.fetch_pos (0, out match_start_index, out match_end_index);

                int match_start_offset, match_end_offset;
                match_start_offset = buffer_substring.substring (0, match_start_index).char_count ();
                match_end_offset = buffer_substring.substring (0, match_end_index).char_count ();

                var buffer_match_start_offset = buffer_start_offset + match_start_offset;
                var buffer_match_end_offset = buffer_start_offset + match_end_offset;

                Gtk.TextIter buffer_match_start_iter, buffer_match_end_iter;
                buffer.get_iter_at_offset (out buffer_match_start_iter, buffer_match_start_offset);
                buffer.get_iter_at_offset (out buffer_match_end_iter, buffer_match_end_offset);

                var tag = buffer.create_tag (null, "underline", Pango.Underline.SINGLE);
                if (!match_text.contains ("://") && !match_text.has_prefix ("mailto:")) {
                    if (match_text[0] == '~') {
                        match_text = Environment.get_home_dir () + match_text.substring (1);
                    }

                    if (match_text[0] == '/') {
                        match_text = "file://" + match_text;
                    } else if (!match_text.contains (":") && match_text.contains ("@")) {
                        match_text = "mailto:" + match_text;
                    } else {
                        match_text = "http://" + match_text;
                    }
                }
                tag.set_data ("uri", match_text);
                buffer.apply_tag (tag, buffer_match_start_iter, buffer_match_end_iter);

                lock (uri_text_tags) {
                    uri_text_tags.set ("[%i,%i]".printf (buffer_match_start_offset, buffer_match_end_offset), tag);
                }

                try {
                    match_info.next ();
                } catch (GLib.RegexError e) {
                    warning ("RegexError while scanning for the next URI match: %s", e.message);
                }
            }
        }

        private bool on_key_press_event (Gdk.EventKey event) {
            if (event.keyval == Gdk.Key.Control_L || event.keyval == Gdk.Key.Control_R) {
                var window = get_window (Gtk.TextWindowType.TEXT);
                if (window != null) {
                    var pointer_device = window.get_display ().get_default_seat ().get_pointer ();
                    if (pointer_device != null) {
                        int pointer_x, pointer_y;
                        window.get_device_position (pointer_device, out pointer_x, out pointer_y, null);

                        var uri_hovering_over = get_uri_at_location (pointer_x, pointer_y);
                        if (uri_hovering_over != null) {
                            window.cursor = new Gdk.Cursor.from_name (get_display (), "pointer");
                        }
                    }
                }
                is_control_key_pressed = true;
            }
            return Gdk.EVENT_PROPAGATE;
        }

        private bool on_key_release_event (Gdk.EventKey event) {
            if (event.keyval == Gdk.Key.Control_L || event.keyval == Gdk.Key.Control_R) {
                var window = get_window (Gtk.TextWindowType.TEXT);
                if (is_control_key_pressed && window != null) {
                    window.cursor = new Gdk.Cursor.from_name (get_display (), "text");
                }
                is_control_key_pressed = false;
            }
            return Gdk.EVENT_PROPAGATE;
        }

        private bool on_button_release_event () {
            if (!is_control_key_pressed) {
                return Gdk.EVENT_PROPAGATE;
            }
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

        private bool on_motion_notify_event (Gtk.Widget widget, Gdk.EventMotion event) {
            var uri_hovering_over = get_uri_at_location ((int) event.x, (int) event.y);

            if (uri_hovering_over != null && !has_tooltip) {
                has_tooltip = true;
                tooltip_markup = string.joinv ("\n", {
                    _("Follow Link"),
                    TOOLTIP_SECONDARY_TEXT_MARKUP.printf (_("Control + Click"))
                });

            } else if (uri_hovering_over == null && has_tooltip) {
                has_tooltip = false;
            }

            return Gdk.EVENT_PROPAGATE;
        }

        private string? get_uri_at_location (int location_x, int location_y) {
            string? uri = null;
            var window = get_window (Gtk.TextWindowType.TEXT);

            if (window != null) {
                int x, y;
                window_to_buffer_coords (Gtk.TextWindowType.WIDGET, location_x, location_y, out x, out y);

                Gtk.TextIter text_iter;
                if (get_iter_at_location (out text_iter, x, y)) {
                    var tags = text_iter.get_tags ();

                    foreach (var tag in tags) {
                        if (tag.get_data<string?> ("uri") != null) {
                            uri = tag.get_data<string> ("uri");
                            break;
                        }
                    }
                }
            }
            return uri;
        }

        private bool on_focus_out_event (Gdk.EventFocus event) {
            is_control_key_pressed = false;
            return Gdk.EVENT_PROPAGATE;
        }
    }
}
