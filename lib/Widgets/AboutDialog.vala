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

        private Granite.Drawing.BufferSurface buffer;

        private const string HELP_BUTTON_STYLESHEET = """
            .help_button {
                border-radius: 200px;
            }
        """;

        private const string WINDOW_STYLESHEET = """
            .window {
                border-radius: 6px 6px 0px 0px;
                border-color: alpha (#000, 0.2);
                border-width: 1px;
                border-style: solid;
                
                background-color: rgba (0, 0, 0, 0.0);
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

            var window_style_provider = new Gtk.CssProvider ();
            try {
                window_style_provider.load_from_data (WINDOW_STYLESHEET, -1);
            } catch (Error e) { warning (e.message); }
            this.get_style_context ().add_provider (window_style_provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
            this.get_style_context ().add_class ("window");
            this.decorated = false;
            this.set_visual (this.get_screen ().get_rgba_visual ());
            this.app_paintable = true;
            this.draw.connect ( () => {
                
                return false;
            });

            action_area.get_style_context ().add_class ("content-view");
            action_area.margin = 12;
            this.get_content_area ().margin = 12;

            /* help button */
            help_button = new Button.with_label("?");
            help_button.get_style_context ().add_class ("help_button");
            help_button.get_style_context ().add_provider (help_button_style_provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
            help_button.halign = Gtk.Align.CENTER;
            help_button.pressed.connect(() => { activate_link(help); });

            /* Circular help button */
            help_button.size_allocate.connect ( (alloc) => {
            	help_button.set_size_request (alloc.height, -1);
            });

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

            show_all ();

            var w = -1; var h = -1; var SHADOW = 15;
            this.size_allocate.connect ( () => {
                if (this.get_allocated_width () == w && this.get_allocated_height () != h)
                    return;
                w = this.get_allocated_width ();
                h = this.get_allocated_height ();
                
                this.buffer = new Granite.Drawing.BufferSurface (w, h);
                this.buffer.context.rectangle (SHADOW, SHADOW, this.get_allocated_width () - SHADOW*2, this.get_allocated_height ()-SHADOW*2);
                this.buffer.context.set_source_rgba (0, 0, 0, 0.7);
                this.buffer.context.fill ();
                this.buffer.exponential_blur (SHADOW/2);
                
                Granite.Drawing.Utilities.cairo_rounded_rectangle (this.buffer.context, SHADOW, SHADOW, w-SHADOW*2, h-SHADOW*2, 5);
                this.buffer.context.set_source_rgba (1, 1, 1, 1);
                this.buffer.context.fill_preserve ();
                this.buffer.context.set_source_rgba (0, 0, 0, 0.4);
                this.buffer.context.set_line_width (1);
                this.buffer.context.stroke ();
            });
            /*draw the buffer*/
            this.draw.connect ( (ctx) => {
                if (buffer == null)
                    return false;
                ctx.set_source_surface (this.buffer.surface, 0, 0);
                ctx.paint ();
                
                return false;
            });
        }
    }

    public extern void show_about_dialog (Gtk.Window *parent, ...);
}

