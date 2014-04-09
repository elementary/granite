/***
    Copyright (C) 2011-2013 Granite Developers

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.

    Authored by: Tom Beckmann <tom@elementaryos.org>
***/

namespace Granite.Widgets {

    /**
     * This class is a standard decorated window.
     */
    [Deprecated (replacement = "Gtk.Dialog", since = "0.3")]
    public class DecoratedWindow : CompositedWindow {

        const string DECORATED_WINDOW_FALLBACK_STYLESHEET = """
            .decorated-window {
                border-style:solid;
                border-color:alpha (#000, 0.35);
                background-image:none;
                background-color:@bg_color;
                border-radius:6px;
            }
        """;

        // Currently not overridable
        const string DECORATED_WINDOW_STYLESHEET = """
            .decorated-window { border-width:1px; }
        """;

        /**
         * This method sets the given window to the decorated window style
         *
         * @param ref_window window to set style to
         */
        public static void set_default_theming (Gtk.Window ref_window) {
            Utils.set_theming (ref_window, DECORATED_WINDOW_STYLESHEET,
                               StyleClass.DECORATED_WINDOW,
                               Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            Utils.set_theming (ref_window, DECORATED_WINDOW_FALLBACK_STYLESHEET,
                               StyleClass.DECORATED_WINDOW,
                               Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK);
        }

        /**
         * Whether to show the window title
         */
        public bool show_title { get; set; default = true; }

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

        private Gtk.Label _title;

        /**
         * This creates a new DecoratedWindow
         *
         * @param title title to set window's title to
         * @param window_style style to set window to
         * @param content_style style to set content to
         */
        public DecoratedWindow (string title = "", string? window_style = null, string? content_style = null) {
            this.resizable = false;
            this.has_resize_grip = false;
            this.window_position = Gtk.WindowPosition.CENTER_ON_PARENT;

            this.close_img = Utils.get_close_pixbuf ();

            this._title = new Gtk.Label (null);
            this._title.halign = Gtk.Align.CENTER;
            this._title.hexpand = false;
            this._title.ellipsize = Pango.EllipsizeMode.MIDDLE;
            this._title.single_line_mode = true;
            this._title.margin = 6;
            this._title.margin_left = this._title.margin_right = 6 + this.close_img.get_width () / 3;
            var attr = new Pango.AttrList ();
            attr.insert (new Pango.AttrFontDesc (Pango.FontDescription.from_string ("bold")));
            this._title.attributes = attr;

            this.notify["title"].connect (update_titlebar_label);
            this.notify["show-title"].connect (update_titlebar_label);

            this.notify["deletable"].connect ( () => {
                w = -1; h = -1; // get it to redraw the buffer
                this.queue_resize ();
                this.queue_draw ();
            });

            this.title = title;
            this.deletable = true;

            this.box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.box.margin = SHADOW_BLUR + 1; // SHADOW_BLUR + border_width

            this.draw_ref = new Gtk.Window ();

            // set theming
            set_default_theming (this.draw_ref);

            // extra theming
            if (window_style != null && window_style != "")
                this.draw_ref.get_style_context ().add_class (window_style);

            if (content_style != null && content_style != "")
                this.box.get_style_context ().add_class (content_style);

            this.box.pack_start (this._title, false);
            base.add (this.box);

            this.add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                             Gdk.EventMask.BUTTON_RELEASE_MASK |
                             Gdk.EventMask.POINTER_MOTION_MASK);
            this.motion_notify_event.connect (on_motion_notify);
            this.delete_event.connect_after (on_delete_event);
            this.size_allocate.connect (on_size_allocate);
            this.draw.connect (draw_widget);
        }

        /**
         * This method adds new item to window
         *
         * @param w widget to add to window
         */
        public new void add (Gtk.Widget w) {
            this.box.pack_start (w, true, true);
        }

        /**
         * This method removes item to window
         *
         * @param w widget to remove from window
         */
        public new void remove (Gtk.Widget w) {
            this.box.remove (w);
        }

        private void update_titlebar_label () {
            // If the show_title property is false, we show an empty titlebar
            // instead of hiding the _title label. This is important since the titlebar
            // sets a sane vertical padding at the top of the window.
            this._title.label = (show_title) ? this.title : "";
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

                draw_ref.get_style_context ().render_activity (this.buffer.context,
                                                               x, y, width, height);

                if (this.deletable) {
                    Gdk.cairo_set_source_pixbuf (this.buffer.context, close_img,
                                                 SHADOW_BLUR / 2 + CLOSE_BUTTON_X,
                                                 SHADOW_BLUR / 2 + CLOSE_BUTTON_Y);
                    this.buffer.context.paint ();
                }
        }

        private bool on_motion_notify (Gdk.EventMotion e) {
            if (coords_over_close_button (e.x_root, e.y_root))
                this.get_window ().set_cursor (new Gdk.Cursor (Gdk.CursorType.HAND1));
            else
                this.get_window ().set_cursor (null);

            return true;
        }

        public override bool button_press_event (Gdk.EventButton e) {
            if (coords_over_close_button (e.x_root, e.y_root))
                return true;
            if (e.type == Gdk.EventType.BUTTON_PRESS && e.button == 1)
                this.begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);

            return base.button_press_event (e);
        }

        public override bool button_release_event (Gdk.EventButton e) {
            bool on_close_button = coords_over_close_button (e.x_root, e.y_root);
            if (on_close_button) {
                var event = (Gdk.Event*) (&e);
                this.delete_event (event->any);
            }

            return on_close_button;
        }
        
        public override bool key_press_event (Gdk.EventKey event) {
            if (event.keyval == Gdk.Key.Escape) {
                this.delete_event (((Gdk.Event*) (&event))->any);
                return true;
            }
            
            return base.key_press_event (event);
        }

        private bool coords_over_close_button (double x_root, double y_root) {
            int w_x, w_y;
            this.get_position (out w_x, out w_y);

            int x = (int) x_root - w_x;
            int y = (int) y_root - w_y;
        
            return this.deletable &&
                    x > (SHADOW_BLUR / 2 + CLOSE_BUTTON_X) &&
                    x < (close_img.get_width () + SHADOW_BLUR / 2 + CLOSE_BUTTON_X) &&
                    y > (SHADOW_BLUR / 2 + CLOSE_BUTTON_Y) &&
                    y < (close_img.get_height () + SHADOW_BLUR / 2 + CLOSE_BUTTON_Y);
        }

        private bool on_delete_event (Gdk.EventAny event) {
            if (this.deletable)
                this.destroy ();

            return false;
        }
    }
}
