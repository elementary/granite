namespace Granite.Widgets {

    public class OverlayBar : Gtk.EventBox {

        private const string FALLBACK_THEME = """
       .files-overlay-bar {
           background-color: @bg_color;
           border-radius: 3px 3px 0 0;
           padding: 3px 6px 3px 6px;
           margin: 1px;
           border-style: solid;
           border-width: 1px;
           border-color: darker (@bg_color);
       }""";

        public Gtk.Label status;

        public OverlayBar () {
            visible_window = false;

            status = new Gtk.Label (null);
            status.set_ellipsize (Pango.EllipsizeMode.END);
            add (status);
            status.show ();

            set_halign (Gtk.Align.END);
            set_valign (Gtk.Align.END);

            set_default_style ();

            var ctx = get_style_context ();
            ctx.changed.connect (update_spacing);
            ctx.changed.connect_after (queue_resize);

            update_spacing ();
        }

        public override void parent_set (Gtk.Widget? old_parent) {
            Gtk.Widget parent = get_parent ();

            if (old_parent != null)
                old_parent.enter_notify_event.disconnect (enter_notify_callback);
            if (parent != null)
                parent.enter_notify_event.connect (enter_notify_callback);
        }

        public override bool draw (Cairo.Context cr) {
            var ctx = get_style_context ();
            ctx.render_background (cr, 0, 0, get_allocated_width (), get_allocated_height ());
            ctx.render_frame (cr, 0, 0, get_allocated_width (), get_allocated_height ());
            return base.draw (cr);
        }

        public override Gtk.SizeRequestMode get_request_mode () {
            return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
        }

        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            Gtk.Requisition label_min_size, label_natural_size;
            status.get_preferred_size (out label_min_size, out label_natural_size);

            var ctx = get_style_context ();
            var state = ctx.get_state ();
            var border = ctx.get_border (state);

            int extra_allocation = border.left + border.right;
            minimum_width = extra_allocation + label_min_size.width;
            natural_width = extra_allocation + label_natural_size.width;
        }

        public override void get_preferred_height_for_width (int width, out int minimum_height,
                                                             out int natural_height) {
            Gtk.Requisition label_min_size, label_natural_size;
            status.get_preferred_size (out label_min_size, out label_natural_size);

            var ctx = get_style_context ();
            var state = ctx.get_state ();
            var border = ctx.get_border (state);

            int extra_allocation = border.top + border.bottom;
            minimum_height = extra_allocation + label_min_size.height;
            natural_height = extra_allocation + label_natural_size.height;
        }

        private void update_spacing () {
            var ctx = get_style_context ();
            var state = ctx.get_state ();

            var padding = ctx.get_padding (state);
            status.margin_top = padding.top;
            status.margin_bottom = padding.bottom;
            status.margin_left = padding.left;
            status.margin_right = padding.right;

            var margin = ctx.get_margin (state);
            margin_top = margin.top;
            margin_bottom = margin.bottom;
            margin_left = margin.left;
            margin_right = margin.right;
        }

        private void set_default_style () {
            int priority = Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK;
            Granite.Widgets.Utils.set_theming (this, FALLBACK_THEME, "files-overlay-bar", priority);
        }

        private bool enter_notify_callback (Gdk.EventCrossing event) {
            if (get_halign () == Gtk.Align.START)
                set_halign (Gtk.Align.END);
            else
                set_halign (Gtk.Align.START);

            return false;
        }
    }
}
