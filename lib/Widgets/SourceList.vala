/***
    Copyright (C) 2012-2013 Victor Eduardo <victoreduardm@gmal.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/

/**
 * A widget that can display a list of items organized in categories.
 *
 * The source list widget consists of a collection of items, some of which are also expandable (and
 * thus can contain more items). All the items displayed in the source list are children of the widget's
 * root item. The API is meant to be used as follows:
 *
 * 1. Create the items you want to display in the source list, setting the appropriate values for their
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
 * var library_category = new Granite.Widgets.SourceList.ExpandableItem ("Libraries");
 * var store_category = new Granite.Widgets.SourceList.ExpandableItem ("Stores");
 * var device_category = new Granite.Widgets.SourceList.ExpandableItem ("Devices");
 *
 * var music_item = new Granite.Widgets.SourceList.Item ("Music");
 *
 * // "Libraries" will be the parent category of "Music"
 * library_category.add (music_item);
 *
 * // We plan to add sub-items to the store, so let's use an expandable item
 * var my_store_item = new Granite.Widgets.SourceList.ExpandableItem ("My Store");
 * store_category.add (my_store_item);
 *
 * var my_store_podcast_item = new Granite.Widgets.SourceList.Item ("Podcasts");
 * var my_store_music_item = new Granite.Widgets.SourceList.Item ("Music");
 *
 * my_store_item.add (my_store_music_item);
 * my_store_item.add (my_store_podcast_item);
 *
 * var player1_item = new Granite.Widgets.SourceList.Item ("Player 1");
 * var player2_item = new Granite.Widgets.SourceList.Item ("Player 2");
 *
 * device_category.add (player1_item);
 * device_category.add (player2_item);
 * }}}
 *
 * 2. Create a source list widget.<<BR>>
 * {{{
 * var source_list = new Granite.Widgets.SourceList ();
 * }}}
 *
 * 3. Add root-level items to the {@link Granite.Widgets.SourceList.root} item.
 * This item only serves as a container, and all its properties are ignored by the widget.
 *
 * {{{
 * // This will add the main categories (including their children) to the source list. After
 * // having being added to be widget, any other item added to any of these items
 * // (or any other child item in a deeper level) will be automatically added too.
 * // There's no need to deal with the source list widget directly.
 *
 * var root = source_list.root;
 *
 * root.add (library_category);
 * root.add (store_category);
 * root.add (device_category);
 * }}}
 *
 * The steps mentioned above are enough for initializing the source list. Future changes to the items'
 * properties are ''automatically'' reflected by the widget.
 *
 * Final steps would involve connecting handlers to the source list events, being
 * {@link Granite.Widgets.SourceList.item_selected} the most important, as it indicates that
 * the selection was modified.
 *
 * It is strongly recommended to pack the source list into the GUI using the
 * {@link Granite.Widgets.ThinPaned} widget. It has aesthetic advantages and offers a wider
 * re-size handle than {@link Gtk.Paned}. This is usually done as follows:
 * {{{
 * var pane = new Granite.Widgets.ThinPaned ();
 * pane.pack1 (source_list, true, false);
 * pane.pack2 (content_area, true, false);
 * }}}
 *
 * @since 0.2
 * @see Granite.Widgets.ThinPaned
 */
public class Granite.Widgets.SourceList : Gtk.ScrolledWindow {

    /**
     * = WORKING INTERNALS =
     *
     * In order to offer a transparent Item-based API, and avoid the need of providing methods
     * to deal with items directly on the SourceList widget, it was decided to follow a monitor-like
     * implementation, where the source list permanently monitors its root item and any other
     * child item added to it. The task of monitoring the properties of the items has been
     * divided between different objects, as shown below:
     *
     * Monitored by: Object::method that receives the signals indicating the property change.
     * Applied by: Object::method that actually updates the tree to reflect the property changes
     *             (directly or indirectly, as in the case of the tree data model).
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
     *   - collapsible   | DataModel::on_item_prop_changed   | Tree::update_expansion
     *                   |                                   | Tree::expander_cell_data_func
     *   - expanded      | Same as @collapsible              | Same as @collapsible
     * ---------------------------------------------------------------------------------------------
     * * Only automatic properties are monitored. ExpandableItem's additions/removals are handled by
     *   DataModel::add_item() and DataModel::remove_item()
     *
     * Other features:
     * - Sorting: this happens on the tree-model level (DataModel). Also see SourceList::SortFunc.
     */



    /**
     * A source list entry.
     *
     * Any change made to any of its properties will be ''automatically'' reflected
     * by the {@link Granite.Widgets.SourceList} widget.
     *
     * @since 0.2
     */
    public class Item : Object {

        /**
         * Emitted when the user has finished editing the item's name.
         *
         * By default, if the name doesn't consist of white space, it is automatically assigned
         * to the {@link Granite.Widgets.SourceList.Item.name} property. The default behavior can
         * be changed by overriding this signal.
         * @param new_name The item's new name (result of editing.)
         * @since 0.2
         */
        public virtual signal void edited (string new_name) {
            if (editable && new_name.strip () != "")
                this.name = new_name;
        }

        /**
         * The {@link Granite.Widgets.SourceList.Item.activatable} icon was activated.
         *
         * @see Granite.Widgets.SourceList.Item.activatable
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
         * Parent {@link Granite.Widgets.SourceList.ExpandableItem} of the item.
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
         * A badge shown next to the item's name.
         *
         * It can be used for displaying the number of unread messages in the "Inbox" item,
         * for instance.
         *
         * @since 0.2
         */
        public string badge { get; set; default = ""; }

        /**
         * Whether the item's name can be edited from within the source list.
         *
         * When this property is set to //true//, users can edit the item by pressing
         * the F2 key, or by double-clicking its name.
         *
         * ''This property only works for selectable items''.
         *
         * @see Granite.Widgets.SourceList.Item.selectable
         * @see Granite.Widgets.SourceList.start_editing_item
         * @since 0.2
         */
        public bool editable { get; set; default = false; }

        /**
         * Whether the item should appear in the source list's tree or not.
         *
         * @since 0.2
         */
        public bool visible { get; set; default = true; }

        /**
         * Whether the item can be selected or not.
         *
         * Setting this property to true doesn't guarantee that the item will actually be
         * selectable, since there are other external factors to take into account, like the
         * item's {@link Granite.Widgets.SourceList.Item.visible} property; whether the item is
         * a category; the parent item is collapsed, etc.
         *
         * @see Granite.Widgets.SourceList.Item.visible
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
         * It can be used for e.g. showing an //"eject"// icon on a device's item.
         *
         * @see Granite.Widgets.SourceList.Item.action_activated
         * @since 0.2
         */
        public Icon activatable { get; set; }

        /**
         * Creates a new {@link Granite.Widgets.SourceList.Item}.
         *
         * @param name Name of the item.
         * @return (transfer full) A new {@link Granite.Widgets.SourceList.Item}.
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
     * It supports all the properties inherited from {@link Granite.Widgets.SourceList.Item},
     * and behaves like a normal item, except when it is located at the root level; in that case,
     * the following properties are ignored by the widget:
     *
     * * {@link Granite.Widgets.SourceList.Item.selectable}
     * * {@link Granite.Widgets.SourceList.Item.editable}
     * * {@link Granite.Widgets.SourceList.Item.icon}
     * * {@link Granite.Widgets.SourceList.Item.activatable}
     * * {@link Granite.Widgets.SourceList.Item.badge}
     *
     * Root-level expandable items (i.e. Main Categories) are ''not'' displayed when they contain
     * zero visible children.
     *
     * @since 0.2
     */
    public class ExpandableItem : Item {

        /**
         * Emitted when an item is added.
         *
         * @param item Item added.
         * @see Granite.Widgets.SourceList.ExpandableItem.add
         * @since 0.2
         */
        public signal void child_added (Item item);

        /**
         * Emitted when an item is removed.
         *
         * @param item Item removed.
         * @see Granite.Widgets.SourceList.ExpandableItem.remove
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
         * {@link Granite.Widgets.SourceList.ExpandableItem.expanded} property.
         *
         * @see Granite.Widgets.SourceList.ExpandableItem.expanded
         * @since 0.2
         */
        public bool collapsible { get; set; default = true; }

        /**
         * Whether the item is expanded or not.
         *
         * The source list widget will obey the value of this property when possible.
         *
         * This property has no effect when {@link Granite.Widgets.SourceList.ExpandableItem.collapsible}
         * is set to //false//. Also keep in mind that, __when set to //true//__, this property
         * doesn't always represent the actual expansion state of an item. For example, it might
         * be the case that an expandable item is collapsed because it has zero visible children,
         * but its //expanded// property value is still //true//; in such case, once one of the
         * item's children becomes visible, the item will be expanded again. Same applies to items
         * hidden behind a collapsed parent item.
         *
         * If obtaining the ''actual'' expansion state of an item is important to your needs,
         * use {@link Granite.Widgets.SourceList.is_item_expanded} instead.
         *
         * @see Granite.Widgets.SourceList.ExpandableItem.collapsible
         * @see Granite.Widgets.SourceList.is_item_expanded
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
         * @since 0.2
         */
        public uint n_children {
            get { return children_list.size; }
        }

        /**
         * The item's children.
         *
         * @since 0.2
         */
        public Gee.Collection<Item> children {
            owned get {
                return children_list.read_only_view;
            }
        }

        private Gee.Collection<Item> children_list = new Gee.ArrayList<Item> ();

        /**
         * Creates a new {@link Granite.Widgets.SourceList.ExpandableItem}
         *
         * @param name Title of the item.
         * @return (transfer full) A new {@link Granite.Widgets.SourceList.ExpandableItem}.
         * @since 0.2
         */
        public ExpandableItem (string name = "") {
            base (name);
            editable = false;
        }

        /**
         * Should return a negative integer, zero, or a positive integer if ''a'' sorts //before//
         * ''b'', ''a'' sorts //with// ''b'', or ''a'' sorts //after// ''b'' respectively. If two
         * items compare as equal, their order in the sorted source list is undefined.
         *
         * In order to ensure that the source list behaves as expected, this method must define a
         * partial order on the source list tree; i.e. it must be reflexive, antisymmetric and
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
        public virtual int compare (Item a, Item b) {
            return 0;
        }

        /**
         * Checks whether the item contains the specified child.
         *
         * This method only considers the item's immediate children.
         *
         * @param item Item to search.
         * @return Whether the item was found or not.
         * @since 0.2
         */
        public bool contains (Item item) {
            return item in children_list;
        }

        /**
         * Adds an item.
         *
         * {@link Granite.Widgets.SourceList.ExpandableItem.child_added} is fired after the item is added.
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
         * @see Granite.Widgets.SourceList.ExpandableItem.child_added
         * @see Granite.Widgets.SourceList.ExpandableItem.remove
         * @since 0.2
         */
        public void add (Item item) requires (item.parent == null) {
            item.parent = this;
            children_list.add (item);
            child_added (item);
        }

        /**
         * Removes an item.
         *
         * The {@link Granite.Widgets.SourceList.ExpandableItem.child_removed} signal is fired
         * //after removing the item//. Finally (i.e. after all the handlers have been invoked),
         * the item's {@link Granite.Widgets.SourceList.Item.parent} property is set to //null//.
         * This has the advantage of letting signal handlers know the parent from which //item//
         * is being removed.
         *
         * @param item The item to remove. This will fail if item has a different parent.
         * @see Granite.Widgets.SourceList.ExpandableItem.child_removed
         * @see Granite.Widgets.SourceList.ExpandableItem.clear
         * @since 0.2
         */
        public void remove (Item item) requires (item.parent == this) {
            children_list.remove (item);
            child_removed (item);
            item.parent = null;
        }

        /**
         * Removes all the items contained by the item. It works similarly to
         * {@link Granite.Widgets.SourceList.ExpandableItem.remove}.
         *
         * @see Granite.Widgets.SourceList.ExpandableItem.remove
         * @see Granite.Widgets.SourceList.ExpandableItem.child_removed
         * @since 0.2
         */
        public void clear () {
            // Create a copy of the children so that it's safe to iterate it
            // (e.g. by using foreach) while removing items
            var children_list_copy = new Gee.ArrayList<Item> ();
            children_list_copy.add_all (children_list);

            foreach (var item in children_list_copy)
                remove (item);
        }

        /**
         * Expands the item and/or its children.
         *
         * @param inclusive Whether to also expand this item (true), or only its children (false).
         * @param recursive Whether to recursively expand all the children (true), or only
         * immediate children (false).
         * @see Granite.Widgets.SourceList.ExpandableItem.expanded
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
         * sense once you've understood what the {@link Granite.Widgets.SourceList.ExpandableItem.expanded}
         * property actually means. If you set //recursive// to //true,// the non-immediate children's
         * //expanded// property will be set to //false//, and therefore they will __stay collapsed__
         * the next time their parents are expanded; otherwise (i.e. if //recursive// is //false//),
         * __their previous expansion state will be restored__ once their parents are expanded again.
         * @see Granite.Widgets.SourceList.ExpandableItem.expanded
         * @since 0.2
         */
        public void collapse_all (bool inclusive = true, bool recursive = true) {
            set_expansion (this, inclusive, recursive, false);
        }

        private static void set_expansion (ExpandableItem item, bool inclusive, bool recursive, bool expanded) {
            if (inclusive)
                item.expanded = expanded;

            foreach (var child_item in item.children) {
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
         * @see Granite.Widgets.SourceList.ExpandableItem.expanded
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
         * @see Granite.Widgets.SourceList.ExpandableItem.expanded
         * @since 0.2
         */
        public void collapse_with_parents () {
            if (parent != null)
                parent.collapse_with_parents ();
            expanded = false;
        }
    }



    /**
     * The model backing the SourceList tree.
     *
     * It monitors item property changes, and handles children additions and removals. It also controls
     * the visibility of the items based on their "visible" property, and on their number of children,
     * if they happen to be categories. Its main purpose is to provide an easy and practical interface
     * for sorting, adding, removing and updating items, eliminating the need of repeatedly dealing with
     * the Gtk.TreeModel API directly.
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

        public signal void item_updated (Item item);

        /**
         * Used by push_parent_update() as key to associate the respective data to the objects.
         */
        private const string ITEM_PARENT_NEEDS_UPDATE = "item-parent-needs-update";

        private Gtk.SortType sort_dir = Gtk.SortType.ASCENDING;
        public Gtk.SortType sort_direction {
            get { return sort_dir; }
            set {
                sort_dir = value;
                resort ();
            }
        }

        private ExpandableItem _root;

        /**
         * Root item.
         *
         * This item is not actually part of the model. It's only used as a proxy
         * for adding and removing items.
         */
        public ExpandableItem root {
            get { return _root; }
            set {
                if (_root != null) {
                    remove_children_monitor (_root);
                    foreach (var item in _root.children)
                        remove_item (item);
                }

                _root = value;

                add_children_monitor (_root);
                foreach (var item in _root.children)
                    add_item (item);
            }
        }

        // This hash map stores items and their respective child node references. For that reason, the
        // references it contains should only be used on the child_tree model, or converted to filter
        // iters/paths using convert_child_*_to_*() before using them with the filter (i.e. this) model.
        private Gee.HashMap<Item, NodeWrapper> items = new Gee.HashMap<Item, NodeWrapper> ();

        private Gee.HashMap<Item, ItemMonitor> monitors = new Gee.HashMap<Item, ItemMonitor> ();

        private Gtk.TreeStore child_tree;
        private SourceList.SortFunc? sort_func;
        private unowned SourceList.VisibleFunc? filter_func;

        public DataModel () {
            var child_tree = new Gtk.TreeStore (Column.N_COLUMNS, Column.ITEM.type ());
            Object (child_model: child_tree, virtual_root: null);
            this.child_tree = child_tree;

            child_tree.set_default_sort_func (child_model_sort_func);
            resort ();

            set_visible_func (filter_visible_func);
        }

        public bool has_item (Item item) {
            return items.has_key (item);
        }

        public void update_item (Item item) requires (has_item (item)) {
            assert (root != null);

            // Emitting row_changed() for this item's row in the child model causes the filter
            // (i.e. this model) to re-evaluate whether a row is visible or not, calling
            // filter_visible_func() for that row again, and that's exactly what we want.
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

        private void add_item (Item item) requires (!has_item (item)) {
            assert (root != null);

            // Find the parent iter
            Gtk.TreeIter? parent_child_iter = null, child_iter;
            var parent = item.parent;

            if (parent != null && parent != root) {
                // Add parent if it hasn't been added yet
                if (!has_item (parent))
                    add_item (parent);

                // Try to find the parent's iter
                parent_child_iter = get_item_child_iter (parent);

                // Parent must have been added prior to adding this item
                assert (parent_child_iter != null);
            }

            child_tree.append (out child_iter, parent_child_iter);
            child_tree.set (child_iter, Column.ITEM, item, -1);

            items.set (item, new NodeWrapper (child_tree, child_iter));

            // This is equivalent to a property change. The tree still needs to update
            // some of the new item's properties through this signal's handler.
            item_updated (item);

            add_property_monitor (item);

            push_parent_update (parent);

            // If the item is expandable, also add children
            var expandable = item as ExpandableItem;
            if (expandable != null) {
                foreach (var child_item in expandable.children)
                    add_item (child_item);

                // Monitor future additions/removals through signal handlers
                add_children_monitor (expandable);
            }
        }

        private void remove_item (Item item) requires (has_item (item)) {
            assert (root != null);

            remove_property_monitor (item);

            // get_item_child_iter() depends on items.get(item) for retrieving the right reference,
            // so don't unset the item from @items yet! We first get the child iter and then
            // unset the value.
            var child_iter = get_item_child_iter (item);

            // Now we remove the item from the table, because that way get_item_child_iter() and
            // all the methods that depend on it won't return invalid iters or items when
            // called. This is important because child_tree.remove() will emit row_deleted(),
            // and its handlers could potentially depend on one of the methods mentioned above.
            items.unset (item);

            if (child_iter != null)
                child_tree.remove (ref child_iter);

            push_parent_update (item.parent);

            // If the item is expandable, also remove children
            var expandable = item as ExpandableItem;
            if (expandable != null) {
                // No longer monitor future additions or removals
                remove_children_monitor (expandable);

                foreach (var child_item in expandable.children)
                    remove_item (child_item);
            }
        }

        private void add_property_monitor (Item item) {
            var wrapper = new ItemMonitor (item);
            monitors[item] = wrapper;
            wrapper.changed.connect (on_item_prop_changed);
        }

        private void remove_property_monitor (Item item) {
            var wrapper = monitors[item];
            if (wrapper != null)
                wrapper.changed.disconnect (on_item_prop_changed);
            monitors.unset (item);
        }

        private void add_children_monitor (ExpandableItem item) {
            item.child_added.connect_after (on_item_child_added);
            item.child_removed.connect_after (on_item_child_removed);
        }

        private void remove_children_monitor (ExpandableItem item) {
            item.child_added.disconnect (on_item_child_added);
            item.child_removed.disconnect (on_item_child_removed);
        }

        private void on_item_child_added (Item item) {
            add_item (item);
        }

        private void on_item_child_removed (Item item) {
            remove_item (item);
        }

        private void on_item_prop_changed (Item item, string prop_name) {
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
            if (parent == null)
                return;

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
         * Returns a newly-created iterator pointing to the item, or null in case a valid iter
         * was not found.
         */
        public Gtk.TreeIter? get_item_iter (Item item) {
            var child_iter = get_item_child_iter (item);

            if (child_iter != null) {
                Gtk.TreeIter iter;
                if (convert_child_iter_to_iter (out iter, child_iter))
                    return iter;
            }

            return null;
        }

        /**
         * Sets the sort function, or "unsets" it if null is passed. Please note though
         * that unsetting the sort function doesn't bring the items back to their initial
         * order.
         */
        public void set_sort_func (owned SourceList.SortFunc? sort_func) {
            this.sort_func = (owned) sort_func;
            resort ();
        }

        /**
         * External "extra" filter method.
         */
        public void set_filter_func (SourceList.VisibleFunc? visible_func) {
            this.filter_func = visible_func;
        }

        /**
         * Checks whether an item is a category (i.e. a root-level expandable item).
         * The caller must pass an iter or path pointing to the item, but not both
         * (one of them must be null.)
         *
         * TODO: instead of checking the position of the iter or path, we should simply
         * check whether the item's parent is the root item and whether the item is
         * expandable. We don't do so right now because vala still allows client code
         * to access the Item.parent property, even though its setter is defined as internal.
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

        private void resort () {
            child_tree.set_sort_column_id (Gtk.SortColumn.UNSORTED, sort_direction);
            child_tree.set_sort_column_id (Gtk.SortColumn.DEFAULT, sort_direction);
        }

        private int child_model_sort_func (Gtk.TreeModel model, Gtk.TreeIter a, Gtk.TreeIter b) {
            int sort = 0;

            Item? item_a, item_b;
            child_tree.get (a, Column.ITEM, out item_a, -1);
            child_tree.get (b, Column.ITEM, out item_b, -1);

            // If the sort function is not null use old sorting API. Otherwise, use each
            // item's compare() method.
            if (sort_func != null) {
                if (item_a != null && item_b != null)
                    sort = sort_func (item_a, item_b);
            } else {
                // code should only compare items on same hierarchy level
                assert (item_a.parent == item_b.parent);

                var parent = item_a.parent;
                if (parent != null)
                    sort = parent.compare (item_a, item_b);
            }

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

                // If the item is a category, also query the number of visible children
                // because empty categories should not be displayed.
                var expandable = item as ExpandableItem;
                if (expandable != null && child_tree.iter_depth (iter) == 0) {
                    uint n_visible_children = 0;
                    foreach (var child_item in expandable.children) {
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
     * A cell renderer that only adds space.
     */
    private class CellRendererSpacer : Gtk.CellRenderer {
        /**
         * Indentation level represented by this cell renderer
         */
        public int level { get; set; default = -1; }

        public override Gtk.SizeRequestMode get_request_mode () {
            return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
        }

        public override void get_preferred_width (Gtk.Widget widget, out int min_size, out int natural_size) {
            min_size = natural_size = 2 * (int) xpad;
        }

        public override void get_preferred_height_for_width (Gtk.Widget widget, int width,
                                                             out int min_height, out int natural_height)
        {
            min_height = natural_height = 2 * (int) ypad;
        }

        public override void render (Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle bg_area,
                                     Gdk.Rectangle cell_area, Gtk.CellRendererState flags)
        {
            // Nothing to do. This renderer only adds space.
        }

        [Deprecated (replacement = "Gtk.CellRenderer.get_preferred_size", since = "")]
        public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                       out int x_offset, out int y_offset,
                                       out int width, out int height)
        {
            assert_not_reached ();
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

        private Item? selected;
        private unowned Item? edited;

        private Gtk.Entry? editable_entry;
        private Gtk.CellRendererText text_cell;
        private CellRendererIcon icon_cell;
        private CellRendererIcon activatable_cell;
        private CellRendererBadge badge_cell;
        private CellRendererExpander primary_expander_cell;
        private CellRendererExpander secondary_expander_cell;
        private Gee.HashMap<int, CellRendererSpacer> spacer_cells; // cells used for left spacing

        private const string DEFAULT_STYLESHEET = """
            .source-list.badge {
                border-radius: 10px;
                border-width: 0;
                padding: 1px 2px 1px 2px;
                font-weight: bold;
            }
        """;

        private const string STYLE_PROP_LEVEL_INDENTATION = "level-indentation";
        private const string STYLE_PROP_LEFT_PADDING = "left-padding";
        private const string STYLE_PROP_EXPANDER_SPACING = "expander-spacing";

        static construct {
            install_style_property (new ParamSpecInt (STYLE_PROP_LEVEL_INDENTATION,
                                                      "Level Indentation",
                                                      "Space to add at the beginning of every indentation level. Must be an even number.",
                                                      1, 50, 6,
                                                      ParamFlags.READABLE));

            install_style_property (new ParamSpecInt (STYLE_PROP_LEFT_PADDING,
                                                      "Left Padding",
                                                      "Padding added to the left side of the tree. Must be an even number.",
                                                      1, 50, 4,
                                                      ParamFlags.READABLE));

            install_style_property (new ParamSpecInt (STYLE_PROP_EXPANDER_SPACING,
                                                      "Expander Spacing",
                                                      "Space added between an item and its expander. Must be an even number.",
                                                      1, 50, 4,
                                                      ParamFlags.READABLE));
        }

        public Tree (DataModel data_model) {
            Utils.set_theming (this, DEFAULT_STYLESHEET, StyleClass.SOURCE_LIST,
                               Gtk.STYLE_PROVIDER_PRIORITY_FALLBACK);

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

            // Now pack the cell renderers. We insert them in reverse order (using pack_end)
            // because we want to use TreeViewColumn.pack_start exclusively for inserting
            // spacer cell renderers for level-indentation purposes.
            // See add_spacer_cell_for_level() for more details.

            // Second expander. Used for main categories
            secondary_expander_cell = new CellRendererExpander ();
            secondary_expander_cell.is_category_expander = true;
            secondary_expander_cell.xpad = 10;
            item_column.pack_end (secondary_expander_cell, false);
            item_column.set_cell_data_func (secondary_expander_cell, expander_cell_data_func);

            activatable_cell = new CellRendererIcon ();
            activatable_cell.xpad = 6;
            activatable_cell.activated.connect (on_activatable_activated);
            item_column.pack_end (activatable_cell, false);
            item_column.set_cell_data_func (activatable_cell, icon_cell_data_func);

            badge_cell = new CellRendererBadge ();
            badge_cell.xpad = 1;
            badge_cell.xalign = 1;
            item_column.pack_end (badge_cell, false);
            item_column.set_cell_data_func (badge_cell, badge_cell_data_func);

            text_cell = new Gtk.CellRendererText ();
            text_cell.editable_set = true;
            text_cell.editable = false;
            text_cell.editing_started.connect (on_editing_started);
            text_cell.editing_canceled.connect (on_editing_canceled);
            text_cell.ellipsize = Pango.EllipsizeMode.END;
            text_cell.xalign = 0;
            item_column.pack_end (text_cell, true);
            item_column.set_cell_data_func (text_cell, name_cell_data_func);

            icon_cell = new CellRendererIcon ();
            icon_cell.xpad = 2;
            item_column.pack_end (icon_cell, false);
            item_column.set_cell_data_func (icon_cell, icon_cell_data_func);

            // First expander. Used for normal expandable items
            primary_expander_cell = new CellRendererExpander ();

            int expander_spacing;
            style_get (STYLE_PROP_EXPANDER_SPACING, out expander_spacing);
            primary_expander_cell.xpad = expander_spacing / 2;

            item_column.pack_end (primary_expander_cell, false);
            item_column.set_cell_data_func (primary_expander_cell, expander_cell_data_func);

            // Selection
            var selection = get_selection ();
            selection.mode = Gtk.SelectionMode.BROWSE;
            selection.set_select_function (select_func);

            // Monitor item changes
            data_model.item_updated.connect_after (on_model_item_updated);

            // Add root-level indentation. New levels will be added by update_item_expansion()
            add_spacer_cell_for_level (1);
        }

        ~Tree () {
            text_cell.editing_started.disconnect (on_editing_started);
            text_cell.editing_canceled.disconnect (on_editing_canceled);
            data_model.item_updated.disconnect (on_model_item_updated);
        }

        private void on_model_item_updated (Item item) {
            // Currently, all the other properties are updated automatically by the
            // cell-data functions after a change in the model.
            var expandable_item = item as ExpandableItem;
            if (expandable_item != null)
                update_expansion (expandable_item);
        }

        private void add_spacer_cell_for_level (int level, bool check_previous = true)
            requires (level > 0)
        {
            if (spacer_cells == null)
                spacer_cells = new Gee.HashMap<int, CellRendererSpacer> ();

            if (!spacer_cells.has_key (level)) {
                var spacer_cell = new CellRendererSpacer ();
                spacer_cell.level = level;
                spacer_cells[level] = spacer_cell;

                uint cell_xpadding;

                // The primary expander is not visible for root-level (i.e. first level)
                // items, so for the second level of indentation we use a low padding
                // because the primary expander will add enough space. For the root level,
                // we use left_padding, and level_indentation for the remaining levels.
                // The value of cell_xpadding will be allocated *twice* by the cell renderer,
                // so we set the value to a half of actual (desired) value.
                switch (level) {
                    case 1: // root
                        int left_padding;
                        style_get (STYLE_PROP_LEFT_PADDING, out left_padding);
                        cell_xpadding = left_padding / 2;
                    break;

                    case 2: // second level
                        cell_xpadding = 0;
                    break;

                    default: // remaining levels
                        int level_indentation;
                        style_get (STYLE_PROP_LEVEL_INDENTATION, out level_indentation);
                        cell_xpadding = level_indentation / 2;
                    break;
                }

                spacer_cell.xpad = cell_xpadding;

                var item_column = get_column (Column.ITEM);
                item_column.pack_start (spacer_cell, false);
                item_column.set_cell_data_func (spacer_cell, spacer_cell_data_func);

                // Make sure that the previous indentation levels also exist
                if (check_previous) {
                    for (int i = level - 1; i > 0; i--)
                        add_spacer_cell_for_level (i, false);
                }
            }
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
                Gtk.TreeSelection? selection = get_selection ();
                if (selection != null)
                    selection.unselect_all ();

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

        public bool scroll_to_item (Item item, bool use_align = false, float row_align = 0) {
            bool scrolled = false;

            var path = data_model.get_item_path (item);
            if (path != null) {
                scroll_to_cell (path, null, use_align, row_align, 0);
                scrolled = true;
            }

            return scrolled;
        }

        public bool start_editing_item (Item item) requires (item.editable) requires (item.selectable) {
            if (editing && item == edited) // If same item again, simply return.
                return false;

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

                // Setting the cursor on the same cell without starting an edit cancels any
                // editing operation going on.
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

        private bool toggle_expansion (ExpandableItem item) {
            if (item.collapsible) {
                item.expanded = !item.expanded;
                return true;
            }
            return false;
        }

        /**
         * Updates the tree to reflect the ''expanded'' property of expandable_item.
         */
        public void update_expansion (ExpandableItem expandable_item) {
            var path = data_model.get_item_path (expandable_item);

            if (path != null) {
                // Make sure that the indentation cell for the item's level exists.
                // We use +1 because the method will make sure that the previous
                // indentation levels exist too.
                add_spacer_cell_for_level (path.get_depth () + 1);

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
                    foreach (var child_item in expandable_item.children) {
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
                        // Check whether an expander (or an equivalent area) was clicked.
                        bool is_expandable = item is ExpandableItem;
                        bool is_category = is_expandable && data_model.is_category (item, null, path);

                        if (event.type == Gdk.EventType.BUTTON_PRESS) {
                            if (is_expandable) {
                                // Checking for secondary_expander_cell is not necessary because the entire row
                                // serves for this purpose when the item is a category or when the item is a
                                // normal expandable item that is not selectable (special care is taken to
                                // not break the activatable/action icons for such cases).
                                // The expander only works like a visual indicator for these items.
                                bool expander_clicked = is_category
                                    || over_primary_expander (column, path, cell_x)
                                    || (!item.selectable && !over_cell (column, path, activatable_cell, cell_x));

                                if (expander_clicked && toggle_expansion (item as ExpandableItem))
                                    return true;
                            }
                        } else if (event.type == Gdk.EventType.2BUTTON_PRESS
                            && !is_category // Main categories are *not* editable
                            && item.editable
                            && item.selectable
                            && over_cell (column, path, text_cell, cell_x)
                            && start_editing_item (item))
                        {
                            // The user double-clicked over the text cell, and editing started successfully.
                            return true;
                        }
                    }
                }
            }

            return base.button_press_event (event);
        }

        private bool over_primary_expander (Gtk.TreeViewColumn col, Gtk.TreePath path, int x) {
            Gtk.TreeIter iter;
            if (!model.get_iter (out iter, path))
                return false;

            // Call the cell-data function and make it assign the proper visibility state to the cell
            expander_cell_data_func (col, primary_expander_cell, model, iter);

            if (!primary_expander_cell.visible)
                return false;

            // We want to return false if the cell is not expandable (i.e. the arrow is hidden)
            if (model.iter_n_children (iter) < 1)
                return false;

            // Now that we're sure that the item is expandable, let's see if the user clicked
            // over the expander area. We don't do so directly by querying the primary expander
            // position because it's not fixed, yielding incorrect coordinates depending on whether
            // a different area was re-drawn before this method was called. We know that the last
            // spacer cell precedes (in a LTR fashion) the expander cell. Because the position
            // of the spacer cell is fixed, we can safely query it.
            int indentation_level = path.get_depth ();
            var last_spacer_cell = spacer_cells[indentation_level];

            if (last_spacer_cell != null) {
                int cell_x, cell_width;

                if (col.cell_get_position (last_spacer_cell, out cell_x, out cell_width)) {
                    // Add a pixel so that the expander area is a bit wider
                    int expander_width = get_cell_width (primary_expander_cell) + 1;

                    if (Utils.is_left_to_right (this)) {
                        int indentation_offset = cell_x + cell_width;
                        return x >= indentation_offset && x <= indentation_offset + expander_width;
                    }

                    return x <= cell_x && x >= cell_x - expander_width;
                }
            }

            return false;
        }

        private bool over_cell (Gtk.TreeViewColumn col, Gtk.TreePath path, Gtk.CellRenderer cell, int x) {
            int cell_x, cell_width;
            bool found = col.cell_get_position (cell, out cell_x, out cell_width);
            return found && x > cell_x && x < cell_x + cell_width;
        }

        private int get_cell_width (Gtk.CellRenderer cell_renderer) {
            Gtk.Requisition min_req;
            cell_renderer.get_preferred_size (this, out min_req, null);
            return min_req.width;
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
         * This function is only used for menu pop-ups triggered by events other than button
         * presses (e.g. key-press events). Since such events provide no coordinates, it is
         * assumed that the item in question is the one currently selected.
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

            bool is_ltr = Utils.is_left_to_right (this);

            if (is_ltr)
                item_x += item_bin_coords.width - 6;

            int widget_x, widget_y;
            convert_bin_window_to_widget_coords (item_x, item_y, out widget_x, out widget_y);

            get_window ().get_origin (out x, out y);
            x += widget_x.clamp (0, get_allocated_width ());
            y += widget_y.clamp (0, get_allocated_height ());

            if (!is_ltr) {
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

        private static void spacer_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                                   Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var spacer = renderer as CellRendererSpacer;
            assert (spacer != null);
            assert (spacer.level > 0);

            var path = model.get_path (iter);

            int level = -1;
            if (path != null)
                level = path.get_depth ();

            renderer.visible = spacer.level <= level;
        }

        private void name_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                          Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var text_renderer = renderer as Gtk.CellRendererText;
            assert (text_renderer != null);

            var text = new StringBuilder ();
            var weight = Pango.Weight.NORMAL;

            var item = get_item_from_model (model, iter);
            if (item != null) {
                text.append (item.name);

                if (data_model.is_category (item, iter))
                    weight = Pango.Weight.BOLD;
            }

            text_renderer.weight = weight;
            text_renderer.text = text.str;
        }

        private void badge_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                           Gtk.TreeModel model, Gtk.TreeIter iter)
        {
            var badge_renderer = renderer as CellRendererBadge;
            assert (badge_renderer != null);

            string text = "";
            bool visible = false;

            var item = get_item_from_model (model, iter);
            if (item != null) {
                // Badges are not displayed for main categories
                visible = !data_model.is_category (item, iter)
                       && item.badge != null
                       && item.badge.strip () != "";

                if (visible)
                    text = item.badge;
            }

            badge_renderer.visible = visible;
            badge_renderer.text = text;
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
                // Gtk.CellRenderer.is_expander takes into account whether the item has children or not.
                // The tree-view checks for that and sets this property for us. It also sets
                // Gtk.CellRenderer.is_expanded, and thus we don't need to check for that either.
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
     * Emitted when the source list selection changes.
     *
     * @param item Selected item; //null// if nothing is selected.
     * @since 0.2
     */
    public virtual signal void item_selected (Item? item) { }

    /**
     * A {@link Granite.Widgets.SourceList.SortFunc} should return a negative integer, zero, or a
     * positive integer if ''a'' sorts //before// ''b'', ''a'' sorts //with// ''b'', or ''a'' sorts
     * //after// ''b'' respectively. If two items compare as equal, their order in the sorted
     * source list is undefined.
     *
     * In order to ensure that the source list behaves as expected, the {@link Granite.Widgets.SourceList.SortFunc}
     * must define a partial order on the source list tree; i.e. it must be reflexive, antisymmetric and
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
    [Deprecated (replacement = "ExpandableItem.compare", since = "0.2")]
    public delegate int SortFunc (Item a, Item b);

    /**
     * A {@link Granite.Widgets.SourceList.VisibleFunc} should return true if the item should be
     * visible; false otherwise. If //item//'s {@link Granite.Widgets.SourceList.Item.visible}
     * property is set to //false//, then it won't be displayed even if this method returns true.
     *
     * It is important to note that the method ''must not modify any property of //item//'',
     * because doing so would cause re-entrancy, because the widget's internal data model invokes the
     * method to filter an item again after every property change, resulting in an infinite chain
     * of recursive calls.
     *
     * Usually, modifying the {@link Granite.Widgets.SourceList.Item.visible} property is enough.
     * The advantage of using this method is that its nature is non-destructive, and the
     * changes it makes can be easily reverted (see {@link Granite.Widgets.SourceList.refilter}).
     *
     * @param item Item to be checked.
     * @return Whether //item// should be visible or not.
     * @since 0.2
     */
    public delegate bool VisibleFunc (Item item);

    /**
     * Root-level expandable item.
     *
     * This item contains the first-level source list items. It //only serves as an item container//.
     * It is used to add and remove items to/from the widget.
     *
     * Internally, it allows the source list to connect to its {@link Granite.Widgets.SourceList.ExpandableItem.child_added}
     * and {@link Granite.Widgets.SourceList.ExpandableItem.child_removed} signals in order to monitor
     * new children additions/removals.
     *
     * @since 0.2
     */
    public ExpandableItem root {
        get { return data_model.root; }
        set { data_model.root = value; }
    }

    /**
     * The current selected item.
     *
     * Setting it to //null// un-selects the previously selected item, if there was any.
     * {@link Granite.Widgets.SourceList.ExpandableItem.expand_with_parents} is called on the
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
     * @see Granite.Widgets.SourceList.start_editing_item
     * @since 0.2
     */
    public bool editing {
        get { return tree.editing; }
    }

    /**
     * Sort direction to use along with the sort function.
     *
     * @see Granite.Widgets.SourceList.set_sort_func
     * @since 0.2
     */
    public Gtk.SortType sort_direction {
        get { return data_model.sort_direction; }
        set { data_model.sort_direction = value; }
    }

    private Tree tree;
    private DataModel data_model = new DataModel ();

    /**
     * Creates a new {@link Granite.Widgets.SourceList}.
     *
     * @return A new {@link Granite.Widgets.SourceList}.
     * @since 0.2
     */
    public SourceList (ExpandableItem root = new ExpandableItem ()) {
        this.root = root;

        push_composite_child ();
        tree = new Tree (data_model);
        tree.set_composite_name ("treeview");
        pop_composite_child ();

        set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        add (tree);
        show_all ();

        tree.item_selected.connect ((item) => item_selected (item));
    }

    /**
     * Checks whether //item// is part of the source list.
     *
     * @param item The item to query.
     * @return //true// if the item belongs to the source list; //false// otherwise.
     * @since 0.2
     */
    public bool has_item (Item item) {
        return data_model.has_item (item);
    }

    /**
     * Sets the method used for sorting items.
     *
     * @param sort_func The method to use for sorting items.
     * @see Granite.Widgets.SourceList.SortFunc
     * @since 0.2
     */
    [Deprecated (replacement = "ExpandableItem.compare", since = "0.2")]
    public void set_sort_func (owned SortFunc? sort_func) {
        data_model.set_sort_func ((owned) sort_func);
    }

    /**
     * Sets the method used for filtering out items.
     *
     * @param visible_func The method to use for filtering items.
     * @param refilter Whether to call {@link Granite.Widgets.SourceList.refilter} using the new function.
     * @see Granite.Widgets.SourceList.VisibleFunc
     * @see Granite.Widgets.SourceList.refilter
     * @since 0.2
     */
    public void set_filter_func (VisibleFunc? visible_func, bool refilter) {
        data_model.set_filter_func (visible_func);
        if (refilter)
            this.refilter ();
    }

    /**
     * Applies the filter method set by {@link Granite.Widgets.SourceList.set_filter_func}
     * to all the items that are part of the current tree.
     *
     * @see Granite.Widgets.SourceList.VisibleFunc
     * @see Granite.Widgets.SourceList.set_filter_func
     * @since 0.2
     */
    public void refilter () {
        data_model.refilter ();
    }

    /**
     * Queries the actual expansion state of //item//.
     *
     * @see Granite.Widgets.SourceList.ExpandableItem.expanded
     * @return Whether //item// is expanded or not.
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
     * @see Granite.Widgets.SourceList.Item.editable
     * @see Granite.Widgets.SourceList.editing
     * @see Granite.Widgets.SourceList.stop_editing
     * @return true if the editing started successfully; false otherwise.
     * @since 0.2
     */
    public bool start_editing_item (Item item) requires (has_item (item)) {
        return tree.start_editing_item (item);
    }

    /**
     * Cancels any editing operation going on.
     *
     * @see Granite.Widgets.SourceList.editing
     * @see Granite.Widgets.SourceList.start_editing_item
     * @since 0.2
     */
    public void stop_editing () {
        if (editing)
            tree.stop_editing ();
    }

    /**
     * Scrolls the source list tree to make //item// visible.
     *
     * {@link Granite.Widgets.SourceList.ExpandableItem.expand_with_parents} is called
     * for the item's parent if //expand_parents// is //true//, to make sure it's not
     * hidden behind a collapsed row.
     *
     * If use_align is //false//, then the row_align argument is ignored, and the tree
     * does the minimum amount of work to scroll the item onto the screen. This means that
     * the item will be scrolled to the edge closest to its current position. If the item
     * is currently visible on the screen, nothing is done.
     *
     * @param item Item to scroll to.
     * @param expand_parents Whether to recursively expand item's parent in case they are collapsed.
     * @param use_align Whether to use the //row_align// argument.
     * @param row_align The vertical alignment of //item//. 0.0 means top, 0.5 center, and 1.0 bottom.
     * @return //true// if successful; //false// otherwise.
     * @since 0.2
     */
    public bool scroll_to_item (Item item, bool expand_parents = true, bool use_align = false, float row_align = 0)
        requires (has_item (item))
    {
        if (expand_parents && item.parent != null)
            item.parent.expand_with_parents ();

        return tree.scroll_to_item (item, use_align, row_align);
    }

    /**
     * Gets the previous item with respect to //reference//.
     *
     * @param reference Item to use as reference.
     * @return The item that appears before //reference//, or //null// if there's none.
     * @since 0.2
     */
    public Item? get_previous_item (Item reference) requires (has_item (reference)) {
        // this will return null for root, so iter_n_children() will always work fine
        var iter = data_model.get_item_iter (reference);
        if (iter != null) {
            Gtk.TreeIter new_iter = iter; // workaround for valac 0.18
            if (data_model.iter_previous (ref new_iter))
                return data_model.get_item (new_iter);
        }

        return null;
    }

    /**
     * Gets the next item with respect to //reference//.
     *
     * @param reference Item to use as reference.
     * @return The item that appears after //reference//, or //null// if there's none.
     * @since 0.2
     */
    public Item? get_next_item (Item reference) requires (has_item (reference)) {
        // this will return null for root, so iter_n_children() will always work fine
        var iter = data_model.get_item_iter (reference);
        if (iter != null) {
            Gtk.TreeIter new_iter = iter; // workaround for valac 0.18
            if (data_model.iter_next (ref new_iter))
                return data_model.get_item (new_iter);
        }

        return null;
    }

    /**
     * Gets the first visible child of an expandable item.
     *
     * @param parent Parent of the child to look up.
     * @return The first visible child of //parent//, or null if it was not found.
     * @since 0.2
     */
    public Item? get_first_child (ExpandableItem parent) {
        return get_nth_child (parent, 0);
    }

    /**
     * Gets the last visible child of an expandable item.
     *
     * @param parent Parent of the child to look up.
     * @return The last visible child of //parent//, or null if it was not found.
     * @since 0.2
     */
    public Item? get_last_child (ExpandableItem parent) {
        return get_nth_child (parent, (int) get_n_visible_children (parent) - 1);
    }

    /**
     * Gets the number of visible children of an expandable item.
     *
     * @param parent Item to query.
     * @return Number of visible children of //parent//.
     * @since 0.2
     */
    public uint get_n_visible_children (ExpandableItem parent) {
        // this will return null for root, so iter_n_children() will always work properly.
        var parent_iter = data_model.get_item_iter (parent);
        return data_model.iter_n_children (parent_iter);
    }

    private Item? get_nth_child (ExpandableItem parent, int index) {
        if (index < 0)
            return null;

        // this will return null for root, so iter_nth_child() will always work properly.
        var parent_iter = data_model.get_item_iter (parent);

        Gtk.TreeIter child_iter;
        if (data_model.iter_nth_child (out child_iter, parent_iter, index))
            return data_model.get_item (child_iter);

        return null;
    }
}
