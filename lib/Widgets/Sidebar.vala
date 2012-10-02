// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*
 * Copyright (c) 2012 Victor Eduardo <victoreduardm@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */


/**
 * A widget that can display a list of items organized in categories.
 *
 * The sidebar widget consists of a collection of items, some of which are also expandable (and
 * thus can contain more items). All the items displayed in the sidebar are children of the widget's
 * root item. The API is meant to be used as follows:
 *
 * 1. Create the items you want to display in the sidebar, setting the appropriate values for their
 * properties. The desired hierarchy is achieved by creating expandable items and adding items to them.
 * These will be displayed as descendants in the widget's tree structure. The expandable items that are
 * not nested inside any other item are considered to be at root level, and should be added to
 * the widget's root item.<<BR>>
 *
 * Expandable items located at the root level are treated as categories, and only support text.
 *
 * ''Example''<<BR>>
 * The final tree will have the following structure:
 * {{{
 * Libraries
 *   Music
 * Stores
 *   My Store
 *      Music
 *      Podcasts
 * Devices
 *   Player 1
 *   Player 2
 * }}}
 *
 * {{{
 * var library_category = new Granite.Widgets.Sidebar.ExpandableItem ("Libraries");
 * var store_category = new Granite.Widgets.Sidebar.ExpandableItem ("Stores");
 * var device_category = new Granite.Widgets.Sidebar.ExpandableItem ("Devices");
 *
 * var music_item = new Granite.Widgets.Sidebar.Item ("Music");
 *
 * // "Libraries" will be the parent category of "Music"
 * library_category.add_item (music_item);
 *
 * // We plan to add sub-items to the store, so let's use an expandable item
 * var my_store_item = new Granite.Widgets.Sidebar.ExpandableItem ("My Store");
 * store_category.add_item (my_store_item);
 *
 * var my_store_podcast_item = new Granite.Widgets.Sidebar.Item ("Podcasts");
 * var my_store_music_item = new Granite.Widgets.Sidebar.Item ("Music");
 *
 * my_store_item.add_item (my_store_music_item);
 * my_store_item.add_item (my_store_podcast_item);
 *
 * var player1_item = new Granite.Widgets.Sidebar.Item ("Player 1");
 * var player2_item = new Granite.Widgets.Sidebar.Item ("Player 2");
 *
 * device_category.add_item (player1_item);
 * device_category.add_item (player2_item);
 * }}}
 *
 * 2. Create a sidebar widget.<<BR>>
 * {{{
 * var sidebar = new Granite.Widgets.Sidebar ();
 * }}}
 *
 * 3. Add root-level items to the {@link Granite.Widgets.Sidebar.root} item.
 * This item only serves as a container, and all its properties are ignored by the widget.
 *
 * {{{
 * // This will add the main categories (including their children) to the sidebar. After
 * // having being added to be widget, any other item added to any of these items
 * // (or any other child item in a deeper level) will be automatically added too.
 * // There's no need to deal with the sidebar widget directly.
 *
 * var root = sidebar.root;
 *
 * root.add_item (library_category);
 * root.add_item (store_category);
 * root.add_item (device_category);
 * }}}
 *
 * The steps mentioned above are enough for initializing the sidebar. Future changes to the items'
 * properties are ''automatically'' reflected by the widget.
 *
 * Final steps would involve connecting handlers to the sidebar events, being
 * {@link Granite.Widgets.Sidebar.item_selected} the most important, as it indicates that
 * the selection was modified.
 *
 * It is strongly recommended to pack the sidebar into the GUI using the
 * {@link Granite.Widgets.SidebarPaned} widget. It has aesthetic advantages and offers a wider
 * re-size handle than usual Paned widgets do. This is usually done as follows:
 * {{{
 * var sidebar_paned = new Granite.Widgets.SidebarPaned ();
 * sidebar_paned.pack1 (sidebar, true, false);
 * sidebar_paned.pack2 (content_area, true, false);
 * }}}
 *
 * @since 0.2
 * @see Granite.Widgets.SidebarPaned
 */
public class Granite.Widgets.Sidebar : Gtk.ScrolledWindow {

    /**
     * = WORKING INTERNALS =
     *
     * In order to offer a transparent Item-based API, and avoid the need of providing methods
     * to deal with items directly on the Sidebar widget, it was decided to follow a monitor-like
     * implementation, where the sidebar permanently monitors its root item and any other
     * child item added to it. The task of monitoring the properties of the items has been
     * divided between different objects, as shown below:
     *
     * Monitored by: Object::method that receives the signals indicating the property change.
     * Applied by: Object::method that actually updates (directly or indirectly, as in the case of
     *             the tree model) the tree to reflect the property changes.
     *
     * ---------------------------------------------------------------------------------------------
     *   PROPERTY        |  MONITORED BY                     |  APPLIED BY
     * ---------------------------------------------------------------------------------------------
     * + Item            |                                   |
     *   - parent        | Not monitored                     | N/A
     *   - name          | Sidebar::on_item_property_changed | Tree::name_cell_data_func
     *   - editable      | Sidebar::on_item_property_changed | Queried when needed (See Tree::start_editing_item)
     *   - visible       | Sidebar::on_item_property_changed | FilteredDataModel::filter_visible_func
     *   - icon          | Sidebar::on_item_property_changed | Tree::icon_cell_data_func
     *   - activatable   | Same as @icon                     | Same as @icon
     * + ExpandableItem  |                                   |
     *   - no_caption    | Sidebar::on_item_property_changed | Tree::name_cell_data_func
     *   - collapsible   | Sidebar::on_item_property_changed | Tree::update_expansion
     *                   |                                   | Tree::expander_cell_data_func
     *   - expanded      | Same as @collapsible              | Same as @collapsible
     * ---------------------------------------------------------------------------------------------
     * * Only automatic properties are monitored. ExpandableItem's add/removals are handled by
     *   Sidebar::add_item() and Sidebar::remove_item()
     *
     * Other features:
     * - Sorting: this happens on the tree-model level. See FilteredDataModel and Sidebar::SortFunc.
     */



    /**
     * A sidebar entry.
     *
     * Any change made to any of its properties will be ''automatically'' reflected
     * by the {@link Granite.Widgets.Sidebar} widget.
     *
     * @since 0.2
     */
    public class Item : Object {

        /**
         * Emitted every time a property changes.
         *
         * @param self Self.
         * @param prop_name Property name.
         * @since 0.2
         */
        internal signal void changed (Item self, string prop_name);

        /**
         * Emitted when the user has finished editing the item's name.
         *
         * By default, if the name doesn't consist of white space, it is automatically asigned
         * to the {@link Granite.Widgets.Sidebar.name} property. Code can change that behavior
         * by overriding this signal.
         *
         * @param new_name The item's new name (result of editing.)
         * @since 0.2
         */
        public virtual signal void edited (string new_name) {
            if (editable && new_name.strip () != "")
                this.name = new_name;
        }

        /**
         * The {@link Granite.Widgets.Sidebar.Item.activatable} icon was activated.
         *
         * @see Granite.Widgets.Sidebar.Item.activatable
         * @since 0.2
         */
        public virtual signal void action_activated () { }

        /**
         * Emitted when the item is double-clicked or when it is selected and one of the keys:
         * Space, Shift+Space, Return or Enter is pressed. This signal is //also// for
         * editable items.
         *
         * @since 0.2
         */
        public virtual signal void activated () { }

        /**
         * Parent {@link Granite.Widgets.Sidebar.ExpandableItem} of the item.
         * ''Must not'' be modified.
         *
         * @since 0.2
         */
        public ExpandableItem parent { get; internal set; }

        /**
         * The item's name. Primary and most important information.
         *
         * @since 0.2
         */
        public string name { get; set; default = ""; }

        /**
         * A counter shown in a bubble right next to the item's name.
         *
         * It can be used for displaying the number of unread messages in the "Inbox" item,
         * for instance. ''Still not implemented''.
         *
         * @since 0.2
         */
        public uint count { get; set; default = 0; }

        /**
         * Whether the item's name can be edited from within the sidebar.
         *
         * When this property is set to //true//, users can edit the item by pressing
         * the F2 key, or by double-cliking over an item.
         *
         * @see Granite.Widgets.Sidebar.start_editing_item
         * @since 0.2
         */
        public bool editable { get; set; default = false; }

        /**
         * Whether the item will appear in the sidebar's tree or not.
         *
         * @since 0.2
         */
        public bool visible { get; set; default = true; }

        /**
         * Whether the item can be selected or not.
         *
         * Setting this property to true doesn't guarantee that the item will actually be
         * selectable, since there are other external factors to take into account, like the
         * item's {@link Granite.Widgets.Sidebar.Item.visible} property; whether the item is
         * a category; the parent item is collapsed, etc.
         *
         * @see Granite.Widgets.Sidebar.Item.visible
         * @since 0.2
         */
        public bool selectable { get; set; default = true; }

        /**
         * Primary icon.
         *
         * This property should be used to give the user an idea of what the item represents
         * (i.e. content type.)
         *
         * @since 0.2
         */
        public Icon icon { get; set; }

        /**
         * An activatable icon that works like a button.
         *
         * It can be used for e.g. showing an //"eject"// icon on a device's sidebar item.
         *
         * @see Granite.Widgets.Sidebar.Item.action_activated
         * @since 0.2
         */
        public Icon activatable { get; set; }

        /**
         * Creates a new {@link Granite.Widgets.Sidebar.Item}.
         *
         * @param name Name of the item.
         * @return (transfer full) A new {@link Granite.Widgets.Sidebar.Item}.
         * @since 0.2
         */
        public Item (string name = "") {
            this.name = name;
            this.notify.connect (on_property_changed);
        }

        /**
         * Invoked when the item is secondary-clicked or when the usual menu keys are pressed.
         *
         * @return A {@link Gtk.Menu} or //null// if nothing should be displayed.
         * @since 0.2
         */
        public virtual Gtk.Menu? get_context_menu () {
            return null;
        }

        private void on_property_changed (ParamSpec prop) {
            changed (this, prop.name);
        }
    }



    /**
     * An item that can contain more items.
     *
     * It supports all the properties inherited from {@link Granite.Widgets.Sidebar.Item},
     * and behaves like a normal item, except when it is located at the root sidebar level;
     * in that case, the {@link Granite.Widgets.Sidebar.Item.activatable},
     * {@link Granite.Widgets.Sidebar.Item.count}, and {@link Granite.Widgets.Sidebar.Item.icon}
     * properties are simply //ignored// by the {@link Granite.Widgets.Sidebar} widget.
     * Root-level expandable items are also ''not'' editable, and are not displayed when they
     * contain zero children.
     *
     * @since 0.2
     */
    public class ExpandableItem : Item {

        /**
         * Emitted when an item is added.
         *
         * @param item Item added.
         * @see Granite.Widgets.Sidebar.ExpandableItem.add_item
         * @since 0.2
         */
        public signal void child_added (Item item);

        /**
         * Emitted when an item is removed.
         *
         * @param item Item removed.
         * @see Granite.Widgets.Sidebar.ExpandableItem.remove_item
         * @since 0.2
         */
        public signal void child_removed (Item item);

        /**
         * Emitted when the item is expanded or collapsed.
         *
         * @since 0.2
         */
        public virtual signal void toggled () { }

        /**
         * Whether the item is collapsible or not.
         *
         * When set to //false//, the item is //always// expanded and the expander is
         * not shown. Please note that this will also affect the value returned by the
         * {@link Granite.Widgets.Sidebar.ExpandableItem.expanded} property.
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
         * @since 0.2
         */
        public bool collapsible { get; set; default = true; }

        /**
         * Whether the item is expanded or not.
         *
         * This property has no effect when {@link Granite.Widgets.Sidebar.ExpandableItem.collapsible}
         * is set to //false//.
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.collapsible
         * @since 0.2
         */
        private bool _expanded = false;
        public bool expanded {
            get { return _expanded || !collapsible; } // if not collapsible, always return true
            set {
                if (value != _expanded) {
                    _expanded = value;
                    toggled ();
                }
            }
        }

        /**
         * Number of children contained by the item.
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.get_children
         * @since 0.2
         */
        public uint n_children {
            get { return children.size; }
        }

        private Gee.Set<Item> children = new Gee.HashSet<Item> ();

        /**
         * Creates a new {@link Granite.Widgets.Sidebar.ExpandableItem}
         *
         * @param name Title of the item.
         * @return (transfer full) A new {@link Granite.Widgets.Sidebar.ExpandableItem}.
         * @since 0.2
         */
        public ExpandableItem (string name = "") {
            base (name);
            editable = false;
        }

        /**
         * Gets all the children of the item.
         *
         * @return (transfer full) Children.
         * @see Granite.Widgets.Sidebar.ExpandableItem.n_children
         * @since 0.2
         */
        public Gee.Set<Item> get_children () {
            var chilren_set = new Gee.HashSet<Item> ();
            var to_remove = new Gee.LinkedList<Item> ();

            foreach (var item in children) {
                if (item.parent == this)
                    chilren_set.add (item);
                else
                    to_remove.add (item);
            }

            foreach (var item in to_remove) {
                // Silently remove items that don't belong here
                children.remove (item);
            }

            return chilren_set;
        }

        /**
         * Adds an item.
         *
         * {@link Granite.Widgets.Sidebar.ExpandableItem.child_added} is fired after the item is added.
         *
         * While adding a child item, //the item it's being added to will set itself as the parent//.
         * Please note that items are required to have their //parent// property set to //null// before
         * being added, so make sure you remove the item from its previous parent before attempting
         * to add it to another item. For instance:
         * {{{
         * if (item.parent != null)
         *     item.parent.remove (item); // this will set item's parent to null
         * new_parent.add_item (item);
         * }}}
         *
         * @param item The item to add. Its parent __must__ be //null//.
         * @see Granite.Widgets.Sidebar.ExpandableItem.child_added
         * @see Granite.Widgets.Sidebar.ExpandableItem.remove_item
         * @since 0.2
         */
        public void add_item (Item item) requires (item.parent == null && !(item in children)) {
            item.parent = this;
            children.add (item);
            child_added (item);
        }

        /**
         * Removes an item.
         *
         * The {@link Granite.Widgets.Sidebar.ExpandableItem.child_removed} signal is fired
         * //after removing the item//. Finally (i.e. after all the handlers have been invoked),
         * the item's {@link Granite.Widgets.Sidebar.Item.parent} property is set to //null//.
         * This has the advantage of letting signal handlers know the parent from which //item//
         * is being removed.
         *
         * @param item The item to remove. This will fail if item has a different parent.
         * @see Granite.Widgets.Sidebar.ExpandableItem.child_removed
         * @see Granite.Widgets.Sidebar.ExpandableItem.clear
         * @since 0.2
         */
        public void remove_item (Item item) requires (item.parent == this && item in children) {
            children.remove (item);
            child_removed (item);
            item.parent = null;
        }

        /**
         * Removes all the items contained by the item. It works similarly to
         * {@link Granite.Widgets.Sidebar.ExpandableItem.remove_item}.
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.remove_item
         * @see Granite.Widgets.Sidebar.ExpandableItem.child_removed
         * @since 0.2
         */
        public void clear () {
            foreach (var item in get_children ())
                remove_item (item);
        }
    }



    /**
     * The model backing the Sidebar tree. It controls the visibility of the items.
     *
     * The FilteredDataModel controls the visibility of the items based on their "visible" property,
     * and also on their number of children, if they happen to be categories. It also offers an easy
     * interface for sorting, adding, removing and updating items, eliminating the need of repeatedly
     * dealing with the Gtk.TreeModel API directly.
     */
    private class FilteredDataModel : Gtk.TreeModelFilter {

        /**
         * An object that references a particular row in a model. This class is a wrapper built around
         * Gtk.TreeRowReference, and exists with the purpose of ensuring we never use invalid tree paths
         * or iters in the model, since most of these errors provoke failures due to GTK+ assertions
         * or, even worse, unexpected behavior.
         */
        private class NodeWrapper {

            /**
             * The actual reference to the node. If is is null, it is treated as invalid.
             */
            private Gtk.TreeRowReference? row_reference;

            /**
             * A newly-created Gtk.TreeIter pointing to the node if it exists; null otherwise.
             */
            public Gtk.TreeIter? iter {
                owned get {
                    Gtk.TreeIter? rv = null;

                    if (valid) {
                        var _path = this.path;
                        if (_path != null) {
                            Gtk.TreeIter _iter;
                            if (row_reference.get_model ().get_iter (out _iter, _path))
                                rv = _iter;
                        }
                    }

                    return rv;
                }
            }

            /**
             * A newly-created Gtk.TreePath pointing to the node if it exists; null otherwise.
             */
            public Gtk.TreePath? path {
                owned get {
                    return valid ? row_reference.get_path () : null;
                }
            }

            /**
             * Whether the node is valid or not. When it is not valid, no valid references are
             * returned by the object to avoid errors (null is returned instead).
             */
            public bool valid {
                get { return row_reference != null && row_reference.valid (); }
            }

            public NodeWrapper (Gtk.TreeModel model, Gtk.TreeIter iter) {
                row_reference = new Gtk.TreeRowReference (model, model.get_path (iter));
            }
        }

        private enum Column {
            ITEM,
            N_COLUMNS;

            public Type type () {
                switch (this) {
                    case ITEM:
                        return typeof (Item);
                    default:
                        assert_not_reached (); // a Type must be returned for every valid column
                }
            }
        }

        private enum SortColumn {
            UNSORTED = Gtk.SortColumn.UNSORTED,
            SORTED = Gtk.SortColumn.DEFAULT + 1
        }

        /**
         * This hashmap stores items and their respective child node references. For that reason, the
         * references it contains should only be used on the child_tree model, or converted to filter
         * iters/paths using convert_child_*_to_*() before using them with the filter (i.e. this) model.
         */
        private Gee.HashMap<Item, NodeWrapper> items = new Gee.HashMap<Item, NodeWrapper> ();

        private Gtk.TreeStore child_tree;
        private Sidebar.SortFunc? sort_func;
        private unowned Sidebar.VisibleFunc? filter_func;

        private SortColumn sort_column = SortColumn.UNSORTED;

        private Gtk.SortType sort_dir = Gtk.SortType.ASCENDING;
        public Gtk.SortType sort_direction {
            get { return sort_dir; }
            set { 
                sort_dir = value;
                child_tree.set_sort_column_id (this.sort_column, sort_dir);
            }
        }

        public FilteredDataModel () {
            var child_tree = new Gtk.TreeStore (Column.N_COLUMNS, Column.ITEM.type ());
            Object (child_model: child_tree, virtual_root: null);
            this.child_tree = child_tree;
            set_visible_func (filter_visible_func);
        }

        public bool has_item (Item item) {
            return items.has_key (item);
        }

        public void update_item (Item item) requires (has_item (item)) {
#if TRACE_SIDEBAR
            debug ("FilteredDataModel::update_item [%s]", item.name);
#endif
            // Emitting row_changed() for this item's row in the child model causes the filter
            // (i.e. this model) to re-evaluate whether a row is visible or not, calling
            // filter_visible_func for that row again, and that's exactly what we want.
            var node_reference = items.get (item);
            if (node_reference != null) {
                var path = node_reference.path;
                var iter = node_reference.iter;
                if (path != null && iter != null)
                    child_tree.row_changed (path, iter);
            }
        }

        public void add_item (Item item) requires (!has_item (item)) {
#if TRACE_SIDEBAR
            debug ("FilteredDataModel::add_item [%s]", item.name);
#endif
            // Try to find the parent. XXX If the parent is not found, and item.parent != null,
            // we should call add_item(item.parent) in order to add it prior to adding the child
            // item. This will be mandatory if Item::parent ever becomes writable from client code.
            // It is currently not needed because of the way the sidebar operates: it adds expandable
            // items first, and then their children.
            Gtk.TreeIter? parent_child_iter = null, child_iter;
            if (item.parent != null)
                parent_child_iter = get_item_child_iter (item.parent);

            child_tree.append (out child_iter, parent_child_iter);
            child_tree.set (child_iter, Column.ITEM, item, -1);

            items.set (item, new NodeWrapper (child_tree, child_iter));

            queue_parent_update (item.parent);
        }

        public void remove_item (Item item) requires (has_item (item)) {
#if TRACE_SIDEBAR
            debug ("FilteredDataModel::remove_item [%s]", item.name);
#endif
            // get_item_child_iter() depends on @items.get(item) for retrieving the right reference,
            // so don't unset the item from @items yet! We first get the child iter and then
            // unset the value.
            var child_iter = get_item_child_iter (item);

            // Now we remove the item from the table, because that way get_item_iter() and
            // all the methods that depend on it won't return invalid iters or items when
            // called. This is important because child_tree.remove() will emit row_deleted(),
            // and its handlers could potentially depend on one of the methods mentioned above.
            items.unset (item);

            if (child_iter != null) {
#if VALA_0_18
                // Workaround for a bug in valac that tries to pass an invalid pointer type
                // (GtkTreeIter** instead of GtkTreeIter*) to gtk_tree_store_remove() in the
                // generated C code. https://bugzilla.gnome.org/show_bug.cgi?id=685177
                Gtk.TreeIter iter = child_iter;

                child_tree.remove (ref iter);
#else
                child_tree.remove (child_iter);
#endif
            }

            queue_parent_update (item.parent);
        }

        /**
         * Queries the item's parent n_children property. In case it is zero, we update
         * the parent item's row in order to re-filter it, since empty empty expandable
         * items should not be displayed.
         */
        private void queue_parent_update (ExpandableItem? parent) {
            if (parent != null) {
                var path = get_item_path (parent);
                if (path != null && is_category (parent, null, path)) {
                    parent.ref ();
                    Idle.add_full (Priority.HIGH_IDLE, () => {
                        if (parent != null)
                            update_item (parent);

                        parent.unref ();
                        return false;
                    });
                }
            }
        }

        /**
         * Returns the Item pointed by iter, or null if the iter doesn't refer to a valid item.
         */
        public Item? get_item (Gtk.TreeIter iter) {
            Item? item;
            get (iter, Column.ITEM, out item, -1);
            return item;
        }

        /**
         * Returns the Item pointed by path, or null if the path doesn't refer to a valid item.
         */
        public Item? get_item_from_path (Gtk.TreePath path) {
            Gtk.TreeIter iter;
            if (get_iter (out iter, path))
                return get_item (iter);

            return null;
        }

        /**
         * Returns a newly-created Gtk.TreeIter pointing to the item, or null if a valid iter could
         * not be created.
         */
        public Gtk.TreeIter? get_item_iter (Item item) {
            Gtk.TreeIter? iter = null, child_iter = get_item_child_iter (item);

            // Now let's convert the child iter to a valid iter
            if (child_iter != null) {
                Gtk.TreeIter tmp_iter;
                if (convert_child_iter_to_iter (out tmp_iter, child_iter))
                    iter = tmp_iter;
            }

            return iter;
        }

        /**
         * Returns a newly-created path pointing to the item, or null in case a valid path
         * is not found.
         */
        public Gtk.TreePath? get_item_path (Item item) {
            Gtk.TreePath? path = null, child_path = get_item_child_path (item);

            // We want a filter path, not a child_model path
            if (child_path != null)
                path = convert_child_path_to_path (child_path);

            return path;
        }

        /**
         * Sets the sort function, or "unsets" it if null is passed. Please note though,
         * that unsetting the sort function doesn't bring the items back to their initial
         * order.
         */
        public void set_sort_func (owned Sidebar.SortFunc? sort_func) {
            this.sort_func = (owned) sort_func;
            this.sort_column = this.sort_func != null ?
                               SortColumn.SORTED : SortColumn.UNSORTED;

            child_tree.set_sort_func (SortColumn.SORTED, child_model_sort_func);
            sort_direction = sort_dir;
        }

        /**
         * External "extra" filter method.
         */
        public void set_filter_func (Sidebar.VisibleFunc? visible_func) {
            this.filter_func = visible_func;
        }

        /**
         * Checks whether an item is a category (i.e. a root-level expandable item).
         * The caller must pass an iter or path pointing to the item, but not both
         * (one of them must be null.)
         */
        public bool is_category (Item item, Gtk.TreeIter? iter, Gtk.TreePath? path = null) {
            bool is_category = false;
            // either iter or path has to be null
            if (item is ExpandableItem) {
                if (iter != null) {
                    assert (path == null);
                    is_category = is_iter_at_root_level (iter);
                } else {
                    assert (iter == null);
                    is_category = is_path_at_root_level (path);
                }
            }
            return is_category;
        }

        private bool is_iter_at_root_level (Gtk.TreeIter iter) {
            return is_path_at_root_level (get_path (iter));
        }

        private bool is_path_at_root_level (Gtk.TreePath path) {
            return path.get_depth () == 1;
        }

        /**
         * Actual sort function. It simply returns zero if sort_func is null.
         */
        private int child_model_sort_func (Gtk.TreeModel model, Gtk.TreeIter a, Gtk.TreeIter b) {
            // Return zero by default, since a different value would not be reflexive nor symmetric when
            // sort_func is null.
            int sort = 0;

            Item? item_a, item_b;
            child_tree.get (a, Column.ITEM, out item_a, -1);
            child_tree.get (b, Column.ITEM, out item_b, -1);

            if (sort_func != null && item_a != null && item_b != null)
                sort = sort_func (item_a, item_b);

            return sort;
        }

        private Gtk.TreeIter? get_item_child_iter (Item item) {
            Gtk.TreeIter? child_iter = null;

            var child_node_wrapper = items.get (item);
            if (child_node_wrapper != null)
                child_iter = child_node_wrapper.iter;

            return child_iter;
        }

        private Gtk.TreePath? get_item_child_path (Item item) {
            Gtk.TreePath? child_path = null;

            var child_node_wrapper = items.get (item);
            if (child_node_wrapper != null)
                child_path = child_node_wrapper.path;

            return child_path;
        }

        /**
         * Filters the child-tree items based on their "visible" property.
         */
        private bool filter_visible_func (Gtk.TreeModel child_model, Gtk.TreeIter iter) {
            bool item_visible = false;

            Item? item;
            child_tree.get (iter, Column.ITEM, out item, -1);

            if (item != null) {
               item_visible = item.visible;

                // If the item is a category, also query the number of visible child items
                // because empty categories should not be displayed.
                var expandable = item as ExpandableItem;
                if (expandable != null && child_tree.iter_depth (iter) == 0) {
                    uint n_visible_children = 0;
                    foreach (var child_item in expandable.get_children ()) {
                        if (child_item.visible)
                            n_visible_children++;
                    }
                    item_visible = item_visible && n_visible_children > 0;
                }
            }

            if (filter_func != null)
                item_visible = item_visible && filter_func (item);

            return item_visible;
        }
    }



    /**
     * Class responsible for rendering Item.icon and Item.activatable. It also
     * notifies about clicks through the activated() signal.
     */
    private class CellRendererIcon : Gtk.CellRendererPixbuf {
        public signal void activated (string path);

        private const Gtk.IconSize ICON_SIZE = Gtk.IconSize.MENU;

        public CellRendererIcon () {
            mode = Gtk.CellRendererMode.ACTIVATABLE;
            stock_size = ICON_SIZE;
            follow_state = true;
        }

        public override bool activate (Gdk.Event event, Gtk.Widget widget, string path,
                                       Gdk.Rectangle background_area, Gdk.Rectangle cell_area,
                                       Gtk.CellRendererState flags)
        {
            activated (path);
            return true;
        }
    }



    /**
     * The tree that actually displays the items.
     *
     * All the user interaction happens here.
     */
    private class Tree : Gtk.TreeView {

        public FilteredDataModel data_model { get; set; }

        public signal void item_selected (Item item);

        public Item? selected_item {
            get { return selected; }
            set { set_selected (value, true); }
        }

        public bool editing {
            get { return text_cell.editing; }
        }

        private enum Column {
            ITEM,
            N_COLS
        }

        private Item? selected;

        private Gtk.Entry? editable_entry;
        private Gtk.CellRendererText text_cell;
        private CellRendererIcon icon_cell;
        private CellRendererIcon activatable_cell;
        private CellRendererExpander primary_expander_cell;
        private CellRendererExpander secondary_expander_cell;

        public Tree (FilteredDataModel data_model) {
            this.data_model = data_model;
            set_model (data_model);

            halign = valign = Gtk.Align.FILL;
            expand = true;

            enable_search = false;
            headers_visible = false;
            enable_grid_lines = Gtk.TreeViewGridLines.NONE;

            // Deactivate GtkTreeView's built-in expander functionality
            expander_column = null;
            show_expanders = false;

            var item_column = new Gtk.TreeViewColumn ();
            item_column.expand = true;

            insert_column (item_column, Column.ITEM);

            // First expander. Used for normal expandable items
            primary_expander_cell = new CellRendererExpander ();
            primary_expander_cell.toggled.connect (on_expander_toggled);
            primary_expander_cell.xpad = 7;
            primary_expander_cell.xalign = 0.0f;
            item_column.pack_start (primary_expander_cell, false);
            item_column.set_cell_data_func (primary_expander_cell, expander_cell_data_func);

            icon_cell = new CellRendererIcon ();
            item_column.pack_start (icon_cell, false);
            item_column.set_cell_data_func (icon_cell, icon_cell_data_func);

            text_cell = new Gtk.CellRendererText ();
            text_cell.editable_set = true;
            text_cell.editable = false;
            text_cell.editing_started.connect (on_editing_started);
            text_cell.editing_canceled.connect (on_editing_canceled);
            text_cell.ellipsize = Pango.EllipsizeMode.END;
            text_cell.xpad = 3;
            text_cell.xalign = 0.0f;
            item_column.pack_start (text_cell, true);
            item_column.set_cell_data_func (text_cell, name_cell_data_func);

            activatable_cell = new CellRendererIcon ();
            activatable_cell.activated.connect (on_activatable_activated);
            item_column.pack_start (activatable_cell, false);
            item_column.set_cell_data_func (activatable_cell, icon_cell_data_func);

            // Second expander. Used for main categories
            secondary_expander_cell = new CellRendererExpander ();
            secondary_expander_cell.xpad = 3;
            secondary_expander_cell.toggled.connect (on_expander_toggled);
            item_column.pack_start (secondary_expander_cell, false);
            item_column.set_cell_data_func (secondary_expander_cell, expander_cell_data_func);

            // Selection
            var selection = get_selection ();
            selection.mode = Gtk.SelectionMode.BROWSE;
            selection.set_select_function (select_func);

            var style_context = get_style_context ();
            style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);
            style_context.changed.connect (compute_indentation);

            compute_indentation ();
        }

        ~Tree () {
            text_cell.editing_started.disconnect (on_editing_started);
            text_cell.editing_canceled.disconnect (on_editing_canceled);
            primary_expander_cell.toggled.disconnect (on_expander_toggled);
            secondary_expander_cell.toggled.disconnect (on_expander_toggled);
        }

        /**
         * Sets the ideal level indentation.
         */
        private void compute_indentation () {
            int expander_width = get_cell_width (primary_expander_cell);

            int left_padding;
            style_get ("horizontal-separator", out left_padding);

            level_indentation = expander_width + left_padding;
        }

        private int get_cell_width (Gtk.CellRenderer cell_renderer) {
            Gtk.Requisition min_req;
            cell_renderer.get_preferred_size (this, out min_req, null);
            return min_req.width;
        }

        /**
         * Evaluates whether the item at the specified path can be selected or not.
         */
        private bool select_func (Gtk.TreeSelection selection, Gtk.TreeModel model,
                                  Gtk.TreePath path, bool path_currently_selected)
        {
            bool selectable = false;
            var item = data_model.get_item_from_path (path);

            if (item != null) {
                // Main categories ARE NOT selectable, so check for that
                if (!data_model.is_category (item, null, path))
                    selectable = item.selectable;
            }

            return selectable;
        }

        private Gtk.TreePath? get_selected_path () {
            Gtk.TreePath? selected_path = null;
            Gtk.TreeSelection? selection = get_selection ();

            if (selection != null) {
                Gtk.TreeModel? model;
                var selected_rows = selection.get_selected_rows (out model);
                if (selected_rows.length () == 1)
                    selected_path = selected_rows.nth_data (0);
            }

            return selected_path;
        }

        private void set_selected (Item? item, bool scroll_to_item) {
            var selection = get_selection ();

            // Initial test
            if (item == null || !item.selectable) {
                selection.unselect_all ();
            } else if (item != null) {
                if (scroll_to_item)
                    this.scroll_to_item (item);

                var to_select = data_model.get_item_iter (item);

                if (to_select != null)
                    selection.select_iter (to_select);
            }
        }

        public override void cursor_changed () {
            var path = get_selected_path ();

            if (path != null) {
                var item = data_model.get_item_from_path (path);
                if (item != null && item != this.selected && item.selectable) {
                    this.selected = item;
                    item_selected (item);
                }
            }
        }

        public bool scroll_to_item (Item item) {
            bool scrolled = false;

            // Try to scroll to the respective cell
            var path = data_model.get_item_path (item);
            if (path != null) {
                scroll_to_cell (path, null, false, 0, 0);
                scrolled = true;
            }

            return scrolled;
        }

        public bool start_editing_item (Item item) requires (item.editable) {
            var path = data_model.get_item_path (item);
            if (path != null) {
                text_cell.editable = true;
                set_cursor_on_cell (path, get_column (Column.ITEM), text_cell, true);
                return true;
            } else {
                warning ("Could not edit \"%s\": path not found", item.name);
            }

            return false;
        }

        private void on_editing_started (Gtk.CellEditable editable, string path) {
            editable_entry = editable as Gtk.Entry;
            if (editable_entry != null) {
                editable_entry.editing_done.connect (on_editing_done);
                editable_entry.editable = true;
            }
        }

        private void on_editing_canceled () {
            if (editable_entry != null) {
                editable_entry.editable = false;
                editable_entry.editing_done.disconnect (on_editing_done);
            }

            text_cell.editable = false;
        }

        private void on_editing_done () {
            // Same actions as when cancelling editing
            on_editing_canceled ();

            if (selected_item != null && selected_item.editable && editable_entry != null)
                selected_item.edited (editable_entry.get_text ());
        }

        private void on_activatable_activated (string item_path_str) {
            var item = get_item_from_path_string (item_path_str);
            if (item != null)
                item.action_activated ();
        }

        private void on_expander_toggled (string item_path_str) {
            var item = get_item_from_path_string (item_path_str) as ExpandableItem;
            if (item != null)
                item.expanded = !item.expanded;
        }

        private Item? get_item_from_path_string (string item_path_str) {
            var item_path = new Gtk.TreePath.from_string (item_path_str);
            return data_model.get_item_from_path (item_path);
        }

        /**
         * Updates the tree to reflect the ''expanded'' property of expandable_item.
         */
        public void update_expansion (ExpandableItem expandable_item) {
            var path = data_model.get_item_path (expandable_item);

            if (path != null) {
                if (expandable_item.expanded)
                    expand_row (path, false);
                else
                    collapse_row (path);
            }
        }

        public override void row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
            if (column == get_column (Column.ITEM)) {
                var item = data_model.get_item_from_path (path);
                if (item != null)
                    item.activated ();
            }
        }

        public override bool key_release_event (Gdk.EventKey event) {
           if (selected_item != null) {
                switch (event.keyval) {
                    case Gdk.Key.F2:
                       var modifiers = Gtk.accelerator_get_default_mod_mask ();
                        // try to start editing selected item
                        if ((event.state & modifiers) == 0 && selected_item.editable)
                            start_editing_item (selected_item);
                        break;
                }
            }

            return base.key_release_event (event);
        }

        public override bool button_press_event (Gdk.EventButton event) {
            Gtk.TreePath path;
            Gtk.TreeViewColumn column;

            int x = (int) event.x, y = (int) event.y, cell_x, cell_y;

            if (get_path_at_pos (x, y, out path, out column, out cell_x, out cell_y)) {
                var item = data_model.get_item_from_path (path);

                if (item != null) {
                    // This is implemented in C as a union, so there's no other way around than doing
                    // pointer casting when working from Vala.
                    var ev = (Gdk.Event*) (&event);

                    if (ev->triggers_context_menu ()) {
                        popup_context_menu (item, event);
                    } else if (event.button == Gdk.BUTTON_PRIMARY) {
                        if (event.type == Gdk.EventType.2BUTTON_PRESS && item.editable)
                            return start_editing_item (item);

                        // toggle item expansion if the item is a category
                        if (data_model.is_category (item, null, path)) {
                            var category = item as ExpandableItem;
                            category.expanded = !category.expanded;
                            return true;
                        }
                    }
                }
            }

            return base.button_press_event (event);
        }

        public override bool popup_menu () {
            return popup_context_menu (null, null);
        }

        private bool popup_context_menu (Item? item, Gdk.EventButton? event) {
            if (item == null)
                item = selected_item;

            if (item == null)
                return false;

            var time = (event != null) ? event.time : Gtk.get_current_event_time ();
            var button = (event != null) ? event.button : 0;

            var menu = item.get_context_menu ();

            if (menu != null) {
                menu.attach_to_widget (this, null);

                if (event != null) {
                    menu.popup (null, null, null, button, time);
                } else {
                    menu.popup (null, null, menu_position_func, button, time);
                    menu.select_first (false);
                }

                return true;
            }

            return false;
        }

        /**
         * Positions a menu based on an item's coordinates.
         *
         * As this function is only used for menu popups triggered by events other than button
         * presses (e.g. key-press events), it assumes that the item in question is the one
         * currently selected, since those events provide no coordinates.
         */
        private void menu_position_func (Gtk.Menu menu, out int x, out int y, out bool push_in) {
            push_in = true;
            x = y = 0;

            if (selected_item == null)
                return;

            var path = data_model.get_item_path (selected_item);
            if (path == null || !get_realized ())
                return;

            get_window ().get_origin (out x, out y);

            // Try to find the position of the item
            Gdk.Rectangle item_bin_coords;
            get_cell_area (path, get_column (Column.ITEM), out item_bin_coords);

            int item_y = item_bin_coords.y + item_bin_coords.height / 2;
            int item_x = item_bin_coords.x;

            bool is_rtl = get_direction () == Gtk.TextDirection.RTL;

            if (!is_rtl)
                item_x += item_bin_coords.width - 20;

            int widget_x, widget_y;
            convert_bin_window_to_widget_coords (item_x, item_y, out widget_x, out widget_y);

            x += widget_x.clamp (0, get_allocated_width ());
            y += widget_y.clamp (0, get_allocated_height ());

            if (is_rtl) {
                Gtk.Requisition menu_req;
                menu.get_preferred_size (out menu_req, null);
                y -= menu_req.width;
            }
        }

        private static Item? get_item_from_model (Gtk.TreeModel model, Gtk.TreeIter iter) {
            var data_model = model as FilteredDataModel;
            assert (data_model != null);
            return data_model.get_item (iter);
        }

        private void name_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                          Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var text_renderer = renderer as Gtk.CellRendererText;
            assert (text_renderer != null);

            string text = "";
            var weight = Pango.Weight.NORMAL;

            var item = get_item_from_model (model, iter);
            if (item != null) {
                text = item.name;

                if (data_model.is_category (item, iter))
                    weight = Pango.Weight.BOLD;
            }

            text_renderer.weight = weight;
            text_renderer.text = text;
        }

        private void icon_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                          Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var icon_renderer = renderer as CellRendererIcon;
            assert (icon_renderer != null);

            bool visible = false;
            Icon? icon = null;

            var item = get_item_from_model (model, iter);
            if (item != null) {
                // Icons are not displayed for main categories
                visible = !data_model.is_category (item, iter);

                if (visible) {
                    if (icon_renderer == icon_cell)
                        icon = item.icon;
                    else if (icon_renderer == activatable_cell)
                        icon = item.activatable;
                    else
                        assert_not_reached ();
                }
            }

            visible = visible && icon != null;

            icon_renderer.visible = visible;
            icon_renderer.gicon = visible ? icon : null;
        }

        private void expander_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                              Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var expander_renderer = renderer as CellRendererExpander;
            assert (expander_renderer != null);

            bool expander_visible = false, primary_expander_visible = false;

            var item = get_item_from_model (model, iter);
            if (item != null) {
                var expandable_item = item as ExpandableItem;
                if (expandable_item != null) {
                    expander_visible = expandable_item.collapsible;

                    // Decide which expander to show based on whether the item is a main
                    // category or not. For main categories, we show the expander on the right.
                    if (expander_visible)
                        primary_expander_visible = !data_model.is_category (expandable_item, iter);
                }
            }

            // For the primary expander, we only make the arrow invisible in order to avoid messing up
            // the item alignment (because that will keep the cell's allocated area). For the secondary
            // expander that's not important, and thus we simply hide the entire cell renderer.
            primary_expander_cell.arrow_visible = expander_visible && primary_expander_visible;
            secondary_expander_cell.visible = expander_visible && !primary_expander_visible;
        }
    }



    /**
     * Emitted when the sidebar selection changes.
     *
     * @param item Selected item.
     * @since 0.2
     */
    public virtual signal void item_selected (Item? item) { }

    /**
     * A {@link Granite.Widgets.Sidebar.SortFunc} should return a negative integer, zero, or a
     * positive integer if ''a'' sorts //before// ''b'', ''a'' sorts //with// ''b'', or ''a'' sorts
     * //after// ''b'' respectively. If two items compare as equal, their order in the sorted
     * sidebar is undefined.
     *
     * In order to ensure that the sidebar behaves as expected, the {@link Granite.Widgets.Sidebar.SortFunc}
     * must define a partial order on the sidebar tree; i.e. it must be reflexive, antisymmetric and
     * transitive.
     *
     * (Same description as {@link Gtk.TreeIterCompareFunc}.)
     *
     * @param a First item.
     * @param b Second item.
     * @return A //negative// integer if //a// sorts after //b//, //zero// if //a// equals //b//,
     *         or a //positive// integer if //a// sorts before //b//.
     * @since 0.2
     */
    public delegate int SortFunc (Item a, Item b);

    /**
     * A {@link Granite.Widgets.Sidebar.VisibleFunc} should return true if the item should be 
     * visible, false otherwise.
     *
     * IMPORTANT NOTE: This method ''must not'' modify the item's //visible// property. Also,
     * if the item //visible// property is set to //false//, the item won't be displayed even
     * if this method returns true.
     *
     * @param item Item to be checked.
     * @since 0.2
     */
    public delegate bool VisibleFunc (Item item);

    /**
     * Root-level expandable item.
     *
     * This item contains the first-level sidebar items. It //only serves as an item container//.
     * It is used to add and remove items to/from the widget.
     *
     * Internally, it allows the sidebar to connect to its {@link Granite.Widgets.Sidebar.ExpandableItem.child_added}
     * and {@link Granite.Widgets.Sidebar.ExpandableItem.child_removed} signals in order to monitor
     * new children additions/removals.
     *
     * @since 0.2
     */
    public ExpandableItem root { get; private set; default = new ExpandableItem ("ROOT"); }

    /**
     * The current selected item.
     *
     * @since 0.2
     */
    public Item? selected {
        get { return tree.selected_item; }
        set { tree.selected_item = value; }
    }

    /**
     * Whether an item is being edited.
     *
     * @see Granite.Widgets.Sidebar.start_editing_item
     * @since 0.2
     */
    public bool editing {
        get { return tree.editing; }
    }

    /**
     * Sort direction to use along with the sort function.
     *
     * @see Granite.Widgets.Sidebar.set_sort_func
     * @since 0.2
     */
    public Gtk.SortType sort_direction {
        get { return data_model.sort_direction; }
        set { data_model.sort_direction = value; }
    }

    private Tree tree;
    private FilteredDataModel data_model { get { return tree.data_model; } }

    /**
     * Creates a new {@link Granite.Widgets.Sidebar}.
     *
     * @return (transfer full) a new {@link Granite.Widgets.Sidebar}.
     * @since 0.2
     */
    public Sidebar () {
        var model = new FilteredDataModel ();

        push_composite_child ();
        tree = new Tree (model);
        tree.set_composite_name ("treeview");
        pop_composite_child ();

        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        add (tree);
        show_all ();

        tree.item_selected.connect ( (item) => item_selected (item) );

        // Initialize item monitor
        root.child_added.connect (add_item);
        root.child_removed.connect (remove_item);
    }

    /**
     * Checks whether //item// is part of the sidebar.
     *
     * @param item The item to query.
     * @return //true// if the item belongs to the sidebar; //false// otherwise.
     * @since 0.2
     */
    public bool has_item (Item item) {
        return data_model.has_item (item);
    }

    /**
     * Sets the method used for sorting items.
     *
     * @param sort_func The method to use for sorting items.
     * @see Granite.Widgets.Sidebar.SortFunc
     * @since 0.2
     */
    public void set_sort_func (owned SortFunc? sort_func) {
        data_model.set_sort_func ((owned) sort_func);
    }

    /**
     * Sets the method used for filtering out items.
     *
     * @param visible_func The method to use for filtering items.
     * @param refilter whether to call {@link Sidebar.refilter} using the new function.
     * @see Granite.Widgets.Sidebar.VisibleFunc
     * @since 0.2
     */
    public void set_filter_func (VisibleFunc? visible_func, bool refilter) {
        data_model.set_filter_func (visible_func);
        if (refilter)
            this.refilter ();
    }

    /**
     * Traverses the tree hiding each item if it is to be hidden based on the passed VisibleFunc
     *
     * @see Granite.Widgets.Sidebar.VisibleFunc
     * @see Granite.Widgets.Sidebar.set_visible_func
     * @since 0.2
     */
    public void refilter () {
        data_model.refilter ();
    }

    /**
     * If //item// is editable, this activates the editor; otherwise, it does nothing. If an item
     * was already being edited, this will fail.
     *
     * @param item Item to edit.
     * @see Granite.Widgets.Sidebar.Item.editable
     * @see Granite.Widgets.Sidebar.editing
     * @return true if the editing started sucessfully; false otherwise.
     * @since 0.2
     */
    public bool start_editing_item (Item item) requires (item.editable)
                                               requires (has_item (item))
    {
        return tree.start_editing_item (item);
    }

    /**
     * Recursively expands all the expandable items.
     *
     * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
     * @since 0.2
     */
    public void expand_all () {
        expand_with_children (root, true);
    }

    /**
     * Recursively collapses all the collapsible (expandable) items.
     *
     * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
     * @see Granite.Widgets.Sidebar.ExpandableItem.collapsible
     * @since 0.2
     */
    public void collapse_all () {
        expand_with_children (root, false);
    }

    /**
     * Recursively sets the {@link Granite.Widgets.Sidebar.ExpandableItem.expanded} property
     * of //expandable_item// and its child expandable items to the value specified, so this can
     * be used for both expanding and collapsing.
     *
     * @param expandable_item ExpandableItem where expansion begins.
     * @param expand Whether expandable items will be expanded or collapsed.
     * @since 0.2
     */
    public void expand_with_children (ExpandableItem expandable_item, bool expand) {
        expandable_item.expanded = expand;

        foreach (var item in expandable_item.get_children ()) {
            var child_expandable_item = item as ExpandableItem;
            if (child_expandable_item != null)
                expand_with_children (child_expandable_item, expand);
        }
    }

    /**
     * Recursively sets the {@link Granite.Widgets.Sidebar.ExpandableItem.expanded} property
     * of //expandable_item// and its parent expandable items to the value specified, so this can
     * be used for both expanding and collapsing.
     *
     * @param expandable_item ExpandableItem where expansion begins.
     * @param expand Whether expandable items will be expanded or collapsed.
     * @since 0.2
     */
    public void expand_with_parents (ExpandableItem expandable_item, bool expand) {
        expandable_item.expanded = expand;

        var parent = expandable_item.parent;
        if (parent != null && parent != this.root)
            expand_with_parents (parent, expand);
    }

    /**
     * Scrolls the sidebar tree to make //item// visible.
     *
     * If //expand_parents// is //true//, {@link Sidebar.expand_with_parents} is called for the
     * item's parent, to make sure it's not obscured behind a collapsed group.
     *
     * @param item Item to scroll to.
     * @param expand_parents Whether to expand item's parent expandable items in case they are collapsed.
     * @return //true// if successful; //false// otherwise.
     * @since 0.2
     */
    public bool scroll_to_item (Item item, bool expand_parents = true) requires (has_item (item)) {
        if (expand_parents && item.parent != null)
            expand_with_parents (item.parent, true);

        return tree.scroll_to_item (item);
    }

    /**
     * Adds an item in response to the {@link Granite.Widgets.Sidebar.ExpandableItem.child_added}
     * signal.
     *
     * This method is recursively signaled. While it is first emitted in response to the
     * root's child_added() signal, successive calls are fired by child expandable items,
     * since we set this method as handler for their child_added() signal. In fact, all the
     * item monitors are connected here, and disconnected in remove_item().
     */
    private void add_item (Item item) requires (!has_item (item)) {
        data_model.add_item (item);

        // Monitor object properties
        item.changed.connect (on_item_property_changed);

        // If it's an expandable item, also add children
        var expandable_item = item as ExpandableItem;
        if (expandable_item != null) {
            tree.update_expansion (expandable_item);

            foreach (var child in expandable_item.get_children ()) {
                // This will always be faster than the normal recursive implementation
                Idle.add_full (Priority.HIGH_IDLE, () => {
                    add_item (child);
                    return false;
                });
            }

            expandable_item.child_added.connect (add_item);
            expandable_item.child_removed.connect (remove_item);
        }
    }

    /**
     * Removes an item in response to the {@link Granite.Widgets.Sidebar.ExpandableItem.child_removed}
     * signal.
     *
     * This method also disconnects the handlers set by add_item().
     */
    private void remove_item (Item item) requires (has_item (item)) {
        // Disconnect everything we connected in add_item()
        item.changed.disconnect (on_item_property_changed);

        var expandable_item = item as ExpandableItem;
        if (expandable_item != null) {
            expandable_item.child_added.disconnect (add_item);
            expandable_item.child_removed.disconnect (remove_item);
        }

        data_model.remove_item (item);
    }

    /**
     * Updates an item in response to the {@link Granite.Widgets.Sidebar.Item.changed} signal.
     */
    private void on_item_property_changed (Item item, string prop) requires (has_item (item)) {
        if (prop == "parent") // Currently only handled by add_item() and remove_item()
            return;

        data_model.update_item (item);

        var expandable_item = item as ExpandableItem;
        if (expandable_item != null)
            tree.update_expansion (expandable_item);
    }
}
