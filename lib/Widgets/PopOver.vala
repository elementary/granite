public class Granite.Widgets.PopOver : Gtk.Dialog
{
    const int ARROW_HEIGHT = 12;
    const int ARROW_WIDTH = 30;
    const int SHADOW = 20;
    int RADIUS = 5;
    double offset = 10.0;
    const int MARGIN = 12;
    Gtk.Widget menu;
    Gtk.CssProvider style_provider;
    Gtk.Box hbox;
    
    construct {
        
        // Set up css provider
        style_provider = new Gtk.CssProvider ();
        try {
            style_provider.load_from_path (Build.RESOURCES_DIR + "/style/CompositedWindow.css");
        } catch (Error e) {
            warning ("Could not add css provider. Some widgets will not look as intended. %s", e.message);
        }
        
        // Window properties
        set_visual (get_screen ().get_rgba_visual());
        get_style_context ().add_provider (style_provider, 600);
        app_paintable = true;
        decorated = false;
        resizable = false;
        set_position(Gtk.WindowPosition.NONE);
        set_type_hint(Gdk.WindowTypeHint.NORMAL);
    }

    public PopOver()
    {
        hbox = get_content_area() as Gtk.Box;
        hbox.set_margin_top(MARGIN + ARROW_HEIGHT + SHADOW);
        hbox.set_margin_left(MARGIN + SHADOW);
        hbox.set_margin_right(MARGIN + SHADOW);
        hbox.set_margin_bottom(SHADOW);
        menu = new Gtk.Window();
        get_style_context().add_class("popover");
        menu.get_style_context().add_class("popover");

        size_allocate.connect(on_size_allocate);

        focus_out_event.connect_after((f) =>
        {
            foreach(Gtk.Window window in Gtk.Window.list_toplevels())
            {
                if(((int)window.type_hint) != 0 && window.visible)
                {
                    return false;
                }
            }
            hide ();

            return false;
        });
    }

    public void set_parent_pop (Gtk.Window win)
    {
        win.configure_event.connect( () => { hide(); return true; });
    }

    public void move_to_widget (Gtk.Widget w)
    {
        int x, y, width, height;
        w.get_window().get_root_origin(out x, out y);
        Gtk.Allocation alloc;
        w.get_allocation(out alloc);
        width = alloc.width;
        x += alloc.x;
        y += alloc.y;
        height = alloc.height;
        y += height + SHADOW/2;
        x += width/2 - (int)offset - SHADOW - ARROW_WIDTH/2;
        move(x, y);
        set_parent_pop(w.get_toplevel() as Gtk.Window);
    }

    public void move_to_window(Gdk.Window win)
    {
        int x,y,w,h;
        win.get_root_origin(out x, out y);
        win.get_origin(out x, out y);
        x += win.get_width()/2 - MARGIN - SHADOW - (int)offset;
        y += win.get_height() - SHADOW;
        print("%d %d\n", x, y);
        show_all();
        show_now();
        move(x, y);
    }

    void fast_blur (ref Cairo.ImageSurface img, int radius)
    {
        if (radius < 1){
            return;
        }
        
        int w = img.get_width();
        int h = img.get_height();
        int wm = w-1;
        int hm = h-1;
        int wh = w*h;
        int ch = 4;
        int div = radius+radius+1;
        int[] r = new int[wh];
        int rsum,x,y,i,p,p1,p2,yp,yi,yw;
        int max = int.max(w, h);
        int[] vmin = new int[max];
        int[] vmax = new int[int.max(w,h)];
        unowned uchar[] pix=img.get_data ();
        int[] dv=new int[256*div];

        for (i=0;i<256*div;i++) {
            dv[i]=(i/div); 
        }

        yw=yi=0;

        for (y=0;y<h;y++) {
            rsum=0;
            for(i=-radius;i<=radius;i++){
              p = (yi+int.min(wm, int.max(i,0))) * ch;
              rsum+=pix[p + 3];
            }
            for (x=0;x<w;x++) {

                r[yi]=rsum/div;

                if(y==0){
                    vmin[x]=int.min(x+radius+1,wm);
                    vmax[x]=int.max(x-radius,0);
                } 
                p1=(yw+vmin[x]) * ch;
                p2=(yw+vmax[x]) * ch;

                rsum+=pix[p1 + 3]-pix[p2 + 3];
                yi++;
            }
            yw+=w;
        }

        for (x=0;x<w;x++) {
            rsum=0;
            yp=-radius*w;
            for(i=-radius; i<=radius; i++) {
                yi=int.max(0,yp)+x;
                rsum+=r[yi];
                yp+=w;
            }
            yi=x;
            for (y=0;y<h;y++) {
                p = yi * ch;
                pix[p + 3] = (uchar)(rsum/div);
                pix[p] = 0; // (uchar)(rsum/div);
                pix[p + 1] = 0; // (uchar)(rsum/div);
                pix[p + 2] = 0; // (uchar)(rsum/div);
                if(x==0){
                  vmin[y]=int.min(y+radius+1,hm)*w;
                  vmax[y]=int.max(y-radius,0)*w;
                }
                p1=x+vmin[y];
                p2=x+vmax[y];

                rsum+=r[p1]-r[p2];

                yi+=w;
            }
        }
    }

    Cairo.ImageSurface blur_surf;

    void make_shape(Cairo.Context cr_surf)
    {
        int w = get_allocated_width();
        int h = get_allocated_height();
        cr_surf.move_to(SHADOW + RADIUS, SHADOW + ARROW_HEIGHT);
        cr_surf.line_to(SHADOW + offset, SHADOW + ARROW_HEIGHT);
        cr_surf.line_to(SHADOW + offset + ARROW_WIDTH/2, SHADOW);
        cr_surf.line_to(SHADOW + offset + ARROW_WIDTH, SHADOW + ARROW_HEIGHT);
        cr_surf.line_to(w - SHADOW - RADIUS, SHADOW + ARROW_HEIGHT);

        cr_surf.curve_to(w - SHADOW, SHADOW + ARROW_HEIGHT,
                         w - SHADOW, SHADOW + ARROW_HEIGHT + RADIUS,
                         w - SHADOW, SHADOW + ARROW_HEIGHT + RADIUS);

        cr_surf.line_to(w - SHADOW, h - SHADOW - RADIUS);
        cr_surf.curve_to(w - SHADOW, h - SHADOW,
                         w - SHADOW - RADIUS, h - SHADOW,
                         w - SHADOW - RADIUS, h - SHADOW);
        cr_surf.line_to(SHADOW + RADIUS, h - SHADOW);
        cr_surf.curve_to(SHADOW, h - SHADOW,
                         SHADOW, h - SHADOW - RADIUS,
                         SHADOW, h - SHADOW - RADIUS);
        cr_surf.line_to(SHADOW, SHADOW + ARROW_HEIGHT + RADIUS);
        cr_surf.curve_to(SHADOW, SHADOW + ARROW_HEIGHT,
                         SHADOW + RADIUS, SHADOW + ARROW_HEIGHT,
                         SHADOW + RADIUS, SHADOW + ARROW_HEIGHT);
        cr_surf.close_path();
    }

    void on_size_allocate(Gtk.Allocation alloc)
    {
        RADIUS = 3;
        int w = get_allocated_width();
        int h = get_allocated_height();
        blur_surf = new Cairo.ImageSurface(Cairo.Format.ARGB32, w, h);
        Cairo.Context cr_surf = new Cairo.Context(blur_surf);
        cr_surf.set_source_rgba(0.4,0.4,0.4,0.0);
        cr_surf.paint();
        make_shape(cr_surf);
        cr_surf.clip();
        cr_surf.set_source_rgba(0.4,0.4,0.4, 0.5);
        cr_surf.paint();
        blur_surf.flush();
        fast_blur(ref blur_surf, 4);
        fast_blur(ref blur_surf, 4);
        RADIUS = 5;
    }

    public override bool draw(Cairo.Context cr)
    {
        int w = get_allocated_width();
        int h = get_allocated_height();
        cr.set_source_surface(blur_surf, 0, 0);
        cr.paint_with_alpha(0.8);

        make_shape(cr);
        cr.clip();
        Gtk.render_background(menu.get_style_context(), cr, SHADOW, SHADOW, get_allocated_width() - 2*SHADOW, get_allocated_height() - 2*SHADOW);
        return base.draw(cr);
    }
}
