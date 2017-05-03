
namespace Granite.Widgets {
    private class IndicatorBar : Gtk.DrawingArea {
        private uint MARGIN = 4;

        private double _fill = 0;
        public double fill {
            get {
                return _fill;
            }

            set {
                _fill = value;

                queue_draw ();
            }
        }

        public IndicatorBar () {
            Object ();
        }

        construct {
            hexpand = true;

            set_size_request (-1, 4);
        }


        public override bool draw (Cairo.Context context) {
            var width = get_allocated_width () - 2*MARGIN;
            var fill_width = fill * width;
            var height = get_allocated_height ();
            var x = MARGIN;
            var y = 0;

            var style_context = get_style_context ();
            style_context.render_background (context, x, y, width, height);
            style_context.add_class ("fill");
            style_context.render_background (context, x, y, fill_width, height);
            style_context.remove_class ("fill");
            style_context.render_frame (context,  x, y, width, height);

            return Gdk.EVENT_STOP;
        }        
    }
}