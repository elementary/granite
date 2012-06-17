

namespace Granite.Widgets {
    
    [CCode (cname="get_close_pixbuf")]
    public extern Gdk.Pixbuf get_close_pixbuf ();
    
    public class LightWindow : Granite.Widgets.CompositedWindow {
        
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
        
        bool _show_close_button = true;
        public bool show_close_button {
            get { return _show_close_button; }
            set {
                _show_close_button = value;
                w = -1; h = -1; //get it to redraw the buffer
                Gtk.Allocation alloc;
                this.get_allocation (out alloc);
                this.size_allocate (alloc);
                
                this.queue_draw ();
            }
        }
        
        Granite.Drawing.BufferSurface buffer;
        
        Gtk.Box box;
        
        int shadow_blur = 15;
        int shadow_x    = 0;
        int shadow_y    = 0;
        double shadow_alpha = 0.3;
        
        int close_button_x = -3;
        int close_button_y = -3;
        
        int w = -1; int h = -1;
        
        public LightWindow () {
            
            var css = new Gtk.CssProvider ();
            try {
                css.load_from_data (LIGHT_WINDOW_STYLE, -1);
            } catch (Error e) { warning (e.message); }
            
            this.resizable = true;
            this.has_resize_grip = false;
            
            this.box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.box.get_style_context ().add_class ("content-view");
            
            var draw_ref = new Gtk.Window ();
            draw_ref.get_style_context ().add_class ("content-view-window");
            draw_ref.get_style_context ().add_provider (css, Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK);
            
            var close_img = get_close_pixbuf ();
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
                
                if (this.show_close_button) {
                    Gdk.cairo_set_source_pixbuf (this.buffer.context, close_img, shadow_blur/2 + close_button_x, 
                        shadow_blur/2 + close_button_y);
                    this.buffer.context.paint ();
                }
            });
            
            this.draw.connect ( (ctx) => {
                ctx.set_source_surface (this.buffer.surface, 0, 0);
                ctx.paint ();
                return false;
            });
            
            this.add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.POINTER_MOTION_MASK);
            this.button_press_event.connect ( (e) => {
                if (this.show_close_button &&
                    e.x > (shadow_blur/2+close_button_x) && 
                    e.x < (close_img.get_width  () + shadow_blur/2+close_button_x) &&
                    e.y > (shadow_blur/2+close_button_y) && 
                    e.y < (close_img.get_height () + shadow_blur/2+close_button_y)) {
                    this.destroy ();
                } else {
                    this.begin_move_drag ((int)e.button, (int)e.x_root, (int)e.y_root, e.time);
                }
                return true;
            });
            this.motion_notify_event.connect ( (e) => {
                if (this.show_close_button &&
                    e.x > (shadow_blur/2+close_button_x) && 
                    e.x < (close_img.get_width  () + shadow_blur/2+close_button_x) &&
                    e.y > (shadow_blur/2+close_button_y) && 
                    e.y < (close_img.get_height () + shadow_blur/2+close_button_y)) {
                    this.get_window ().set_cursor (new Gdk.Cursor (Gdk.CursorType.HAND1));
                } else {
                    this.get_window ().set_cursor (null);
                }
                return true;
            });
            
            base.add (this.box);
            this.box.margin = shadow_blur;
        }
        
        public new void add (Gtk.Widget w) {
            this.box.pack_start (w);
        }
        public new void remove (Gtk.Widget w) {
            this.box.remove (w);
        }
        
    }
}
