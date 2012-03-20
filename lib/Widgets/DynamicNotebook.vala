using Granite.Widgets;

using Gtk;


public class Granite.Widgets.Tab : Object {
    public string text;
    public  Gdk.Pixbuf? pixbuf { set; get; default = null; }

    internal Gtk.StateFlags close_button = Gtk.StateFlags.NORMAL;
    internal Gtk.StateFlags state = Gtk.StateFlags.NORMAL;
    internal double offset = 0.0;
    internal double draw_offset = 0.0;
    internal double drag_origin = 0.0;
    internal  bool removed = false;
    double initial_offset = 1.0;
    double initial_draw_offset = 0.0;
    public bool loading { set; get; default = false;}
    internal Cairo.Surface surface;

    public Gtk.Widget widget;

    public signal void need_redraw ();
    public signal void need_recache ();

    public bool is_animated () {

        bool return_value =  (!removed && initial_offset != 1.0) ||
                             (drag_origin == 0.0 && initial_draw_offset != 0.0) ||
                             (removed && initial_offset != 0.0);
        return return_value;
    }

    public Tab (string text, string? stock_id = null, bool loading = false) {
        this.text = text;
        if (stock_id != null) pixbuf = Gtk.IconTheme.get_default ().load_icon (stock_id, 16, 0);
        this.loading = loading;
        notify["pixbuf"].connect ( () => { need_recache (); });
    }

    internal void start_animation () {
        initial_offset = offset;
        initial_draw_offset = draw_offset;
    }

    internal void do_animation (double x) {
        x = (double)Math.sin ((double)x * Math.PI/2);

        draw_offset = initial_draw_offset * (1.0 - x);
        if (!removed)
            offset = initial_offset * (1.0 - x) + 1.0 * x;
        else
            offset = initial_offset * (1.0 - x);
    }

    internal void select () {
        state = Gtk.StateFlags.ACTIVE;
    }
    
    internal void unselect () {
        state = Gtk.StateFlags.NORMAL;
    }
    
    internal void hover () {
        if (state == Gtk.StateFlags.NORMAL)
            state = Gtk.StateFlags.PRELIGHT;
    }

    internal void shrunk () {
        offset = 0.0;
    }
    
    internal bool draw_with_cache (Cairo.Context cr, double x) {
        if (offset == 1.0 && surface != null && state == Gtk.StateFlags.NORMAL &&
            close_button == Gtk.StateFlags.NORMAL && !loading) {
            cr.set_source_surface (surface, x + draw_offset, 0);
            cr.paint ();
            return true;
        }
        return false;
    }
}


internal class Granite.Widgets.Tabs : Gtk.EventBox {

    Gtk.StyleContext tab_context;
    Gtk.StyleContext label_context;
    Gtk.StyleContext button_context;
    
    internal Gee.ArrayList<Tab> tabs;
    internal static Gtk.CssProvider style_provider;
    private const string STYLESHEET_AMBIANCE = """
        .dynamic-notebook tab:active {
            background-color:#000;
            background-image: -gtk-gradient (linear, left bottom, left top,
                                     from (shade (@dark_bg_color, 0.96)),
                                     to (shade (@dark_bg_color, 1.4)));
        }
        .dynamic-notebook tab .dynamic-label:active {
            color: @dark_fg_color;
        }
        .dynamic-label {
            color: @fg_color;
        }
    """;
    private const string STYLESHEET_ADWAITA = """
        .dynamic-label {
            color: @fg_color;
        }
    """;
    internal const int style_priority = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION;

    Gdk.Pixbuf close_pixbuf;
    double scrolling = 0.0;

    const double radius = 5;
    const double max_width = 200;
    const double min_width = 120;
    double width = max_width;
    const double overlap = 3;
    const int close_size = 16;
    const double close_margin = 1;
    const double y = 5;
    const int shadow_size = 3;

    Gdk.EventMotion? saved_event_motion = null;

    Cairo.Surface left_surface;
    Cairo.Surface right_surface;
    Cairo.Pattern center_pattern;
    
    uint timeout_remove = -1;
    uint scroll_timeout = -1;
    uint timeout_anim = -1;

    int _page = 0;
    public int page {
        get {
            return _page;
        }
        set {
            if (_page != value) {
                tabs[_page].unselect ();
                _page = value;
                tabs[_page].select ();
                queue_draw ();
            }
        }
    }

    public Gtk.PositionType tab_position { set; get; default = Gtk.PositionType.BOTTOM; }
    public bool draw_unselected_background { set; get; default = true; }

    int start_dragging = -1;
    int spinner_count = 0;

    public signal void switch_page (Tab tab);
    public signal void page_removed (Tab tab);
    /**
     * Emitted when the user makes a double click on an empty space.
     **/
    public signal void need_new_tab ();

    public Tabs () {
        tabs = new Gee.ArrayList<Tab>();
        
        if (style_provider == null) {
            style_provider = new Gtk.CssProvider ();
            try {
                if (Gtk.Settings.get_default ().gtk_theme_name == "Ambiance") {
                    //style_provider.load_from_data (STYLESHEET_AMBIANCE, -1);
                }
                else if (Gtk.Settings.get_default ().gtk_theme_name == "Adwaita") {
                    style_provider.load_from_data (STYLESHEET_ADWAITA, -1);
                }
            } catch (Error e) {
                warning ("The tab bar will not look as intended: %s", e.message);
            }
        }

        try {
            close_pixbuf = Gtk.IconTheme.get_default ().load_icon ("gtk-close", close_size, 0);
        }
        catch (Error e) {
        }

        height_request = 35;
        width_request = (int)(2*max_width);
        
        /* Set up the StyleContexts */
        tab_context = new Gtk.StyleContext ();
        label_context = get_style_context ();;
        button_context = new Gtk.StyleContext ();
        
        var path =  get_style_context ().get_path ().copy ();

        var pos = path.append_type (typeof (Gtk.Notebook));
        path.iter_add_class (pos, "notebook");
        path.iter_add_class (pos, "dynamic-notebook");
        path.iter_add_region (pos, "tab", Gtk.RegionFlags.EVEN); /* for a tab */

        var path_label = path.copy ();
        pos = path_label.append_type (typeof (Gtk.Label));
        path_label.iter_add_class (pos, "dynamic-label"); /* for a label */

        var path_button = path.copy ();
        pos = path_label.append_type (typeof (Gtk.Button)); /* for a button */
        
        tab_context.set_path (path);
        label_context.set_path (path_label);
        button_context.set_path (path_button);
        
        get_style_context ().add_class ("dynamic-notebook");
        
        /* Add our nice provider... */
        get_style_context ().add_provider (style_provider, style_priority);
        tab_context.add_provider (style_provider, style_priority);
        //label_context.add_provider (style_provider, style_priority);
        button_context.add_provider (style_provider, style_priority);

        size_allocate.connect (on_size_allocate);

        add_events (Gdk.EventMask.POINTER_MOTION_MASK);

        Timeout.add (80, () => {
            foreach (var tab in tabs) {
                if(tab.loading) {
                    spinner_count++;
                    queue_draw ();
                    break;
                }
            }
            return true;
        });
    }

    public void add_tab (Tab tab) {
        tabs.add (tab);
        tab.need_redraw.connect (() => { queue_draw (); });
        tab.need_recache.connect (() => { cache_tab (tab); queue_draw (); });

        switch_page (tab);
        page = tabs.size -1;
        
        update_tab_size (get_allocated_width ());
        tab.shrunk ();
        launch_animations ();
    }

    public override bool draw (Cairo.Context cr) {
        double x = radius;

        /* First; the background */
        Gtk.render_background (get_style_context (), cr, 0, 0, get_allocated_width (), get_allocated_height ());
        
        /* Scroll */
        cr.translate (scrolling, 0);
        cr.save ();

        /* We have to save these tabs because we want them to be drawn on top of the other ones. */
        double x_selected = 0;
        Tab? tab_selected = null;
        double x_dragged = 0;
        Tab? tab_dragged = null;

        foreach (var tab in tabs) {
            if (tab.state != Gtk.StateFlags.ACTIVE && tabs.index_of (tab) != start_dragging) {
                draw_tab (cr, x, tab);
            }
            else if (tab.state == Gtk.StateFlags.ACTIVE) {
                x_selected = x;
                tab_selected = tab;
            }
            else {
                x_dragged = x;
                tab_dragged = tab;
            }
            x += width*tab.offset - overlap;
        }

        if (tab_selected != null) {
            draw_tab (cr, x_selected, tab_selected);
        }
        
        if (tab_dragged != null) {
            draw_tab (cr, x_dragged, tab_dragged);
        }

        return true;
    }

    void draw_tab (Cairo.Context cr, double x, Tab tab, bool use_cache = true) {
        double height = get_allocated_height () - y;
        double y_origin = tab_position == Gtk.PositionType.TOP ? 0 : y;
        
        if (!(use_cache && tab.draw_with_cache (cr, x - radius))) {
            if (width*tab.offset < 2*radius) /* Then it is too small */
                return;

            draw_tab_background (cr, x + tab.draw_offset, y_origin, width*tab.offset, height, radius, tab);
            draw_label (cr, x + tab.draw_offset, y_origin, height, tab.text, tab);
            draw_close_button (cr, x + tab.draw_offset, y_origin, height, tab);
            draw_pixbuf_icon (cr, x + tab.draw_offset, y_origin, height, tab);
            cr.restore ();
            cr.save ();
        }
    }

    void draw_pixbuf_icon (Cairo.Context cr, double x, double y, double height, Tab tab) {
        if (tab.loading)
            Gtk.paint_spinner (get_style (), cr, Gtk.StateType.ACTIVE, this, "",
                               spinner_count, (int)(x + width*tab.offset - overlap - close_margin - close_size),
                               (int)(y +  height /2 - close_size/2), close_size, close_size);
        else if (tab.pixbuf != null) {
            Gdk.cairo_set_source_pixbuf (cr, tab.pixbuf,
                                         (int)(x + width*tab.offset - overlap - close_margin - close_size),
                                         (int)(y +  height /2 - close_size/2));
            cr.paint ();
        }
    }

    void draw_close_button (Cairo.Context cr, double x, double y, double height, Tab tab) {
        if (tab.close_button == Gtk.StateFlags.PRELIGHT) {
            Gtk.render_background (button_context, cr,
                x + overlap, y + height/2 - (close_size + 2*close_margin)/2,
                close_size + 2*close_margin, close_size + 2*close_margin);
            Gtk.render_frame (button_context, cr,
                x + overlap, y + height/2 - (close_size + 2*close_margin)/2,
                close_size + 2*close_margin, close_size + 2*close_margin);
        }
        Gdk.cairo_set_source_pixbuf (cr, close_pixbuf, x + overlap + close_margin, y +  height /2 - close_size/2);
        cr.paint ();
    }

    void draw_label (Cairo.Context cr, double x, double y, double height, string text, Tab tab) {
        double left_padding = 5 + overlap + close_size + 2*close_margin;

        var layout = create_pango_layout (text);
        double layout_width = width - 2 * radius - 2* close_margin - close_size;
        /* Do we need to take into account the icon or the loading spinner? */
        if (tab.pixbuf != null || tab.loading) {
            layout_width -= 2*close_margin + close_size;
        }
        layout.set_width (Pango.units_from_double (layout_width));
        layout.set_ellipsize (Pango.EllipsizeMode.END);

        Pango.Rectangle extents;
        layout.get_extents (null, out extents);
        double layout_height = Pango.units_to_double (extents.height);

        label_context.set_state (tab.state);

        Gtk.render_layout (label_context, cr, x + left_padding, y + height/2 - layout_height/2, layout);
    }
    
    void update_tab_size (double alloc_width) {
        var old_width = width;
        width = double.min (double.max ((int)((alloc_width + (tabs.size - 1)*overlap - 2*radius)/tabs.size), min_width),
                            max_width);
        
        double offset = old_width/width;
        /* Let's create the new tab cache. */
        foreach (var tab in tabs) {
            cache_tab (tab);
            /* This is old_width/width, useful to have the tabs dynamically resized */
            tab.offset = offset;
        }
    }

    void cache_tab (Tab tab) {
        /* Reset some values */
        tab.offset = 1.0;
        var draw_offset = tab.draw_offset;
        var state = tab.state;
        var loading = tab.loading;
        tab.loading = false;
        tab.draw_offset = 0;
        tab.state = Gtk.StateFlags.NORMAL;

        var buf = new Granite.Drawing.BufferSurface ( (int)(width +2*radius), get_allocated_height ());
        draw_tab (buf.context, radius, tab, false /* don't use cache */);

        tab.surface = buf.surface;
        
        /* Restore the values */
        tab.state = state;
        tab.loading = loading;
        tab.draw_offset = draw_offset;
    }

    void on_size_allocate (Gtk.Allocation alloc) {
    
        var border_color = tab_context.get_border_color (Gtk.StateFlags.NORMAL);
        border_color.alpha -= 0.2;


        var buf = new Granite.Drawing.BufferSurface ( (int)(2*radius), (int)(alloc.height + 2*shadow_size));
        draw_tab_background_shape (buf.context, radius, shadow_size, 50, alloc.height - 5, radius, radius);
        Gdk.cairo_set_source_rgba (buf.context, border_color);
        buf.context.fill ();
        buf.gaussian_blur (shadow_size);
        left_surface = buf.surface;
        
        buf = new Granite.Drawing.BufferSurface ( (int)(2*radius), (int)(alloc.height + 2*shadow_size));
        draw_tab_background_shape (buf.context, -50 + radius, shadow_size, 50, alloc.height - 5, radius, radius);
        Gdk.cairo_set_source_rgba (buf.context, border_color);
        buf.context.fill ();
        buf.gaussian_blur (shadow_size);
        right_surface = buf.surface;
        
        buf = new Granite.Drawing.BufferSurface ( (int)(2), (int)(alloc.height + 2*shadow_size));
        double y = tab_position == Gtk.PositionType.TOP ? 0 : this.y;
        draw_tab_background_shape (buf.context, -25, y, 50, alloc.height - 5, radius, radius);
        Gdk.cairo_set_source_rgba (buf.context, border_color);
        buf.context.fill ();
        buf.gaussian_blur (shadow_size);

        center_pattern = new Cairo.Pattern.for_surface (buf.surface);
        center_pattern.set_extend (Cairo.Extend.REPEAT);
        
        update_tab_size (alloc.width);
    }

    void draw_tab_background (Cairo.Context cr, double x, double y, double width, double height,
                              double radius, Tab tab) {
        double border_size = 0.8;

        var border_color = tab_context.get_border_color (tab.state);
        if (draw_unselected_background || tab.state == Gtk.StateFlags.ACTIVE) {
            cr.set_source_surface (left_surface, x - radius, y - shadow_size);
            cr.paint ();
            cr.set_source_surface (right_surface, x + width - radius, y - shadow_size);
            cr.paint ();

            
            cr.rectangle (x + radius, y - shadow_size, width - 2*radius, height + 2*shadow_size);
            cr.set_source (center_pattern);
            cr.fill ();

            tab_context.set_state (tab.state);
            Gdk.cairo_set_source_rgba (cr, border_color);
            draw_tab_background_shape (cr, x, y, width, height, radius, radius);
            cr.fill ();
            
            double y_origin = y;
            if (tab_position == Gtk.PositionType.BOTTOM)
                y_origin += border_size;

            draw_tab_background_shape (cr, x + border_size, y_origin,
                width - 2*border_size, height - border_size, radius, radius - border_size);
            cr.set_source_rgba (1, 1, 1, 0.8);
            cr.clip ();
            Gtk.render_background ( tab_context, cr, x - radius, y - 3, width + 2* radius, height + 6);
        }
        else {
            /* Just a light gradient */
            cr.move_to (x + width - overlap/2, y);
            cr.line_to (x + width - overlap/2, y + height);
            var gradient = new Cairo.Pattern.linear (0, 0, 0, height);
            gradient.add_color_stop_rgba (0.0, border_color.red, border_color.green, border_color.blue, 0.0);
            gradient.add_color_stop_rgba (1.0, border_color.red, border_color.green, border_color.blue, 1.0);
            cr.set_source (gradient);
            cr.set_line_width (1.0);
            cr.stroke ();
        }
    }

    void draw_tab_background_shape (Cairo.Context cr, double x, double y, double width,
                         double height, double radius_t, double radius_l) {
        switch (tab_position) {
        case Gtk.PositionType.BOTTOM:
            cr.move_to (x - radius_l, y + height);
            cr.curve_to (x, y + height, x, y + height - radius_t, x, y + height - radius_t);
            cr.line_to (x, y + radius_t);
            cr.curve_to (x, y, x + radius_l, y, x + radius_l, y);
            cr.line_to (x + width - radius_l, y);
            cr.curve_to (x + width, y, x + width, y + radius_t, x + width, y + radius_t);
            cr.line_to (x + width, y + height - radius_t);
            cr.curve_to (x + width, y + height,
                         x + width + radius_l, y + height,
                         x + width + radius_l, y + height);
            break;

        case Gtk.PositionType.TOP:
            cr.move_to (x - radius_l, y);
            cr.curve_to (x, y, x, y + radius_t, x, y + radius_t);
            cr.line_to (x, y  + height - radius_t);
            cr.curve_to (x, y + height, x + radius_l, y + height, x + radius_l, y + height);
            cr.line_to (x + width - radius_l, y + height);
            cr.curve_to (x + width, y + height,
                         x + width, y + height - radius_t,
                         x + width, y + height - radius_t);
            cr.line_to (x + width, y + radius_t);
            cr.curve_to (x + width, y, x + width + radius_l, y, x + width + radius_l, y);
            break;
        }
    }

    public override bool scroll_event (Gdk.EventScroll event) {
        Source.remove (scroll_timeout);
        double impulse = 0.0;
        double step = 0.1;
        if (event.direction == Gdk.ScrollDirection.DOWN) {
            step = -step;
        }
        double start = scrolling;
        scroll_timeout = Timeout.add (30, () => {
            impulse += step;
            double dt = Math.sin ((impulse) * Math.PI/2);
            scrolling = double.min (double.max (-(tabs.size * (width - overlap) + 2*radius - get_allocated_width ()), start -  200*dt), 0);
            queue_draw ();

            if(impulse > 1.0 || impulse < -1.0)
                return false;
            return true;
        });
        return true;
    }

    public override bool leave_notify_event (Gdk.EventCrossing event) {
        foreach (var tab in tabs) {
            if (tab.state != Gtk.StateFlags.ACTIVE)
                tab.state = Gtk.StateFlags.NORMAL;
            tab.close_button = Gtk.StateFlags.NORMAL;
        }
        saved_event_motion = null;
        queue_draw ();
        return true;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        event.x -= radius + scrolling;
        if (event.button == 1) {
            start_dragging = (int)(event.x/(width - overlap));
            if (start_dragging >= tabs.size) {
                start_dragging = -1;
                /* click on an empty space */
                if (event.type == Gdk.EventType.2BUTTON_PRESS)
                    need_new_tab ();
            }
            else {
                tabs[start_dragging].drag_origin = event.x - start_dragging * (width - overlap);
            }
        }

        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        Tab? tab_removed = null;
        foreach (var tab in tabs) {
            if (tab.removed) tab_removed = tab;
        }
        if (tab_removed != null) tabs.remove (tab_removed);

        event.x -= radius + scrolling;

        if (event.button == 1) { /* It is a left click */
            /* we select the good one */
            int n_tab = (int)(event.x/(width - overlap));
            if (n_tab < tabs.size) {
                /* we unselect all tabs */
                foreach (var tab in tabs) {
                    tab.state = Gtk.StateFlags.NORMAL;
                }
                tabs[n_tab].select ();

                /* Let's see of it is on the close button */
                double offset = event.x - n_tab * (width - overlap) - overlap;
                if (0 < offset < close_margin*2 + close_size) { /* then it is a click on the close_button */
                    tabs[n_tab].state = Gtk.StateFlags.NORMAL;
                    tabs[n_tab].removed = true;
                    tabs[n_tab].offset = 1.0;
                    launch_animations ();
                    if (page == n_tab)
                        page--;
                    page_removed (tabs[n_tab]);
                    tabs[page].select ();
                }
                else
                    page = n_tab;
                switch_page (tabs[page]);
            }
        }
        else if (event.button == 2) {
            int n_tab = (int)(event.x/(width - overlap));
            if (n_tab < tabs.size && n_tab >= 0) {
                tabs[n_tab].unselect ();
                tabs[n_tab].removed = true;
                tabs[n_tab].offset = 1.0;
                launch_animations ();
                if (page == n_tab)
                    page--;
                tabs[page].select ();
                page_removed (tabs[n_tab]);
                switch_page (tabs[page]);
            }
        }
        if (start_dragging != -1) {
            var tab = tabs[start_dragging];
            tab.drag_origin = 0.0;
            launch_animations ();
        }
        start_dragging = -1;
        queue_draw ();
        return true;
    }

    void launch_animations () {
        Source.remove (timeout_anim);
        
        foreach (var tab in tabs) {
            tab.start_animation ();
        }
        double dt = 0.0;
        timeout_anim = Timeout.add (35, () => {
            bool need_continue = true;
            dt += 0.2;
            if (dt >= 1.0) {
                dt = 1.0;
                need_continue = false;
            }
            Tab? tab_to_remove = null;
            foreach (var tab in tabs) {
                bool tab_animated = tab.is_animated ();
                if (tab_animated)
                    tab.do_animation (dt);
                if (tab.removed) {
                    tab_to_remove = tab;
                }
            }
            if (!need_continue && tab_to_remove != null) {
                remove_tab (tab_to_remove);
            }

            if (!need_continue && saved_event_motion != null) {
                motion_notify_event (saved_event_motion);
            }

            queue_draw ();
            return need_continue;
        });
    }

    void remove_tab (Tab tab) {
        int n_tab = tabs.index_of (tab);
        tabs.remove (tab);
        if (_page >= n_tab)
            _page--;
        Source.remove (timeout_remove);
        timeout_remove = Timeout.add (2000, () => {
            update_tab_size (get_allocated_width ());
            launch_animations ();
            timeout_remove = -1;
            return false;
        });
    }
    
    public override bool motion_notify_event (Gdk.EventMotion event) {
        event.x -= radius + scrolling;
        bool need_draw = false;

        if (start_dragging != -1) {
            need_draw = true;
            tabs[start_dragging].draw_offset = -(tabs[start_dragging].drag_origin +
                                                 start_dragging * (width - overlap) - event.x);
            if (tabs[start_dragging].draw_offset < - width/2 && start_dragging > 0) {
                var tab = tabs[start_dragging];
                tabs[start_dragging] = tabs[start_dragging - 1];
                var old_tab = tabs[start_dragging];
                start_dragging --;
                tabs[start_dragging] = tab;
                tabs[start_dragging].draw_offset = -(tabs[start_dragging].drag_origin +
                                                     start_dragging * (width - overlap) - event.x);
                old_tab.draw_offset = - width + overlap;
                launch_animations ();
            }
            else if (tabs[start_dragging].draw_offset > width/2 && start_dragging < tabs.size - 1) {
                var tab = tabs[start_dragging];
                tabs[start_dragging] = tabs[start_dragging + 1];
                var old_tab = tabs[start_dragging];
                start_dragging ++;
                tabs[start_dragging] = tab;
                tabs[start_dragging].draw_offset = -(tabs[start_dragging].drag_origin +
                                                     start_dragging * (width - overlap) - event.x);
                old_tab.draw_offset = width - overlap;
                launch_animations ();
            }
        }
        else {
            int n_tab = (int)(event.x/(width - overlap));
            
            foreach (var tab in tabs) {
                tab.close_button = Gtk.StateFlags.NORMAL;
                if (tab.state != Gtk.StateFlags.ACTIVE && tab.state != Gtk.StateFlags.NORMAL) {
                    tab.state = Gtk.StateFlags.NORMAL;
                    need_draw = true;
                }
            }

            if (n_tab < tabs.size) {

                double offset = event.x - n_tab * (width - overlap) - overlap;
                if (0 < offset < close_margin *2 + close_size &&
                    get_allocated_height ()/2 - close_size/2 - close_margin < event.y - y <
                    get_allocated_height ()/2 + close_size/2 + close_margin) {
                    tabs[n_tab].close_button = Gtk.StateFlags.PRELIGHT;
                }
                tabs[n_tab].hover ();
                need_draw = true;
            }
        }

        if (need_draw)
            queue_draw ();

        event.x += radius + scrolling;
        saved_event_motion = event;


        return true;
    }
}

public class Granite.Widgets.DynamicNotebook : Gtk.Grid {
    Granite.Widgets.Tabs tabs;
    public signal void add_button_clicked ();
    public signal void new_tab_created (Tab tab);

    public signal void switch_page (Widget page, uint num);
    public signal void page_added (Widget page, uint num);
    public signal void page_removed (Widget page, uint num);

    public int page { set {
        /* Hide the old one */
        tabs.tabs[tabs.page].widget.set_child_visible (false);
        tabs.page = value;
        /* Show the new one */
        tabs.tabs[tabs.page].widget.set_child_visible (true);
        show_all ();
    } get { return tabs.page; } }

    Gtk.EventBox add_eventbox;
    Gtk.Button add_button;
    public DynamicNotebook () {
        add_eventbox = new Gtk.EventBox ();
        add_button = new Gtk.Button();
        add_button.set_image (new Gtk.Image.from_pixbuf (Gtk.IconTheme.get_default ().load_icon ("add", 16, 0)));
        add_button.set_relief (Gtk.ReliefStyle.NONE);
        add_eventbox.add (add_button);
        add_eventbox.get_style_context ().add_class ("dynamic-notebook");
        add_eventbox.get_style_context ().add_provider (Tabs.style_provider, Tabs.style_priority);
        add_button.clicked.connect ( () => { add_button_clicked (); });
        tabs = new Granite.Widgets.Tabs ();
        tabs.hexpand = true;
        attach (tabs, 0, 0, 1, 1);
        attach (add_eventbox, 1, 0, 1, 1);

        get_style_context ().add_class ("notebook");

        tabs.switch_page.connect ( (t) => {
            page = tabs.tabs.index_of (t);
        });

        tabs.page_removed.connect ( (t) => {
            page_removed (t.widget, 0);
        });
        tabs.need_new_tab.connect ( () => { add_button_clicked (); });

        tabs.show_all ();
        add_eventbox.show_all ();
    }

    public Tab new_tab () {
        var tab = append_page (new Gtk.Grid (), "New", "gtk-file");
        new_tab_created (tab);
        show_all ();
        return tab;
    }
    
    /**
     * granite_widgets_dynamic_notebook_append_page:
     *
     * Return value: (transfer full): a tab
     */
    public Tab append_page (Gtk.Widget widget, string label, string? icon_id = null) {
        var tab = new Tab (label, icon_id);
        //widget.set_has_window (true);
        tab.widget = widget;
        widget.hexpand = widget.vexpand = true;
        attach (widget, 0, 1, 2, 1);
        tabs.add_tab (tab);
        page_added (widget, tabs.tabs.size - 1);
        return tab;
    }

    public void set_scrollable (bool scrollable) {
    }

    public void set_group_name (string name) {
    }
    
    public override void forall_internal (bool internals, Gtk.Callback callback) {
        if (internals) {
            callback (tabs);
            callback (add_eventbox);
        }
        foreach (var tab in tabs.tabs) {
            callback (tab.widget);
        }
    }

    public int page_num (Gtk.Widget widget) {
        foreach (var tab in tabs.tabs) {
            if (tab.widget == widget) return tabs.tabs.index_of (tab);
        }
        return -1;
    }
    
    public override void add (Gtk.Widget widget) {
        var tab = new Tab ("[Untitled]");
        tab.widget = widget;
        widget.hexpand = true;
        widget.vexpand = true;
        tabs.add_tab (tab);
        base.add (widget);
    }
    

    public void set_current_page (int page) {
        this.page  = page;
    }
    
    public int get_current_page () {
        return page;
    }
    
    public int get_n_pages () {
        return (int) get_children ().length ();
    }
    
    public Tab get_nth_page (int page) {
        if (page < tabs.tabs.size && page >= 0)
            return tabs.tabs[page];
        else
            return null;
    }
}



