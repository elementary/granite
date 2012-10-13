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
 * library_category.add (music_item);
 *
 * // We plan to add sub-items to the store, so let's use an expandable item
 * var my_store_item = new Granite.Widgets.Sidebar.ExpandableItem ("My Store");
 * store_category.add (my_store_item);
 *
 * var my_store_podcast_item = new Granite.Widgets.Sidebar.Item ("Podcasts");
 * var my_store_music_item = new Granite.Widgets.Sidebar.Item ("Music");
 *
 * my_store_item.add (my_store_music_item);
 * my_store_item.add (my_store_podcast_item);
 *
 * var player1_item = new Granite.Widgets.Sidebar.Item ("Player 1");
 * var player2_item = new Granite.Widgets.Sidebar.Item ("Player 2");
 *
 * device_category.add (player1_item);
 * device_category.add (player2_item);
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
 * root.add (library_category);
 * root.add (store_category);
 * root.add (device_category);
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
     *   - name          | DataModel::on_item_prop_changed   | Tree::name_cell_data_func
     *   - editable      | DataModel::on_item_prop_changed   | Queried when needed (See Tree::start_editing_item)
     *   - visible       | DataModel::on_item_prop_changed   | DataModel::filter_visible_func
     *   - icon          | DataModel::on_item_prop_changed   | Tree::icon_cell_data_func
     *   - activatable   | Same as @icon                     | Same as @icon
     * + ExpandableItem  |                                   |
     *   - no_caption    | DataModel::on_item_prop_changed   | Tree::name_cell_data_func
     *   - collapsible   | DataModel::on_item_prop_changed   | Tree::update_expansion
     *                   |                                   | Tree::expander_cell_data_func
     *   - expanded      | Same as @collapsible              | Same as @collapsible
     * ---------------------------------------------------------------------------------------------
     * * Only automatic properties are monitored. ExpandableItem's additions/removals are handled by
     *   Sidebar::add_item() and Sidebar::remove_item()
     *
     * Other features:
     * - Sorting: this happens on the tree-model level. See DataModel and Sidebar::SortFunc.
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
         * Emitted when the user has finished editing the item's name.
         *
         * By default, if the name doesn't consist of white space, it is automatically assigned
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
         * the F2 key, or by double-clicking over an item.
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
         * @see Granite.Widgets.Sidebar.ExpandableItem.add
         * @since 0.2
         */
        public signal void child_added (Item item);

        /**
         * Emitted when an item is removed.
         *
         * @param item Item removed.
         * @see Granite.Widgets.Sidebar.ExpandableItem.remove
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
         * The sidebar widget will obey the value of this property when possible.
         *
         * This property has no effect when {@link Granite.Widgets.Sidebar.ExpandableItem.collapsible}
         * is set to //false//. Also keep in mind that, __when set to //true//__, this property
         * doesn't always represent the actual expanded state of an item. For example, it might
         * be the case that an expandable item is collapsed because it has zero visible children,
         * but its //expanded// property value is still //true//; in such case, once one of the
         * item's children becomes visible, the item will be expanded again. Same applies to items
         * hidden behind a collapsed parent item.
         *
         * If obtaining the ''actual'' expanded state of an item is important to your needs,
         * use {@link Granite.Widgets.Sidebar.is_item_expanded} instead.
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.collapsible
         * @see Granite.Widgets.Sidebar.is_item_expanded
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
         * new_parent.add (item);
         * }}}
         *
         * @param item The item to add. Its parent __must__ be //null//.
         * @see Granite.Widgets.Sidebar.ExpandableItem.child_added
         * @see Granite.Widgets.Sidebar.ExpandableItem.remove
         * @since 0.2
         */
        public void add (Item item) requires (item.parent == null && !(item in children)) {
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
        public void remove (Item item) requires (item.parent == this && item in children) {
            children.remove (item);
            child_removed (item);
            item.parent = null;
        }

        /**
         * Removes all the items contained by the item. It works similarly to
         * {@link Granite.Widgets.Sidebar.ExpandableItem.remove}.
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.remove
         * @see Granite.Widgets.Sidebar.ExpandableItem.child_removed
         * @since 0.2
         */
        public void clear () {
            foreach (var item in get_children ())
                remove (item);
        }

        /**
         * Expands the item and/or its children.
         *
         * @param inclusive Whether to also expand this item (true), or only its children (false).
         * @param recursive Whether to recursively expand all the children (true), or only
         * immediate children (false).
         * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
         * @since 0.2
         */
        public void expand_all (bool inclusive = true, bool recursive = true) {
            set_expansion (this, inclusive, recursive, true);
        }

        /**
         * Collapses the item and/or its children.
         *
         * @param inclusive Whether to also collapse this item (true), or only its children (false).
         * @param recursive Whether to recursively collapse all the children (true), or only
         * immediate children (false). The latter case might appear contradictory, given that collapsing
         * immediate children will also //visually// collapse non-immediate children, but it makes total
         * sense once you've understood what the {@link Granite.Widgets.Sidebar.ExpandableItem.expanded}
         * property actually means. If you set //recursive// to //true,// the non-immediate children's
         * //expanded// property will be set to //false//, and therefore they will __stay collapsed__
         * the next time their parents are expanded; otherwise (i.e. if //recursive// is //false//),
         * __their previous expansion state will be restored__ once their parents are expanded again.
         * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
         * @since 0.2
         */
        public void collapse_all (bool inclusive = true, bool recursive = true) {
            set_expansion (this, inclusive, recursive, false);
        }

        private static void set_expansion (ExpandableItem item, bool inclusive, bool recursive, bool expanded) {
            if (inclusive)
                item.expanded = expanded;

            foreach (var child_item in item.get_children ()) {
                var child_expandable_item = child_item as ExpandableItem;
                if (child_expandable_item != null) {
                    if (recursive)
                        set_expansion (child_expandable_item, true, true, expanded);
                    else
                        child_expandable_item.expanded = expanded;
                }
            }
        }

        /**
         * Recursively expands the item along with its parent(s).
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
         * @since 0.2
         */
        public void expand_with_parents () {
            // Update parent items first due to GtkTreeView's working internals:
            // Expanding children before their parents would not always work, because
            // they could be obscured behind a collapsed row by the time the treeview
            // tries to expand them, obviously failing.
            if (parent != null)
                parent.expand_with_parents ();
            expanded = true;
        }

        /**
         * Recursively collapses the item along with its parent(s).
         *
         * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
         * @since 0.2
         */
        public void collapse_with_parents () {
            if (parent != null)
                parent.collapse_with_parents ();
            expanded = false;
        }
    }



    /**
     * The model backing the Sidebar tree. It controls the visibility of the items.
     *
     * The DataModel controls the visibility of the items based on their "visible" property,
     * and also on their number of children, if they happen to be categories. It also offers an easy
     * interface for sorting, adding, removing and updating items, eliminating the need of repeatedly
     * dealing with the Gtk.TreeModel API directly.
     */
    private class DataModel : Gtk.TreeModelFilter {

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
                owned get { return valid ? row_reference.get_path () : null; }
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

        /**
         * Helper object used to monitor item property changes.
         */
        private class ItemMonitor {
            public signal void changed (Item self, string prop_name);
            private Item item;

            public ItemMonitor (Item item) {
                this.item = item;
                item.notify.connect_after (on_notify);
            }

            ~ItemMonitor () {
                item.notify.disconnect (on_notify);
            }

            private void on_notify (ParamSpec prop) {
                changed (item, prop.name);
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

        public signal void item_updated (Item item);

        /**
         * Used by push_parent_update() as key to associate the respective data to the objects.
         */
        private const string ITEM_PARENT_NEEDS_UPDATE = "item-parent-needs-update";

        /**
         * This hash map stores items and their respective child node references. For that reason, the
         * references it contains should only be used on the child_tree model, or converted to filter
         * iters/paths using convert_child_*_to_*() before using them with the filter (i.e. this) model.
         */
        private Gee.HashMap<Item, NodeWrapper> items = new Gee.HashMap<Item, NodeWrapper> ();

        private Gee.HashMap<Item, ItemMonitor> monitors = new Gee.HashMap<Item, ItemMonitor> ();

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

        public DataModel () {
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
            debug ("DataModel::update_item [%s]", item.name);
#endif
            // Emitting row_changed() for this item's row in the child model causes the filter
            // (i.e. this model) to re-evaluate whether a row is visible or not, calling
            // filter_visible_func for that row again, and that's exactly what we want.
            var node_reference = items.get (item);
            if (node_reference != null) {
                var path = node_reference.path;
                var iter = node_reference.iter;
                if (path != null && iter != null) {
                    child_tree.row_changed (path, iter);
                    item_updated (item);
                }
            }
        }

        public void add_item (Item item) requires (!has_item (item)) {
#if TRACE_SIDEBAR
            debug ("DataModel::add_item [%s]", item.name);
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

            // This is equivalent to a property change. The tree still needs to update
            // the some of the new item's properties through this signal's handler.
            item_updated (item);
            add_property_monitor (item);
            push_parent_update (item.parent);
        }

        public void remove_item (Item item) requires (has_item (item)) {
#if TRACE_SIDEBAR
            debug ("DataModel::remove_item [%s]", item.name);
#endif
            remove_property_monitor (item);

            // get_item_child_iter() depends on @items.get(item) for retrieving the right reference,
            // so don't unset the item from @items yet! We first get the child iter and then
            // unset the value.
            var child_iter = get_item_child_iter (item);

            // Now we remove the item from the table, because that way get_item_child_iter() and
            // all the methods that depend on it won't return invalid iters or items when
            // called. This is important because child_tree.remove() will emit row_deleted(),
            // and its handlers could potentially depend on one of the methods mentioned above.
            items.unset (item);

            if (child_iter != null) {
#if VALA_0_18
                // Workaround for a bug in valac 0.18 that tries to pass an invalid pointer type
                // (GtkTreeIter** instead of GtkTreeIter*) to gtk_tree_store_remove() in the
                // generated C code. https://bugzilla.gnome.org/show_bug.cgi?id=685177
                Gtk.TreeIter iter = child_iter;

                child_tree.remove (ref iter);
#else
                child_tree.remove (child_iter);
#endif
            }

            push_parent_update (item.parent);
        }

        private void add_property_monitor (Item item) {
            var wrapper = new ItemMonitor (item);
            monitors[item] = wrapper;
            wrapper.changed.connect (on_item_prop_changed);
        }

        private void remove_property_monitor (Item item) {
            // Disconnect everything we connected in add_property_monitor()
            var wrapper = monitors[item];
            if (wrapper != null)
                wrapper.changed.disconnect (on_item_prop_changed);
            monitors.unset (item);
        }

        private void on_item_prop_changed (Item item, string prop_name) {
            // the parent property is currently only handled by ExpandableItem.add() and
            // ExpandableItem.remove(), which also emit child_added() and child_removed(),
            // so we don't monitor this specific property. There are further comments on
            // this topic in DataModel.add_item()
            if (prop_name != "parent")
                update_item (item);
        }

        /**
         * Pushes a call to update_item() if //parent// is not //null//.
         *
         * This is needed because the visibility of categories depends on their n_children property,
         * and also because item expansion should be updated after adding or removing items.
         * If many updates are pushed, and the item has still not been updated, only one is processed.
         * This guarantees efficiency as updating a category item could trigger expensive actions.
         */
        private void push_parent_update (ExpandableItem? parent) {
           if (parent != null) {
                bool needs_update = parent.get_data<bool> (ITEM_PARENT_NEEDS_UPDATE);

                // If an update is already waiting to be processed, just return, as we
                // don't need to queue another one for the same item.
                if (needs_update)
                    return;

                var path = get_item_path (parent);

                if (path != null) {
                    // Let's mark this item for update
                    parent.set_data<bool> (ITEM_PARENT_NEEDS_UPDATE, true);

                    Idle.add (() => {
                        if (parent != null) {
                            update_item (parent);

                            // Already updated. No longer needs an update.
                            parent.set_data<bool> (ITEM_PARENT_NEEDS_UPDATE, false);
                        }

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
            this.sort_column = this.sort_func != null ? SortColumn.SORTED : SortColumn.UNSORTED;

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

        public bool is_iter_at_root_level (Gtk.TreeIter iter) {
            return is_path_at_root_level (get_path (iter));
        }

        public bool is_path_at_root_level (Gtk.TreePath path) {
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

        public DataModel data_model { get; set; }

        public signal void item_selected (Item? item);

        public Item? selected_item {
            get { return selected; }
            set { set_selected (value, true); }
        }

        public bool editing {
            get { return text_cell.editing; }
        }

        public Pango.EllipsizeMode ellipsize_mode {
            get { return text_cell.ellipsize; }
            set { text_cell.ellipsize = value; }
        }

        private enum Column {
            ITEM,
            N_COLS
        }

        // Extra horizontal space added between the expanders and items.
        private const uint PRIMARY_EXPANDER_PADDING = 6;
        private const uint SECONDARY_EXPANDER_PADDING = 3;

        private Item? selected;
        private unowned Item? edited;

        private Gtk.Entry? editable_entry;
        private Gtk.CellRendererText text_cell;
        private CellRendererIcon icon_cell;
        private CellRendererIcon activatable_cell;
        private CellRendererExpander primary_expander_cell;
        private CellRendererExpander secondary_expander_cell;
        private CellRendererExpander root_spacer_cell;

        public Tree (DataModel data_model) {
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

            // Root-level item spacer. It is supposed to only add padding. As this is
            // an expander renderer, it has the nice advantage of adjusting the padding
            // to the arrow size specified by the theme, so we don't have to care about
            // setting a size manually. This is similar to what would happen if we used
            // the TreeView's built-in expanders.
            root_spacer_cell = new CellRendererExpander ();
            item_column.pack_start (root_spacer_cell, false);
            item_column.set_cell_data_func (root_spacer_cell, root_spacer_cell_data_func);

            // First expander. Used for normal expandable items
            primary_expander_cell = new CellRendererExpander ();
            primary_expander_cell.xpad = PRIMARY_EXPANDER_PADDING;
            primary_expander_cell.xalign = 0;
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
            text_cell.xalign = 0;
            item_column.pack_start (text_cell, true);
            item_column.set_cell_data_func (text_cell, name_cell_data_func);

            activatable_cell = new CellRendererIcon ();
            activatable_cell.activated.connect (on_activatable_activated);
            item_column.pack_start (activatable_cell, false);
            item_column.set_cell_data_func (activatable_cell, icon_cell_data_func);

            // Second expander. Used for main categories
            secondary_expander_cell = new CellRendererExpander ();
            secondary_expander_cell.xpad = SECONDARY_EXPANDER_PADDING;
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

            // Monitor item changes
            data_model.item_updated.connect_after (on_model_item_updated);
        }

        ~Tree () {
            text_cell.editing_started.disconnect (on_editing_started);
            text_cell.editing_canceled.disconnect (on_editing_canceled);
        }

        private void on_model_item_updated (Item item) {
            // Currently, all the other properties are updated automatically by the
            // cell-data functions after a change in the model.
            var expandable_item = item as ExpandableItem;
            if (expandable_item != null)
                update_expansion (expandable_item);
        }

        /**
         * Sets the ideal level indentation.
         *
         * Because our tree doesn't use GtkTreeView's built-in expanders, some tricks
         * had to be applied to it in order to get proper indentation, as the widget
         * ties the automatic indentation feature to the default expanders; if they
         * are not used, the default indentation support is gone and we have no other
         * option than using the level_indentation property. Since level_indentation
         * doesn't affect root-level items, we pack an invisible expander-cell there.
         *
         * LEGEND:
         *
         * {...} : root_spacer_cell
         * -----> : level_indentation
         * [....]  : primary_expander_cell
         *
         * level_indentaton and primary_expander_cell are supposed to have the
         * same width.
         *
         * SPACER DIAGRAM
         *
         * {...} CATEGORY 1
         * -----> [....] Item 1
         * -----> [....] Expandable Item 2
         * -----> -----> [....] Sub-Item 1
         * {...} CATEGORY 2
         * -----> [....] Expandable Item 1
         * -----> -----> [....] Expandable Sub-Item 1
         * -----> -----> -----> [....] Expandable Sub-Item 1
         *
         * As shown in the diagram above, level_indentation equals the width of
         * primary_expander_cell, which is visible even if the row it's packed
         * into is not expandable; it only draws an arrow for expandable and
         * collapsible rows though. Please notice that the tree view doesn't
         * add the value of level_indentation to root-level items, and so we
         * must use an invisible expander row to control the padding there;
         * it doesn't have the same value of level_indentation though, so it's
         * not aligned with the second-level children.
         */
        private void compute_indentation () {
            this.level_indentation = get_cell_width (primary_expander_cell);
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
            if (item == null) {
                unselect_all ();

                // As explained in cursor_changed(), we cannot emit signals for this special
                // case from there because that wouldn't allow us to implement the behavior
                // we want (i.e. restoring the old selection after expanding a previously
                // collapsed category) without emitting the undesired item_selected() signal
                // along the way. This special case is handled manually, because it *should*
                // only happen in response to client code requests and never in response to
                // user interaction. We do that here because there's no way to determine
                // whether the cursor change came from code (i.e. this method) or user
                // interaction from cursor_changed().
                this.selected = null;
                item_selected (null);
            } else if (item.selectable) {
                if (scroll_to_item)
                    this.scroll_to_item (item);

                var to_select = data_model.get_item_path (item);
                if (to_select != null)
                    set_cursor_on_cell (to_select, get_column (Column.ITEM), text_cell, false);
            }
        }

        public override void cursor_changed () {
            var path = get_selected_path ();
            Item? new_item = path != null ? data_model.get_item_from_path (path) : null;

            // Don't do anything if @new_item is null.
            //
            // The only way 'this.selected' can be null is by setting it explicitly to
            // that value from client code, and thus we handle that case in set_selected().
            // THIS CANNOT HAPPEN IN RESPONSE TO USER INTERACTION. For example, if an
            // item is un-selected because its parent category has been collapsed, then it will
            // remain as the current selected item (not in reality, just as the value of
            // this.selected) and will be re-selected after the parent is expanded again.
            // THIS ALL HAPPENS SILENTLY BEHIND THE SCENES, so client code will never know
            // it ever happened; the value of selected_item remains unchanged and item_selected()
            // is not emitted.
            if (new_item != null && new_item != this.selected) {
                this.selected = new_item;
                item_selected (new_item);
            }
        }

        private bool toggle_expansion (ExpandableItem item) {
            if (item.collapsible) {
                item.expanded = !item.expanded;
                return true;
            }
            return false;
        }

        public bool scroll_to_item (Item item) {
            bool scrolled = false;

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
                edited = item;
                text_cell.editable = true;
                set_cursor_on_cell (path, get_column (Column.ITEM), text_cell, true);
            } else {
                warning ("Could not edit \"%s\": path not found", item.name);
            }

            return editing;
        }

        public void stop_editing () {
            if (editing && edited != null) {
                var path = data_model.get_item_path (edited);

                // Setting the cursor on the same cell without editing cancels any editing
                // operation going on
                if (path != null)
                    set_cursor_on_cell (path, get_column (Column.ITEM), text_cell, false);
            }
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
            edited = null;
        }

        private void on_editing_done () {
            if (edited != null && edited.editable && editable_entry != null)
                edited.edited (editable_entry.get_text ());

            // Same actions as when canceling editing
            on_editing_canceled ();
        }

        private void on_activatable_activated (string item_path_str) {
            var item = get_item_from_path_string (item_path_str);
            if (item != null)
                item.action_activated ();
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
                if (expandable_item.expanded) {
                    expand_row (path, false);

                    // Since collapsing an item un-selects any child item previously selected,
                    // we need to restore the selection. This will be done silently because
                    // set_selected checks for equality between the previously "selected"
                    // item and the newly selected, and only emits the item_selected() signal
                    // if they are different. See cursor_changed() for a better explanation
                    // of this behavior.
                    if (selected != null && selected.parent == expandable_item)
                        set_selected (selected, true);

                    // Collapsing expandable_item's row also collapsed all its children,
                    // and thus we need to update the "expanded" property of each of them
                    // to reflect their previous state.
                    foreach (var child_item in expandable_item.get_children ()) {
                        var child_expandable_item = child_item as ExpandableItem;
                        if (child_expandable_item != null)
                            update_expansion (child_expandable_item);
                    }
                } else {
                    collapse_row (path);
                }
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
            if (event.window != get_bin_window ())
                return base.button_press_event (event);

            Gtk.TreePath path;
            Gtk.TreeViewColumn column;

            int x = (int) event.x, y = (int) event.y, cell_x, cell_y;

            if (get_path_at_pos (x, y, out path, out column, out cell_x, out cell_y)) {
                var item = data_model.get_item_from_path (path);

                // This is needed because the treeview adds an offset at the beginning of every level
                Gdk.Rectangle start_cell_area;
                get_cell_area (path, get_column (0), out start_cell_area);
                cell_x -= start_cell_area.x;

                if (item != null && column == get_column (Column.ITEM)) {
                    // Cancel any editing operation going on
                    stop_editing ();

                    if (((Gdk.Event*) (&event))->triggers_context_menu ()) {
                        popup_context_menu (item, event);
                    } else if (event.button == Gdk.BUTTON_PRIMARY) {
                        if (item is ExpandableItem) {
                            bool over_expander = over_cell (column, primary_expander_cell, cell_x)
                                              || over_cell (column, secondary_expander_cell, cell_x)
                                              || data_model.is_category (item, null, path);
                            if (over_expander && toggle_expansion (item as ExpandableItem))
                                return true;
                        }

                        // Check if the user double-clicked over the text cell
                        if (event.type == Gdk.EventType.2BUTTON_PRESS
                            && item.editable
                            && over_cell (column, text_cell, cell_x)
                            && start_editing_item (item))
                        {
                            return true;
                        }
                    }
                }
            }

            return base.button_press_event (event);
        }

        private bool over_cell (Gtk.TreeViewColumn col, Gtk.CellRenderer cell, int x) {
            int cell_x, cell_width;
            bool found = col.cell_get_position (cell, out cell_x, out cell_width);

            // XXX: This is ugly. Most times, when primary_expander_cell.is_expanded is
            // 'false', cell_get_position returns 0 for cell_width, making everything fail
            // in our button-press handler. Since I have no idea of what is provoking this
            // (it is certainly not the cell's visibility - already checked that), I thought
            // I'd be a duck-taper and added a workaround (which is working perfectly fine
            // by the way). Please add a proper fix if you know what is provoking the problem.
            if (cell == primary_expander_cell)
                cell_width = get_cell_width (primary_expander_cell);

            return found && x > cell_x && x < cell_x + cell_width;
        }

        public override bool popup_menu () {
            return popup_context_menu (null, null);
        }

        private bool popup_context_menu (Item? item, Gdk.EventButton? event) {
            if (item == null)
                item = selected_item;

            if (item != null) {
                var menu = item.get_context_menu ();
                if (menu != null) {
                    var time = (event != null) ? event.time : Gtk.get_current_event_time ();
                    var button = (event != null) ? event.button : 0;

                    menu.attach_to_widget (this, null);

                    if (event != null) {
                        menu.popup (null, null, null, button, time);
                    } else {
                        menu.popup (null, null, menu_position_func, button, time);
                        menu.select_first (false);
                    }

                    return true;
                }
            }

            return false;
        }

        /**
         * Positions a menu based on an item's coordinates.
         *
         * As this function is only used for menu pop-ups triggered by events other than button
         * presses (e.g. key-press events), it assumes that the item in question is the one
         * currently selected, since those events provide no coordinates.
         */
        private void menu_position_func (Gtk.Menu menu, out int x, out int y, out bool push_in) {
            push_in = true;
            x = y = 0;

            if (selected_item == null || !get_realized ())
                return;

            var path = data_model.get_item_path (selected_item);
            if (path == null)
                return;

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

            get_window ().get_origin (out x, out y);
            x += widget_x.clamp (0, get_allocated_width ());
            y += widget_y.clamp (0, get_allocated_height ());

            if (is_rtl) {
                Gtk.Requisition menu_req;
                menu.get_preferred_size (out menu_req, null);
                y -= menu_req.width;
            }
        }

        private static Item? get_item_from_model (Gtk.TreeModel model, Gtk.TreeIter iter) {
            var data_model = model as DataModel;
            assert (data_model != null);
            return data_model.get_item (iter);
        }

        private void root_spacer_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                                 Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            // Only show allocated space for root-level items. Otherwise, hide.
            renderer.visible = data_model.is_iter_at_root_level (iter);
            root_spacer_cell.is_expander = false;
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

        /**
         * Controls expander visibility.
         */
        private void expander_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                              Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var item = get_item_from_model (model, iter);
            if (item != null) {
                // is_expander takes into account whether the item has children or not.
                // The tree-view checks for that and sets this property for us. It also sets
                // is_expanded, and thus we don't need to check for that either.
                var expandable_item = item as ExpandableItem;
                if (expandable_item != null)
                    renderer.is_expander = renderer.is_expander && expandable_item.collapsible;
            }

            if (renderer == primary_expander_cell)
                renderer.visible = !data_model.is_iter_at_root_level (iter);
            else if (renderer == secondary_expander_cell)
                renderer.visible = data_model.is_category (item, iter);
            else
                assert_not_reached ();
        }
    }



    /**
     * Emitted when the sidebar selection changes.
     *
     * @param item Selected item; //null// if nothing is selected.
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
     * Setting it to //null// un-selects the previously selected item, if there was any.
     * {@link Granite.Widgets.Sidebar.ExpandableItem.expand_with_parents} is called on the
     * item's parent to make sure it's possible to select it.
     *
     * @since 0.2
     */
    public Item? selected {
        get { return tree.selected_item; }
        set {
            if (value != null && value.parent != null)
                value.parent.expand_with_parents ();
            tree.selected_item = value;
        }
    }

    /**
     * Text ellipsize mode.
     *
     * @since 0.2
     */
    public Pango.EllipsizeMode ellipsize_mode {
        get { return tree.ellipsize_mode; }
        set { tree.ellipsize_mode = value; }
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
    private DataModel data_model { get { return tree.data_model; } }

    /**
     * Creates a new {@link Granite.Widgets.Sidebar}.
     *
     * @return (transfer full) a new {@link Granite.Widgets.Sidebar}.
     * @since 0.2
     */
    public Sidebar () {
        var model = new DataModel ();

        push_composite_child ();
        tree = new Tree (model);
        tree.set_composite_name ("treeview");
        pop_composite_child ();

        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        add (tree);
        show_all ();

        tree.item_selected.connect ( (item) => item_selected (item) );

        // Initialize item monitor
        add_children_monitor (root);
    }

    ~Sidebar () {
        remove_children_monitor (root);
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
     * @param re-filter whether to call {@link Sidebar.refilter} using the new function.
     * @see Granite.Widgets.Sidebar.VisibleFunc
     * @see Granite.Widgets.Sidebar.refilter
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
     * Queries the actual expanded state of //item//.
     *
     * @see Granite.Widgets.Sidebar.ExpandableItem.expanded
     * @since 0.2
     */
    public bool is_item_expanded (Item item) requires (has_item (item)) {
        var path = data_model.get_item_path (item);
        return path != null && tree.is_row_expanded (path);
    }

    /**
     * If //item// is editable, this activates the editor; otherwise, it does nothing.
     * If an item was already being edited, this will fail.
     *
     * @param item Item to edit.
     * @see Granite.Widgets.Sidebar.Item.editable
     * @see Granite.Widgets.Sidebar.editing
     * @see Granite.Widgets.Sidebar.stop_editing
     * @return true if the editing started successfully; false otherwise.
     * @since 0.2
     */
    public bool start_editing_item (Item item) requires (item.editable)
                                               requires (has_item (item))
    {
        return !editing && tree.start_editing_item (item);
    }

    /**
     * Cancels any editing operation going on.
     *
     * @see Granite.Widgets.Sidebar.editing
     * @see Granite.Widgets.Sidebar.start_editing_item
     * @since 0.2
     */
    public void stop_editing () {
        if (editing)
            tree.stop_editing ();
    }

    /**
     * Scrolls the sidebar tree to make //item// visible.
     *
     * If //expand_parents// is //true//, {@link Granite.Widgets.Sidebar.ExpandableItem.expand_with_parents}
     * is called for the item's parent, to make sure it's not hidden behind a collapsed row.
     *
     * @param item Item to scroll to.
     * @param expand_parents Whether to expand item's parent expandable items in case they are collapsed.
     * @return //true// if successful; //false// otherwise.
     * @since 0.2
     */
    public bool scroll_to_item (Item item, bool expand_parents = true) requires (has_item (item)) {
        if (expand_parents && item.parent != null)
            item.parent.expand_with_parents ();

        return tree.scroll_to_item (item);
    }

    /**
     * Adds an item in response to {@link Granite.Widgets.Sidebar.ExpandableItem.child_added}
     *
     * This method is recursively signaled. While it is first emitted in response to the
     * root's child_added() signal, successive calls are fired by child expandable items,
     * since we set this method as handler for their child_added() signal. In fact, all the
     * item monitors are connected here, and disconnected in remove_item().
     */
    private void add_item (Item item) requires (!has_item (item)) {
        data_model.add_item (item);

        // If it's an expandable item, add children, and monitor future additions and removals.
        var expandable_item = item as ExpandableItem;
        if (expandable_item != null) {
            foreach (var child in expandable_item.get_children ())
                add_item (child);

            add_children_monitor (expandable_item);
        }
    }

    /**
     * Removes an item in response to {@link Granite.Widgets.Sidebar.ExpandableItem.child_removed}.
     *
     * It un-does what add_item() did.
     */
    private void remove_item (Item item) requires (has_item (item)) {
        if (item is ExpandableItem)
            remove_children_monitor (item as ExpandableItem);

        data_model.remove_item (item);
    }

    private void add_children_monitor (ExpandableItem item) {
        item.child_added.connect_after (add_item);
        item.child_removed.connect_after (remove_item);
    }

    private void remove_children_monitor (ExpandableItem item) {
        item.child_added.disconnect (add_item);
        item.child_removed.disconnect (remove_item);
    }
}
