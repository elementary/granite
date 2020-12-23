/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * ValidatedEntry is a {@link Gtk.Entry} subclass that is meant to be used in
 * forms where input must be validated before the form can be submitted. It
 * provides feedback to users about the state of input validation and keeps
 * track of its own validation state. By default, input is considered invalid.
 *
 * ''Example''<<BR>>
 * {{{
 *   var validated_entry = new Granite.ValidatedEntry ();
 *   username_entry.changed.connect (() => {
 *       username_entry.is_valid = username_entry.text == "valid input";
 *   });
 * }}}
 *
 * If the ValidatedEntry.from_regex () constructor is used then the entry automatically
 * sets its validity status. A valid regex must be passed to this constructor.
 *
 * ''Example''<<BR>>
 * {{{
 *   Regex? regex = null;
 *   ValidatedEntry only_lower_case_letters_entry;
 *   try {
 *       regex = new Regex ("^[a-z]*$");
 *       only_lower_case_letters_entry = new ValidatedEntry.from_regex (regex);
 *   } catch (Error e) {
 *       critical (e.message);
 *       // Provide a fallback entry
 *   }
 * }}}

 */
public class Granite.ValidatedEntry : Gtk.Entry {
    /**
     * Whether or not text is considered valid input
     */
    public bool is_valid { get; set; default = false; }

    public ValidatedEntry.from_regex (Regex regex) {
        changed.connect (() => {
            is_valid = regex.match (text);
        });
    }

    construct {
        activates_default = true;

        changed.connect_after (() => {
            unowned Gtk.StyleContext style_context = get_style_context ();

            if (text == "") {
                secondary_icon_name = null;
                style_context.remove_class (Gtk.STYLE_CLASS_ERROR);
            } else if (is_valid) {
                secondary_icon_name = "process-completed-symbolic";
                style_context.remove_class (Gtk.STYLE_CLASS_ERROR);
            } else {
                secondary_icon_name = "process-error-symbolic";
                style_context.add_class (Gtk.STYLE_CLASS_ERROR);
            }
        });
    }
}
