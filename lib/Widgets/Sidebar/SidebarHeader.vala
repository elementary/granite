namespace Granite.Widgets {
    public class SidebarHeader : SidebarRow {
        public SidebarHeaderModel header_model {
            get {
                return (SidebarHeaderModel) model;
            }
        }

        private Gtk.Revealer disclosure_image_revealer;
        private Gtk.Image disclosure_image;
        private Gtk.Grid row_layout;
        private Gtk.Button row_box;

        public SidebarHeader (SidebarHeaderModel model) {
            Object (model: (SidebarRowModel) model);
            
            build_ui ();
            connect_signals ();
            load_data ();
        }


        private void build_ui () {
            selectable = false;

            disclosure_image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);

            disclosure_image_revealer = new Gtk.Revealer ();
            disclosure_image_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            disclosure_image_revealer.add (disclosure_image);

            row_layout = build_grid ();
            row_layout.attach (disclosure_image_revealer, 3, 0, 1, 2);
            set_bold ();

            row_box = new Gtk.Button ();
            row_box.get_style_context ().remove_class (Gtk.STYLE_CLASS_BUTTON);

            row_box.add (row_layout);

            add (row_box);
        }

        protected void connect_signals () {
            base.connect_signals ();
            
            header_model.children.items_changed.connect (handle_children_items_changed);

            header_model.expanded_changed.connect (update_disclosure_image);
            row_box.clicked.connect (toggle_reveal_children);

            row_box.enter_notify_event.connect (() => {
                disclosure_image_revealer.reveal_child = true;
                return false;
            });

            row_box.leave_notify_event.connect (() => {
                disclosure_image_revealer.reveal_child = false;
                return false;
            });

            header_model.show.connect (() => { show (); });
            header_model.hide.connect (() => { hide (); });
        }

        private void load_data () {
            base.load_data ();

            update_disclosure_image (header_model.expanded);
            
            handle_children_items_changed ();
        }

        private void handle_children_items_changed () {
            if (header_model.children.get_n_items () == 0) {
                no_show_all = true;
                hide ();
            } else {
                no_show_all = false;
                show_all ();
            }
        }

        private void update_disclosure_image (bool expanded) {
            if (expanded) {
                disclosure_image.icon_name = "pan-down-symbolic";
            } else {
                disclosure_image.icon_name = "pan-end-symbolic";
            }
        }

        private void toggle_reveal_children () {
            header_model.expanded = !header_model.expanded;
        }
    }
}