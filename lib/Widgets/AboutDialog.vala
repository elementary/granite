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
        
        int shadow_blur = 15;
        int shadow_x    = 0;
        int shadow_y    = 2;
        double shadow_alpha = 0.3;
        
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
                warning ("%s. Some widgets will not look as intended", e.message);
            }

            var draw_ref = new Gtk.Window ();
            draw_ref.get_style_context ().add_class (STYLE_CLASS_CONTENT_VIEW_WINDOW);
            DecoratedWindow.set_default_theming (draw_ref, action_area);
            action_area.get_style_context ().add_class (STYLE_CLASS_CONTENT_VIEW);

            this.decorated = false;
            this.set_visual (this.get_screen ().get_rgba_visual ());
            this.app_paintable = true;

            action_area.margin = 4;
            action_area.margin_bottom = 8;
            this.get_content_area ().margin = 10;
            this.get_content_area ().margin_top = 27;
            this.get_content_area ().margin_bottom = 3;

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
            translate_button = new Button.with_label(_("Translate this app"));
            translate_button.pressed.connect ( () => { activate_link(translate); });
            action_area.pack_start (translate_button, false, false, 0);

            /* bug button */
            bug_button = new Button.with_label (_("Report a problem"));
            bug_button.pressed.connect (() => { activate_link(bug); });
            action_area.pack_start (bug_button, false, false, 0);

            action_area.reorder_child (bug_button, 0);
            action_area.reorder_child (translate_button, 0);

            show_all ();

            this.height_request = 282;
            
            var w = -1; var h = -1;
            this.size_allocate.connect ( () => {
                if (this.get_allocated_width () == w && this.get_allocated_height () == h)
                    return;
                w = this.get_allocated_width ();
                h = this.get_allocated_height ();
                
                this.buffer = new Granite.Drawing.BufferSurface (w, h);
                
                this.buffer.context.rectangle (shadow_blur + shadow_x, 
                    shadow_blur + shadow_y, w - shadow_blur*2 + shadow_x, h - shadow_blur*2 + shadow_y);
                this.buffer.context.set_source_rgba (0, 0, 0, shadow_alpha);
                this.buffer.context.fill ();
                this.buffer.exponential_blur (shadow_blur / 2);
                
                draw_ref.get_style_context ().render_activity (this.buffer.context, shadow_blur + shadow_x, 
                    shadow_blur + shadow_y, w - shadow_blur*2 + shadow_x, h - shadow_blur*2 + shadow_y);
                
            });
            /*draw the buffer*/
            this.draw.connect ( (ctx) => {
                if (buffer == null)
                    return false;
                
                ctx.set_operator (Cairo.Operator.SOURCE);
                ctx.rectangle (0, 0, w, h);
                ctx.set_source_rgba (0, 0, 0, 0);
                ctx.fill ();
                
                ctx.set_source_surface (this.buffer.surface, 0, 0);
                ctx.paint ();
                
                return false;
            });
            /*allow moving the window*/
            this.button_press_event.connect ( (e) => {
                if (e.button == 1) {
                    this.begin_move_drag ((int)e.button, (int)e.x_root, (int)e.y_root, e.time);
                    return true;
                }
                return false;
            });
        }
    }

    public extern void show_about_dialog (Gtk.Window *parent, ...);
}

