
const string BUTTON_STYLE = """
* {
    -GtkButton-default-border : 0;
    -GtkButton-default-outside-border : 0;
    -GtkButton-inner-border: 0;
    -GtkWidget-focus-line-width : 0;
    -GtkWidget-focus-padding : 0;
    padding: 0;
}
""";

namespace Granite.Widgets {
    
    public struct Tab {
        string label;
        Gtk.Widget page;
        string? icon;
    }
    
    public class DynamicNotebook : Gtk.EventBox {
        
        /**
         * the underlying GtkNotebook, in case you need a method not provided by this class
         **/
        public Gtk.Notebook notebook;
        /**
         * connect to this signal to be notified when a page is closed. 
         * @return return true to let the tab be closed
         **/
        public signal bool page_closed (Gtk.Widget page, uint num);
        /**
         * the plus button was pressed, you should return a Tab struct and fill it with the 
         * appropriate content
         **/
        public signal Tab? new_page ();
        /**
         * the notebook page was swtiched
         **/
        public signal void switch_page (Gtk.Widget page, uint num);
        /**
         * Show or hide tab icons. Doesn't apply to existing tabs.
         **/
        public bool show_icon;
        
        private Gtk.CssProvider button_fix;
        
        private int tab_width = 150;
        private int max_tab_width = 150;
        
        /**
         * create a new dynamic notebook
         **/
        public DynamicNotebook () {
            
            this.button_fix = new Gtk.CssProvider ();
            try {
                this.button_fix.load_from_data (BUTTON_STYLE, -1);
            } catch (Error e) { warning (e.message); }
            
            this.notebook = new Gtk.Notebook ();
            this.visible_window = false;
            this.get_style_context ().add_class ("dynamic-notebook");
            
            this.notebook.scrollable = true;
            this.notebook.show_border = false;
            
            this.draw.connect ( (ctx) => {
                this.get_style_context ().render_activity (ctx, 0, 0, this.get_allocated_width (), 27);
                return false;
            });
            
            this.add (this.notebook);
            
            
            var add = new Gtk.Button ();
            add.add (new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU));
            add.margin_left = 6;
            add.relief = Gtk.ReliefStyle.NONE;
            this.notebook.set_action_widget (add, Gtk.PackType.START);
            add.show_all ();
            add.get_style_context ().add_provider (button_fix, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            
            add.clicked.connect ( () => {
                var t = this.new_page ();
                this.append_page (t.label, t.page, t.icon);
            });
            
            this.size_allocate.connect ( () => {
                this.recalc_size ();
            });
            
            this.key_press_event.connect ( (e) => {
                switch (e.keyval){
                    case 119: //ctrl+w
                        if (Signal.has_handler_pending (this, //if no one listens, just kill it!
                            Signal.lookup ("page-closed", typeof (DynamicNotebook)), 0, true)) {
                            var sure = this.page_closed (this.notebook.get_nth_page (this.notebook.page), 
                                this.notebook.page);
                            if (sure)
                                this.notebook.remove_page (this.notebook.page);
                        } else {
                            this.notebook.remove_page (this.notebook.page);
                        }
                        return true;
                    case 116: //ctrl+t
                        var t = this.new_page ();
                        this.append_page (t.label, t.page, t.icon);
                        return true;
                    case 49: //ctrl+[1-8]
                    case 50:
                    case 51:
                    case 52:
                    case 53:
                    case 54:
                    case 55:
                    case 56:
                        if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0){
                            var i = e.keyval - 49;
                            this.notebook.page = (int)((i >= this.notebook.get_n_pages ()) ? 
                                this.notebook.get_n_pages () - 1 : i);
                            return true;
                        }
                        break;
                    /*case 65289: //tab (and shift+tab)    not working :(  (Gtk seems to move focus)
                    case 65056:
                        if ((e.state & Gdk.ModifierType.SHIFT_MASK) != 0){
                            this.prev ();
                            return true;
                        }else if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0){
                            this.next ();
                            return true;
                        }
                        break;*/
                }
                return false;
            });
            
            this.notebook.button_press_event.connect ( (e) => {
                /*if (e.button == 1) {
                    this.get_parent_window ().begin_move_drag ((int)e.button, (int)e.x_root, (int)e.y_root, e.time);
                    return true;
                }*/
                return false;
            });
        }
        
        private void recalc_size () {
            if (this.notebook.get_n_pages () == 0)
                return;
            
            var offset = 130;
            this.tab_width = (this.get_allocated_width () - offset) / this.notebook.get_n_pages ();
            if (this.tab_width > max_tab_width)
                this.tab_width = max_tab_width;
            
            for (var i=0;i<this.notebook.get_n_pages ();i++) {
                this.notebook.get_tab_label (this.notebook.get_nth_page (i)).width_request = tab_width;
            }
        }
        
        private void next () {
            this.notebook.page = (this.notebook.page + 1 >= this.notebook.get_n_pages ())?
                this.notebook.page = 0 : this.notebook.page + 1;
        }
        private void prev () {
            this.notebook.page = (this.notebook.page - 1 < 0)?this.notebook.get_n_pages () - 1:
                this.notebook.page-1;
        }
        
        public uint append_tab (Tab tab) {
            return this.append_page (tab.label, tab.page, tab.icon);
        }
        
        /**
         * add a page to the notebook
         * @param label The label for the tab
         * @param page The tab page
         * @param icon An optional icon for the tab. Use a Gtk icon_name
         **/
        public uint append_page (string label, Gtk.Widget page, string? icon = null) {
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            
            var close = new Gtk.Button ();
            close.add (new Gtk.Image.from_stock (Gtk.Stock.CLOSE, Gtk.IconSize.MENU));
            close.get_style_context ().add_provider (button_fix, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            close.relief = Gtk.ReliefStyle.NONE;
            
            var lbl = new Gtk.EventBox ();
            var l = new Gtk.Label (label);
            l.set_tooltip_text (label);
            lbl.add (l);
            l.ellipsize = Pango.EllipsizeMode.END;
            lbl.visible_window = false;
            
            var spinner = new Gtk.Spinner ();
            
            box.width_request = tab_width;
            box.pack_start (close, false);
            box.pack_start (lbl);
            
            Gtk.Image img;
            if (icon != null)
                img = new Gtk.Image.from_icon_name (icon, Gtk.IconSize.MENU);
            else
                img = new Gtk.Image.from_icon_name ("empty", Gtk.IconSize.MENU);
            box.pack_start (img, false);
            box.pack_start (spinner, false);
            
            var idx = this.notebook.append_page (page, box);
            this.notebook.set_tab_reorderable (page, true);
            
            page.show_all ();
            this.notebook.page = idx;
            
            box.show_all ();
            if (!show_icon)
                img.hide ();
            spinner.hide ();
            
            lbl.button_release_event.connect ( (e) => {
                if (e.button == 2) {
                    this.close_by_button (close);
                    return true;
                }
                return false;
            });
            
            lbl.scroll_event.connect ( (e) => {
                if (e.direction == Gdk.ScrollDirection.UP)
                    this.prev ();
                else
                    this.next ();
                return false;
            });
            
            close.clicked.connect ( () => this.close_by_button (close) );
            
            this.recalc_size ();
            
            return idx;
        }
        
        private void close_by_button (Gtk.Button close) {
            int i; //find the label widget that fits the close button's parent
            for (i=0;i<this.notebook.get_n_pages (); i++) {
                if (close.get_parent () == 
                    this.notebook.get_tab_label (this.notebook.get_nth_page (i)))
                    break;
            }
            if (Signal.has_handler_pending (this, //if no one listens, just kill it!
                Signal.lookup ("page-closed", typeof (DynamicNotebook)), 0, true)) {
                var sure = this.page_closed (this.notebook.get_nth_page (i), i);
                if (sure)
                    this.notebook.remove_page (i);
            } else {
                this.notebook.remove_page (i);
            }
        }
        
        /**
         * toggle the working state of the tab, which will cause a spinner to appear if it's working
         **/
        public void toggle_working (int num, bool enable) {
            var box = (Gtk.Container)this.notebook.get_tab_label (this.notebook.get_nth_page (num));
            if (enable) {
                box.get_children ().nth_data (3).show_all ();
                box.get_children ().nth_data (2).hide ();
            } else {
                box.get_children ().nth_data (2).show_all ();
                box.get_children ().nth_data (3).hide ();
            }
            
        }
        
        /**
         * toggle whether the tab should be an app, e.g. show only its icon
         **/
        public void toggle_app_tab (int num, bool enable) {
            var box = (Gtk.Container)this.notebook.get_tab_label (this.notebook.get_nth_page (num));
            if (enable) {
                box.get_children ().nth_data (0).hide ();
                box.get_children ().nth_data (1).hide ();
            } else {
                box.get_children ().nth_data (0).show_all ();
                box.get_children ().nth_data (1).show_all ();
            }
        }
        
    }
    
}
