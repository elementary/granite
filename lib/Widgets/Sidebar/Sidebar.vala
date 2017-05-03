
namespace Granite.Widgets {
    public class Sidebar : Gtk.ListBox {
    
        public Sidebar () {
            Object ();
        }
        
        construct {
            build_ui ();
        }

        private void build_ui () {
            get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
            width_request = 176;
            vexpand = true;
        }

        public void bind_model (ListModel? model) {
            base.bind_model (model, walk_model_items);
        }
        
        private Gtk.Widget walk_model_items (Object item) {
            assert (item is SidebarRowModel);    

            if (item is SidebarExpandableRowModel) {
                var sidebar_model = (SidebarExpandableRowModel) item;
                
                return new SidebarExpandableRow (sidebar_model);
            } else if (item is SidebarHeaderModel) {
                var sidebar_model = (SidebarHeaderModel) item;
                
                return new SidebarHeader (sidebar_model);
            } else {
                var sidebar_model = (SidebarRowModel) item;

                return new SidebarRow (sidebar_model);
            }


        }
    }
}