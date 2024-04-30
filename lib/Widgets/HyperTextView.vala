/*
 *  Copyright 2021 elementary, Inc.
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

/**
 * This class enables navigatable URLs in Gtk.TextView
 * @since 6.1.3
 */
public class Granite.HyperTextView : Gtk.TextView {

    private const int FORCE_FULL_BUFFER_RESCAN_CHANGE_START_OFFSET = -1;

    private uint buffer_changed_debounce_timeout_id = 0;
    private int buffer_cursor_position_when_change_started = 0;

    private GLib.HashTable<string, Gtk.TextTag> uri_text_tags;
    private Regex uri_regex;

    private bool is_control_key_pressed = false;

    private int pointer_x;
    private int pointer_y;

    construct {
        var http_charset = "[\\w\\/\\-\\+\\.:@\\?&%=#]";
        var email_charset = "[\\w\\-\\.]";
        var email_tld_charset = "[\\w\\-]";

        var http_match_str = @"https?:\\/\\/$(http_charset)+\\.$(http_charset)+";
        var email_match_str = @"(mailto:)?$(email_charset)+@$(email_charset)+\\.$(email_tld_charset)+";

        var uri_regex_str = "(?:(" +
                http_match_str +
            ")|(" +
                email_match_str +
            "))";

        uri_text_tags = new GLib.HashTable<string, Gtk.TextTag> (str_hash, direct_equal);
        try {
            uri_regex = new Regex (uri_regex_str);
        } catch (GLib.RegexError e) {
            critical ("RegexError while constructing URI regex: %s", e.message);
        }

        buffer_connect (buffer);
        notify["buffer"].connect (() => {
            buffer_connect (buffer);
            buffer.changed ();
        });

        var motion_controller = new Gtk.EventControllerMotion ();
        motion_controller.motion.connect (on_motion_notify_event);
        add_controller (motion_controller);

        var keypress_controller = new Gtk.EventControllerKey ();
        keypress_controller.key_pressed.connect (on_key_press_event);
        keypress_controller.key_released.connect (on_key_release_event);

        var click_controller = new Gtk.GestureClick ();
        click_controller.pressed.connect (on_click_event);
        add_controller (click_controller);

        var focus_controller = new Gtk.EventControllerFocus ();
        focus_controller.leave.connect (() => {
            set_cursor (new Gdk.Cursor.from_name ("text", null));
            is_control_key_pressed = false;
        });
        add_controller (focus_controller);

        realize.connect (() => {
            // Attach the keypress controller to the root so we can see Ctrl key presses
            // even when the widget isn't focused
            get_root ().add_controller (keypress_controller);
        });
    }

    private void buffer_connect (Gtk.TextBuffer buffer) {
        buffer.notify["cursor-position"].connect (on_buffer_cursor_position_changed);
        buffer.paste_done.connect (on_paste_done);
        buffer.changed.connect_after (on_after_buffer_changed);
    }

    private void on_buffer_cursor_position_changed () {
        if (buffer_cursor_position_when_change_started == 0) {
            buffer_cursor_position_when_change_started = buffer.cursor_position;
        }
    }

    private void on_paste_done (Gdk.Clipboard clipboard) {
        // force rescan of whole buffer:
        buffer_cursor_position_when_change_started = FORCE_FULL_BUFFER_RESCAN_CHANGE_START_OFFSET;
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

            if (change_start_offset == FORCE_FULL_BUFFER_RESCAN_CHANGE_START_OFFSET || change_start_offset == change_end_offset) {
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
        if (buffer_start_offset == buffer_end_offset) {
            return;
        }

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

        /*
        Character counts are usually referred to as offsets, while byte counts are called indexes.
        If you confuse these two, things will work fine with ASCII, but as soon as your
        buffer contains multibyte characters, bad things will happen.
        https://developer.gnome.org/gtk3/stable/TextWidget.html
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
            if (!match_text.contains ("://") && match_text.contains ("@") && !match_text.has_prefix ("mailto:")) {
                match_text = "mailto:" + match_text;
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

    private bool on_key_press_event (uint keyval, uint keycode, Gdk.ModifierType state) {
        if (keyval == Gdk.Key.Control_L || keyval == Gdk.Key.Control_R) {
            var uri_hovering_over = get_uri_at_location (pointer_x, pointer_y);
            if (uri_hovering_over != null) {
                set_cursor (new Gdk.Cursor.from_name ("pointer", null));
            }

            is_control_key_pressed = true;
        }

        return Gdk.EVENT_PROPAGATE;
    }

    private void on_key_release_event (uint keyval, uint keycode, Gdk.ModifierType state) {
        if (keyval == Gdk.Key.Control_L || keyval == Gdk.Key.Control_R) {
            set_cursor (new Gdk.Cursor.from_name ("text", null));
            is_control_key_pressed = false;
        }
    }

    private void on_click_event (int n_press, double x, double y) {
        if (!is_control_key_pressed) {
            return;
        }

        var uri = get_uri_at_location ((int)x, (int)y);
        if (uri == null) {
            return;
        }

        Gtk.show_uri (null, uri, Gdk.CURRENT_TIME);
        set_cursor (new Gdk.Cursor.from_name ("text", null));
        is_control_key_pressed = false;
    }

    private void on_motion_notify_event (double x, double y) {
        pointer_x = (int)x;
        pointer_y = (int)y;

        var uri_hovering_over = get_uri_at_location (pointer_x, pointer_y);

        if (uri_hovering_over != null && !has_tooltip) {
            has_tooltip = true;
            tooltip_markup = string.joinv ("\n", {
                _("Follow Link"),
                Granite.TOOLTIP_SECONDARY_TEXT_MARKUP.printf (_("Control + Click"))
            });

        } else if (uri_hovering_over == null && has_tooltip) {
            has_tooltip = false;
        }
    }

    private string? get_uri_at_location (int location_x, int location_y) {
        string? uri = null;

        int x, y;
        window_to_buffer_coords (Gtk.TextWindowType.TEXT, location_x, location_y, out x, out y);

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

        return uri;
    }
}
