/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 20126 elementary, Inc. <https://elementary.io>
 */

/**
 * A standard widget for displaying a Gtk.TreeListModel suitable for directory
 * structures. The model is expected to contain objects that implement the
 * TreeListItem interface.
 *
 * The widget can display primary and secondary icons
 * as well as a badge for each item. It the item is marked expandable then an
 * expander is also displayed
 *
 * The TreeList Model is wrapped in a SingleSelection model.
 *
 * Activating an item results in an `item-activated` signal indicating the item activated
 * Triggering a context menu on an item results in a `popup_context_menu` signal indicating
 * both the item selected and its coordinates relative to the widget for positioning the menu.
 *
 * Root items appear at the first level of the tree. It is up to the user to
 * implement a `0th` level widget, in any form, if needed, to provide a description, show/hide and
 * other functionality
 *
 * @since 7.9.0
 */

[Version (since = "7.9.0")]
//TODO Should we allow subclassing?
public sealed class Granite.TreeList : Granite.Bin {
    public signal void item_activated (TreeListItem item);
    public signal void popup_context_menu (Graphene.Point view_point, Granite.TreeListItem treelistitem);

    public bool activate_on_single_click { get; set; default = true;}
    public int row_spacing { get; set; default = 0;}

    private Gtk.ListView list_view;
    private GLib.ListStore root_model;
    private Gtk.TreeListModel tree_model;
    private Gtk.SingleSelection selection_model;

    construct {
        root_model = new GLib.ListStore (typeof (TreeListItem));
        tree_model = new Gtk.TreeListModel (
            root_model,
            false,  // passthrough
            false,  // autoexpand
            (obj) => { //create model for child
                var data = (TreeListItem) obj;
                // If the item needs a child model create it but do not populate
                if (data.is_expandable && data.child_model == null) {
                    data.create_child_model ();
                }

                return data.child_model;
            }
        );

        selection_model = new Gtk.SingleSelection (tree_model);
        var tree_list_factory = new Gtk.SignalListItemFactory ();

        list_view = new Gtk.ListView (selection_model, tree_list_factory);

        bind_property (
            "activate-on-single-click",
            list_view, "single-click-activate",
            BIDIRECTIONAL | SYNC_CREATE
        );

        list_view.activate.connect ((pos) => {
            var tree_row = ((Gtk.TreeListRow) selection_model.get_item (pos));
            var data = (Granite.TreeListItem) (tree_row.item);
            item_activated (data);
        });

         // LIST ITEM FACTORY HANDLERS
        tree_list_factory.setup.connect ((obj) => {
            var listitem = (Gtk.ListItem) obj;
            create_listitem_child (listitem);
        });
        tree_list_factory.teardown.connect ((obj) => {
            var listitem = (Gtk.ListItem) obj;
            teardown_listitem_child (listitem);
        });
        tree_list_factory.bind.connect ((obj) => {
            var listitem = (Gtk.ListItem) obj;
            var treelistrow = (Gtk.TreeListRow) (listitem.get_item ());
            var data = (Granite.TreeListItem) (treelistrow.get_item ());
            bind_data_to_row (data, treelistrow, listitem);
        });
        tree_list_factory.unbind.connect ((obj) => {
            var listitem = (Gtk.ListItem) obj;
            var treelistrow = (Gtk.TreeListRow) (listitem.item);
            var data = (Granite.TreeListItem) (treelistrow.item);
            unbind_data_from_row (data, treelistrow, listitem);
        });

       child = list_view;
    }

    public TreeListItem add_root_item (
        TreeListItem item
    ) {
        root_model.append (item);
        return item;
    }

    public void remove_root_item (TreeListItem item) {
        uint pos;
        if (root_model.find (item, out pos)) {
            root_model.remove (pos);
        }
    }

    public void remove_root_children (List<TreeListItem> to_remove) {
        foreach (TreeListItem item in to_remove) {
            uint pos;
            if (root_model.find (item, out pos)) {
                root_model.remove (pos);
            }
        }
    }

    public void remove_all () {
        root_model.remove_all ();
    }

    public void sort_root_children (CompareDataFunc sort_func) {
        root_model.sort (sort_func);
    }

    public uint n_root_items () {
        return root_model.get_n_items ();
    }

    public delegate bool ListIteratorCallback (TreeListItem item);
    public const bool ITERATE_CONTINUE = true;
    public const bool ITERATE_STOP = false;
    public void iterate_children (TreeListItem? start, ListIteratorCallback cb) {
        ListModel model;
        if (start == null) {
            model = root_model;
        } else {
            model = start.child_model;
        }

        TreeListItem? item = null;
        uint pos = 0;
        do {
            item = (TreeListItem?) (model.get_object (pos++));
        } while (item != null && cb (item));
    }

    public void expand_all (TreeListItem? start) {
        iterate_children (start, expand_callback);
    }

    private bool expand_callback (TreeListItem item) {
        if (item.is_expandable) {
            iterate_children (item, expand_callback);
        }

        return TreeList.ITERATE_CONTINUE;
    }


    public void unselect_all () {
        selection_model.unselect_all ();
    }

    private void create_listitem_child (Gtk.ListItem listitem) {
        var label = new Gtk.Label ("") {
           halign = START,
           hexpand = true
        };
        label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        var primary_image = new Gtk.Image.from_icon_name (null);
        var secondary_image = new Gtk.Image.from_icon_name (null);
        var badge_label = new Gtk.Label ("");
        badge_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        var half_spacing = row_spacing / 2;
        var box = new Gtk.Box (HORIZONTAL, 6) {
            hexpand = true,
            margin_top = half_spacing,
            margin_bottom = row_spacing - half_spacing
        };
        box.append (primary_image);
        box.append (label);
        box.append (secondary_image);
        box.append (badge_label);

        var expander = new Gtk.TreeExpander () {
            child = box
        };

        listitem.child = expander;

        var button_controller = new Gtk.GestureClick () {
            propagation_phase = CAPTURE,
            button = 0
        };

        box.add_controller (button_controller);
        button_controller.pressed.connect ((n_press, bx, by) => {
            var event = button_controller.get_last_event (null);
            if (event.triggers_context_menu ()) { // Only true for press events
                var treelistrow = (Gtk.TreeListRow) (listitem.get_item ());
                var data = (Granite.TreeListItem) (treelistrow.get_item ());
                var button_point = Graphene.Point () {x = (float) bx, y = (float) by};
                var view_point = Graphene.Point ();
                listitem.get_child ().compute_point (list_view, button_point, out view_point);
                popup_context_menu (view_point, data);
            }
        });
    }

    private void teardown_listitem_child (Gtk.ListItem item) {
        // Must be paired with create_listitem child
        // Assuming controller will be removed automatically on teardown
    }

    private void bind_data_to_row (
        TreeListItem data,
        Gtk.TreeListRow row,
        Gtk.ListItem item
    ) {
        // Must be matched with create item widget when overriding
        var expander = (Gtk.TreeExpander) (item.child);
        expander.set_list_row (row);
        expander.hide_expander = !data.is_expandable;
        data.expanded_binding = data.bind_property ("is-expanded", row, "expanded", BIDIRECTIONAL | SYNC_CREATE);
        var box = (Gtk.Box)(expander.child);
        var primary_image = (Gtk.Image)(box.get_first_child ());
        var name_label = (Gtk.Label)(primary_image.get_next_sibling ());
        var secondary_image = (Gtk.Image) (name_label.get_next_sibling ());
        var badge_label = (Gtk.Label) secondary_image.get_next_sibling ();

        name_label.label = data.text;
        name_label.tooltip_text = data.tooltip;
        primary_image.icon_name = data.icon_name;
        secondary_image.icon_name = data.secondary_icon_name;
        secondary_image.tooltip_text = data.secondary_icon_tooltip;
        badge_label.label = data.badge;

        //TODO Should we expose a public virtual method to allow users to modify
        // the ListItem?
    }

    private void unbind_data_from_row (
        TreeListItem data,
        Gtk.TreeListRow row,
        Gtk.ListItem item
    ) {
        data.expanded_binding.unbind ();
        // //TODO Is this needed? Not all reset on binding another object
        // name_label.label = "";
        // name_label.tooltip = "";
        // primary_image.icon_name = "";
        // secondary_image.icon_name = "";
        // secondary_image_tooltip = "";
        // badge_label.label = "";
    }
 }
