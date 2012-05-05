// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*
 * Copyright (c) 2012 Granite Developers
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Tom Beckmann <tombeckmann@online.de>
 */

namespace Granite.Widgets {

    [CCode (cname="get_close_pixbuf")]
    internal extern Gdk.Pixbuf get_close_pixbuf ();

    public class DecoratedWindow : CompositedWindow {
        bool _show_close_button = true;
        public bool show_close_button {
            get {
                return _show_close_button;
            }
            set {
                _show_close_button = value;
                w = -1; h = -1; // get it to redraw the buffer
                Gtk.Allocation alloc;
                this.get_allocation (out alloc);
                this.size_allocate (alloc);

                this.queue_draw ();
            }
        }

        protected Gtk.Box box { get; private set; }
        protected Gtk.Window draw_ref { get; private set; }
        protected Gdk.Pixbuf close_img;

        private Granite.Drawing.BufferSurface buffer;

        private const int SHADOW_BLUR = 15;
        private const int SHADOW_X    = 0;
        private const int SHADOW_Y    = 0;
 
        private const int CLOSE_BUTTON_X = -3;
        private const int CLOSE_BUTTON_Y = -3;

        private const double SHADOW_ALPHA = 0.3;

        private int w = -1;
        private int h = -1;

        public DecoratedWindow () {
            this.resizable = true;
            this.has_resize_grip = false;
            this.window_position = Gtk.WindowPosition.CENTER_ON_PARENT;

            this.box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            this.draw_ref = new Gtk.Window ();

            close_img = get_close_pixbuf ();

            this.size_allocate.connect (on_size_allocate);
            this.draw.connect (draw_widget);

            this.add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.POINTER_MOTION_MASK);

            this.motion_notify_event.connect (on_motion_notify);
            this.button_press_event.connect (on_button_press);

            base.add (this.box);
            this.box.margin = SHADOW_BLUR;
        }

        public new void add (Gtk.Widget w) {
            this.box.pack_start (w);
        }

        public new void remove (Gtk.Widget w) {
            this.box.remove (w);
        }

        private bool draw_widget (Cairo.Context ctx) {
            ctx.set_source_surface (this.buffer.surface, 0, 0);
            ctx.paint ();
            return false;
        }
        
        private void on_size_allocate (Gtk.Allocation alloc) {
                if (alloc.width == w && h == alloc.height)
                    return;

                this.w = alloc.width;
                this.h = alloc.height;

                this.buffer = new Granite.Drawing.BufferSurface (w, h);

                int x = SHADOW_BLUR + SHADOW_X;
                int y = SHADOW_BLUR + SHADOW_Y;
                int width  = w - 2 * SHADOW_BLUR + SHADOW_X;
                int height = h - 2 * SHADOW_BLUR + SHADOW_Y;

                this.buffer.context.rectangle (x, y, width, height);

                this.buffer.context.set_source_rgba (0, 0, 0, SHADOW_ALPHA);
                this.buffer.context.fill ();
                this.buffer.exponential_blur (SHADOW_BLUR / 2);

                draw_ref.get_style_context ().render_activity (this.buffer.context, x, y, width, height);

                if (this.show_close_button) {
                    Gdk.cairo_set_source_pixbuf (this.buffer.context, close_img, SHADOW_BLUR / 2 + CLOSE_BUTTON_X,
                                                 SHADOW_BLUR / 2 + CLOSE_BUTTON_Y);
                    this.buffer.context.paint ();
                }
        }

        private bool on_motion_notify (Gdk.EventMotion e) {
            if (show_close_button && coords_over_close_button (e.x, e.y))
                this.get_window ().set_cursor (new Gdk.Cursor (Gdk.CursorType.HAND1));
            else
                this.get_window ().set_cursor (null);

            return true;
        }

        private bool on_button_press (Gdk.EventButton e) {
                if (coords_over_close_button (e.x, e.y))
                    this.destroy ();
                else
                    this.begin_move_drag ((int)e.button, (int)e.x_root, (int)e.y_root, e.time);

                return true;
        }

        private bool coords_over_close_button (double x, double y) {
            return x > (SHADOW_BLUR / 2 + CLOSE_BUTTON_X) &&
                    x < (close_img.get_width () + SHADOW_BLUR / 2 + CLOSE_BUTTON_X) &&
                    y > (SHADOW_BLUR / 2 + CLOSE_BUTTON_Y) &&
                    y < (close_img.get_height () + SHADOW_BLUR / 2 + CLOSE_BUTTON_Y);
        }
    }

    public class LightWindow : DecoratedWindow {

        public const string LIGHT_WINDOW_STYLE = """
            .content-view-window {
                background-image:none;
                background-color:@bg_color;

                border-radius: 6px;

                border-width:1px;
                border-style: solid;
                border-color: alpha (#000, 0.25);
            }
        """;

        public LightWindow () {
            var css = new Gtk.CssProvider ();

            try {
                css.load_from_data (LIGHT_WINDOW_STYLE, -1);
            } catch (Error e) { warning (e.message); }

            box.get_style_context ().add_class (STYLE_CLASS_CONTENT_VIEW);

            draw_ref.get_style_context ().add_class ("content-view-window");
            draw_ref.get_style_context ().add_provider (css, Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK);
        }
    }

    public class DarkWindow : DecoratedWindow {

        public DarkWindow () {
            box.get_style_context ().add_class ("dark-content-view");
            draw_ref.get_style_context ().add_class ("dark-content-view-window");
        }
    }

}

