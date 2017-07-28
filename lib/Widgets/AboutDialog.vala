/*
 * Copyright (C) 2011-2017 elementary LLC (https://launchpad.net/granite)
 *
 * This program or library is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Adrien Plazas <kekun.plazas@laposte.net>
 */

namespace Granite.Widgets {

    /**
     * This class makes an about dialog which goes in the App Menu on most apps.
     * This class is deprecated. Applications should instead provide an Appstream appdata.xml file to describe their metadata
     *
     * {{../../doc/images/AboutDialog.png}}
     */
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public class AboutDialog : Granite.GtkPatch.AboutDialog {
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

        private Gtk.Button help_button;
        private Gtk.Button translate_button;
        private Gtk.Button bug_button;

        /**
         * Creates a new Granite.Widgets.AboutDialog
         */
        public AboutDialog () {
            help_button = new Gtk.Button.with_label ("?");
            help_button.halign = Gtk.Align.CENTER;
            help_button.get_style_context ().add_class ("circular");

            translate_button = new Gtk.Button.with_label (_("Suggest Translations"));

            bug_button = new Gtk.Button.with_label (_("Report a Problem"));

            var action_area = (Gtk.Box) get_action_area ();
            action_area.pack_end (help_button, false, false, 0);
            action_area.pack_start (bug_button, false, false, 0);
            action_area.pack_start (translate_button, false, false, 0);
            action_area.reorder_child (bug_button, 0);
            action_area.reorder_child (translate_button, 0);

            ((Gtk.ButtonBox) action_area).set_child_secondary (help_button, true);
            ((Gtk.ButtonBox) action_area).set_child_non_homogeneous (help_button, true);

            height_request = 282;

            show_all ();

            bug_button.clicked.connect (() => {
                activate_link (bug);
            });

            help_button.clicked.connect (() => {
                activate_link (help);
            });

            help_button.size_allocate.connect ((alloc) => {
                help_button.set_size_request (alloc.height, -1);
            });

            translate_button.clicked.connect (() => {
                activate_link (translate);
            });
        }
    }

    public extern void show_about_dialog (Gtk.Window *parent, string first, ...);
}
