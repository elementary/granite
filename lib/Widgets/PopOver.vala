/*
 * Copyright (c) 2011 Lucas Baudin <xapantu@gmail.com>
 *
 * This is a free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */


/**
 * PopOver widget. It is a Dialog you can attach to a widget, e.g. a button.
 *
 * It is a dialog you can attach to a widget, to make it look
 * more consistent, and easier to understand. e.g. if you need to make a popup
 * after clicking on a button as "Create a new document" to choose the type
 * of the document, a popover is more adapted because you can see which button
 * is related to the button, etc... It is also less agressive than a usual
 * dialog because it doesn't hide a big part of the screen. And it is closed
 * when it lose focus.
 *
 * {{images/popover.png}}
 *
 **/

public class Granite.Widgets.PopOver : Gtk.Dialog
{
    const int ARROW_HEIGHT = 17;
    const int ARROW_WIDTH = 30;
    const int SHADOW = 10;
    int RADIUS = 10;
    double offset = 15.0;
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
        skip_pager_hint = true;
        skip_pager_hint = true;
    }

    /**
     * Create a new PopOver
     **/
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

    /**
     * Set the parent window of the popover. It should not be needed, but it
     * could solve some bugs on some window manager.
     **/
    public void set_parent_pop (Gtk.Window win)
    {
        set_transient_for(win);
        win.configure_event.connect( () => { hide(); return true; });
    }

    /**
     * Change the position of the popover, to display it under w.
     *
     * The arrow of the PopOver is moved at the bottom of the widget, and it is
     * horizontally centered.
     *
     * @param w a normal Gtk.Widget, e.g. a button
     **/
    public void move_to_widget (Gtk.Widget w)
    {
        int x,y;
        w.get_window ().get_origin(out x, out y);
        Gtk.Allocation alloc;
        w.get_allocation (out alloc);
        x += alloc.x + alloc.width/2 - SHADOW - (int)offset - ARROW_WIDTH/2;
        y += alloc.y + alloc.height - SHADOW;
        show_all();
        move(x, y);
        set_parent_pop(w.get_toplevel() as Gtk.Window);
    }

    public void move_to_coords (int x, int y)
    {
        x -= (int) offset + SHADOW + ARROW_WIDTH/2;
        y -= SHADOW;
        move(x, y);
    }

    /**
     * Move the popover to the Gdk.Window window. The recommand method is
     * move_to_widget, but this one can be used when we don't know which widget
     * triggered the action (e.g. with a Gtk.Action).
     **/
    public void move_to_window(Gdk.Window window)
    {
        int x,y,w,h;
        window.get_root_origin(out x, out y);
        window.get_origin(out x, out y);
        x += window.get_width()/2 - MARGIN - SHADOW - (int)offset;
        y += window.get_height() - SHADOW;
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
        RADIUS -= 2;
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
        RADIUS += 2;
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
