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

namespace Granite.Widgets {
    public class AboutDialog : Granite.GtkPatch.AboutDialog
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

        private Button help_button;
        private Button translate_button;
        private Button bug_button;

        private const string HELP_BUTTON_STYLESHEET = """
            .help_button {
                border-radius: 20px;
                padding: 3px;
            }
        """;

        /**
         * Creates a new Granite.Widgets.AboutDialog
         */
        public AboutDialog()
        {
            Box action_area = (Box) get_action_area ();

            /* help button style */
            var help_button_style_provider = new CssProvider();
            try {
                help_button_style_provider.load_from_data(HELP_BUTTON_STYLESHEET, -1);
            }
            catch (Error e) {
                warning ("GraniteWidgetsAboutDialog: %s. Some widgets will not look as intended", e.message);
            }

            /* help button */
            help_button = new Button.with_label("?");
            help_button.get_style_context ().add_class ("help_button");
            help_button.get_style_context ().add_provider (help_button_style_provider,
                                                           STYLE_PROVIDER_PRIORITY_APPLICATION);
            help_button.halign = Gtk.Align.CENTER;
            help_button.pressed.connect(() => { activate_link(help); });

            /* Circular help button */
            help_button.set_size_request (29, -1);

            action_area.pack_end (help_button, false, false, 0);
            ((Gtk.ButtonBox) action_area).set_child_secondary (help_button, true);
            ((Gtk.ButtonBox) action_area).set_child_non_homogeneous (help_button, true);

            /* translate button */
            translate_button = new Button.with_label("Translate this app");
            translate_button.pressed.connect ( () => { activate_link(translate); });
            action_area.pack_start (translate_button, false, false, 0);

            /* bug button */
            bug_button = new Button.with_label ("Report a problem");
            bug_button.pressed.connect (() => { activate_link(bug); });
            action_area.pack_start (bug_button, false, false, 0);

            action_area.reorder_child (bug_button, 0);
            action_area.reorder_child (translate_button, 0);

            action_area.show_all ();
        }
    }

    public extern void show_about_dialog (Gtk.Window *parent, ...);
}


