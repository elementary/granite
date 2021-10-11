/*
 * Copyright 2020 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
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
    public int min_length { get; set; default = 0; }
    public Regex regex { get; set; default = null; }

    public ValidatedEntry () {
        changed.connect (() => {
            check_validity ();
        });
    }

    public ValidatedEntry.from_regex (Regex regex_arg) {
        regex = regex_arg;
        
        changed.connect (() => {
            check_validity ();
        });
    }
    
    private void check_validity () {
        is_valid = check_length ();
        
        if (is_valid && regex != null) {
            is_valid = regex.match (text);
        }
    }
    
    private bool check_length () {
        if (get_text_length () >= min_length) {
            return true;
        } else {
            return false;
        }
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
