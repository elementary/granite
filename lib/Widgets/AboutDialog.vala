//  
//  Copyright (C) 2011 Adrien Plazas
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
// 
//  Authors:
//      Adrien Plazas <kekun.plazas@laposte.net>
//  Artists:
//      Daniel Foré <daniel@elementaryos.org>
// 

using Gtk;

public class Granite.Widgets.AboutDialog : Granite.GtkPatch.AboutDialog
{
    /**
     * The URL for the link to the website of the program.
     */
    public string help {
        set {
            _help = value;
            help_button.sensitive = !(_help == null || _help == "");
        }
        get { return _help; }
    }
    string _help = "";

    /**
     * The URL for the link to the website of the program.
     */
    public string translate {
        set {
            _translate = value;
            translate_button.sensitive = !(_translate == null || _translate == "");
        }
        get { return _translate; }
    }
    string _translate = "";

    /**
     * The URL for the link to the website of the program.
     */
    public string bug {
        set {
            _bug = value;
            bug_button.sensitive = !(_bug == null || _bug == "");
        }
        get { return _bug; }
    }
    string _bug = "";

    Button help_button;
    Button translate_button;
    Button bug_button;

    /**
     * Creates a new Granite.AboutDialog
     */
    public AboutDialog()
    {
        // Creating the buttons
        help_button = new Button.with_label(" ? ");
        help_button.get_style_context ().add_class ("help_button");
        help_button.pressed.connect(() => { activate_link(help); });

        translate_button = new Button.with_label("Translate this app");
        translate_button.pressed.connect(() => { activate_link(translate); });

        bug_button = new Button.with_label("Report a problem");
        bug_button.pressed.connect(() => { activate_link(bug); });

        // Pack
        action_hbox.pack_start(help_button);
        action_hbox.reorder_child(help_button, 0);
        action_homogeneous_hbox.pack_start(translate_button);
        action_homogeneous_hbox.pack_start(bug_button);
        action_homogeneous_hbox.reorder_child(bug_button, 0);
        action_homogeneous_hbox.reorder_child(translate_button, 0);

        // Show
        help_button.show();
        translate_button.show();
        bug_button.show();
    }
}
