/*
* Copyright (c) 2016 elementary LLC (https://launchpad.net/granite)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
*/

namespace Granite.Widgets {
    public class SidebarExpandableRow : SidebarRow {
        public SidebarExpandableRowModel expandable_model {
            get {
                return (SidebarExpandableRowModel) model;
            }
        }

        private Gtk.Button disclosure_button;
        private Gtk.Revealer disclosure_button_revealer;
        private Gtk.Grid row_layout;

        public SidebarExpandableRow (SidebarExpandableRowModel model) {
            Object (model: (SidebarRowModel) model);

            build_ui ();
            connect_signals ();
            load_data ();
        }

        private void build_ui () {
            disclosure_button = new Gtk.Button.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
            disclosure_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_BUTTON);

            disclosure_button_revealer = new Gtk.Revealer ();
            disclosure_button_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            disclosure_button_revealer.add (disclosure_button);

            row_layout = build_grid ();
            row_layout.insert_column (0);
            row_layout.attach (disclosure_button_revealer, 0, 0, 1, 2);

            add (row_layout);
        }

        protected void connect_signals () {
            base.connect_signals ();

            expandable_model.children.items_changed.connect (handle_children_items_changed);

            expandable_model.expanded_changed.connect (update_disclosure_button_icon);
            disclosure_button.clicked.connect (toggle_reveal_children);

            disclosure_button_revealer.notify["child-revealed"].connect (handle_disclosure_button_revealer_state_changed);

            expandable_model.show.connect (() => { show (); });
            expandable_model.hide.connect (() => { hide (); });
        }

        private void load_data () {
            base.load_data ();

            update_disclosure_button_icon (expandable_model.expanded);

            handle_children_items_changed ();
        }

        private void handle_disclosure_button_revealer_state_changed () {
            if (!disclosure_button_revealer.reveal_child) {
                disclosure_button_revealer.visible = false;
            }
        }

        private void handle_children_items_changed () {
            if (expandable_model.children.get_n_items () == 0) {
                disclosure_button_revealer.no_show_all = true;
                disclosure_button_revealer.reveal_child = false;
            } else {
                disclosure_button_revealer.no_show_all = false;
                disclosure_button_revealer.show_all ();
                disclosure_button_revealer.reveal_child = true;
            }
        }

        private void update_disclosure_button_icon (bool expanded) {
            if (expanded) {
                ((Gtk.Image) disclosure_button.image).icon_name = "pan-down-symbolic";
            } else {
                ((Gtk.Image) disclosure_button.image).icon_name = "pan-end-symbolic";
            }
        }

        private void toggle_reveal_children () {
            expandable_model.expanded = !expandable_model.expanded;
        }
    }
}
