/*-
 * Copyright (c) 2011-2012       Scott Ringwelski <sgringwe@mtu.edu>
 *
 * Originally Written by Scott Ringwelski for BeatBox Music Player and Granite Library
 * BeatBox Music Player: http://www.launchpad.net/beat-box
 * Granite Library:      http://www.launchpad.net/granite
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or  (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

/**
 * NOTES: The iters returned are child model iters. To work with any function
 * except for add, you need to to use convert_to_filter (child iter);
 */
public class Granite.Widgets.Sidebar : Gtk.TreeView {

    private class CellRendererExpander : Gtk.CellRenderer {
        public bool expanded;
        public const int EXPANDER_SIZE = 8;

        public CellRendererExpander () {
            expanded = false;
        }

        public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
            out int x_offset, out int y_offset, out int width, out int height) {
            x_offset = 0;
            y_offset = EXPANDER_SIZE / 2;
            width = height = EXPANDER_SIZE;
        }

        public override void render (Cairo.Context context, Gtk.Widget widget,
            Gdk.Rectangle background_area, Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
            widget.get_style_context ().set_state (expanded ? Gtk.StateFlags.ACTIVE : Gtk.StateFlags.NORMAL);
            widget.get_style_context ().render_expander (context, cell_area.x + EXPANDER_SIZE / 2,
                                                         cell_area.y + EXPANDER_SIZE / 2,
                                                         EXPANDER_SIZE, EXPANDER_SIZE);
        }
    }

    public enum Column {
        COLUMN_OBJECT,
        COLUMN_WIDGET,
        COLUMN_VISIBLE,
        COLUMN_PIXBUF,
        COLUMN_TEXT,
        COLUMN_CLICKABLE
    }

    public bool autoExpanded;

    public signal void clickable_clicked (Gtk.TreeIter iter);
    public signal void true_selection_change (Gtk.TreeIter selected);

    private Gtk.TreeStore tree;
    private Gtk.TreeModelFilter filter;
    private Gtk.TreeIter? selectedIter;

    private Gtk.CellRendererText spacer;
    private Gtk.CellRendererText secondary_spacer;
    private Gtk.CellRendererPixbuf pix_cell;
    private Gtk.CellRendererText text_cell;
    private Gtk.CellRendererPixbuf clickable_cell;
    private CellRendererExpander expander_cell;


    public Sidebar () {
        tree = new Gtk.TreeStore (6, typeof (Object), typeof (Gtk.Widget), typeof (bool), typeof (Gdk.Pixbuf), typeof (string), typeof (Gdk.Pixbuf));
        filter = new Gtk.TreeModelFilter (tree, null);
        set_model (filter);

        Gtk.TreeViewColumn col = new Gtk.TreeViewColumn ();
        col.title = "object";
        this.insert_column (col, 0);

        col = new Gtk.TreeViewColumn ();
        col.title = "widget";
        this.insert_column (col, 1);

        col = new Gtk.TreeViewColumn ();
        col.title = "visible";
        this.insert_column (col, 2);

        col = new Gtk.TreeViewColumn ();
        col.title = "display";
        col.expand = true;
        this.insert_column (col, 3);

        // add spacer
        spacer = new Gtk.CellRendererText ();
        col.pack_start (spacer, false);
        col.set_cell_data_func (spacer, spacer_cell_data_func);
        spacer.xpad = 8;

        // secondary spacer
        secondary_spacer = new Gtk.CellRendererText ();
        col.pack_start (secondary_spacer, false);
        col.set_cell_data_func (secondary_spacer, secondary_spacer_cell_data_func);
        secondary_spacer.xpad = 8;

        // add pixbuf
        pix_cell = new Gtk.CellRendererPixbuf ();
        col.pack_start (pix_cell, false);
        col.set_cell_data_func (pix_cell, pixbuf_cell_data_func);
        col.set_attributes (pix_cell, "pixbuf", Column.COLUMN_PIXBUF);

        // add text
        text_cell = new Gtk.CellRendererText ();
        col.pack_start (text_cell, true);
        col.set_cell_data_func (text_cell, string_cell_data_func);
        col.set_attributes (text_cell, "markup", Column.COLUMN_TEXT);
        text_cell.ellipsize = Pango.EllipsizeMode.END;
        text_cell.xalign = 0.0f;
        text_cell.xpad = 3;

        // add clickable icon
        clickable_cell = new Gtk.CellRendererPixbuf ();
        col.pack_start (clickable_cell, false);
        col.set_cell_data_func (clickable_cell, clickable_cell_data_func);
        col.set_attributes (clickable_cell, "pixbuf", Column.COLUMN_CLICKABLE);
        clickable_cell.mode = Gtk.CellRendererMode.ACTIVATABLE;
        clickable_cell.xpad = 2;
        clickable_cell.xalign = 1.0f;
        clickable_cell.stock_size = 16;

        // add expander
        expander_cell = new CellRendererExpander ();
        col.pack_start (expander_cell, false);
        col.set_cell_data_func (expander_cell, expander_cell_data_func);

        this.set_headers_visible (false);
        //this.set_expander_column (get_column (3));
        this.set_show_expanders (false);
        filter.set_visible_column (Column.COLUMN_VISIBLE);
        this.set_grid_lines (Gtk.TreeViewGridLines.NONE);
        this.name = "SidebarContent";

        // Setup theming
        this.get_style_context ().add_class  (Gtk.STYLE_CLASS_SIDEBAR);

        this.get_selection ().changed.connect (selection_change);
        this.button_press_event.connect (sidebar_click);
    }

    private static void spacer_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                               Gtk.TreeModel model, Gtk.TreeIter iter) {
        Gtk.TreePath path = model.get_path (iter);
        int depth = path.get_depth ();

        renderer.visible =  (depth > 1);
        renderer.xpad =  (depth > 1) ? 8 : 0;
    }

    private static void secondary_spacer_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                                  Gtk.TreeModel model, Gtk.TreeIter iter) {
        Gtk.TreePath path = model.get_path (iter);
        int depth = path.get_depth ();

        renderer.visible =  (depth > 2);
        renderer.xpad =  (depth > 1) ? 8 : 0;
    }

    private static void pixbuf_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                               Gtk.TreeModel model, Gtk.TreeIter iter) {
        Gtk.TreePath path = model.get_path (iter);

        if (path.get_depth () == 1) {
            renderer.visible = false;
        }
        else {
            renderer.visible = true;
        }
    }

    private static void string_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                               Gtk.TreeModel model, Gtk.TreeIter iter) {
        Gtk.TreePath path = model.get_path (iter);
        int depth = path.get_depth ();
        string text = "";
        model.get (iter, Column.COLUMN_TEXT, out text);

        if (depth == 1) {
             ( (Gtk.CellRendererText)renderer).markup = "<b>" + text + "</b>";
        }
        else {
             ( (Gtk.CellRendererText)renderer).markup = text;
        }
    }

    private static void clickable_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                                  Gtk.TreeModel model, Gtk.TreeIter iter) {
        Gtk.TreePath path = model.get_path (iter);

        if (path.get_depth () == 1) {
            renderer.visible = false;
        }
        else {
            renderer.visible = true;
        }
    }

    private static void expander_cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer renderer,
                                                 Gtk.TreeModel model, Gtk.TreeIter iter) {
        Gtk.TreePath path = model.get_path (iter);

        renderer.visible =  (path.get_depth () == 1);
         ( (CellRendererExpander)renderer).expanded = is_row_expanded (path);
    }

    /* Convenient add/remove/edit methods */
    public Gtk.TreeIter add_item (Gtk.TreeIter? parent, Object? o, Gtk.Widget? w, Gdk.Pixbuf? pixbuf, string text, Gdk.Pixbuf? clickable) {
        Gtk.TreeIter iter;

        tree.append (out iter, parent);
        tree.set (iter, 0, o, 1, w, 2, true, 3, pixbuf, 4, text, 5, clickable);

        if (parent != null) {
            tree.set (parent, 2, true);
        }
        else {
            tree.set (iter, 2, false);
        }

        expand_all ();
        return iter;
    }

    public bool remove_item (Gtk.TreeIter iter) {
        Gtk.TreeIter parent;
        if (tree.iter_parent (out parent, iter)) {
            if (tree.iter_n_children (parent) > 1)
                tree.set (parent, 2, true);
            else
                tree.set (parent, 2, false);
        }

        Gtk.Widget w;
        tree.get (iter, Column.COLUMN_WIDGET, out w);
        w.destroy ();

        // destroy child row widgets as well
        Gtk.TreeIter current;
        if (tree.iter_children (out current, iter)) {
            do {
                tree.get (current, Column.COLUMN_WIDGET, out w);
                w.destroy ();
            }
            while (tree.iter_next (ref current));
        }

        return tree.remove (iter);
    }

    // input MUST be a child iter
    public void set_item_visibility (Gtk.TreeIter it, bool val) {
        bool was = false;
        tree.get (it, Column.COLUMN_VISIBLE, out was);
        tree.set (it, Column.COLUMN_VISIBLE, val);

        if (val && !was) {
            warning  ("error happening sidebar.vala...");
            expand_row (filter.get_path (convert_to_filter (it)), true);
            warning  ("error finished");
        }
    }

    public void set_item_name (Gtk.TreeIter it, string name) {
        Gtk.TreeIter iter = convert_to_child (it);

        tree.set (iter, Column.COLUMN_TEXT, name);
    }

    // parent should be filter iter
    public bool set_item_name_from_object (Gtk.TreeIter parent, Object o, string name) {
        Gtk.TreeIter realParent = convert_to_child (parent);
        Gtk.TreeIter pivot;
        tree.iter_children (out pivot, realParent);

        do {
            Object tempO;
            tree.get (pivot, 0, out tempO);

            if (tempO == o) {
                tree.set (pivot, Column.COLUMN_TEXT, name);
                return true;
            }
            else if (!tree.iter_next (ref pivot)) {
                return false;
            }

        } while (true);
    }

    public Gtk.TreeIter? get_selected_iter () {
        Gtk.TreeModel mod;
        Gtk.TreeIter sel;

        if (this.get_selection ().get_selected (out mod, out sel)) {
            return sel;
        }

        return null;
    }

    public void set_selected_iter (Gtk.TreeIter iter) {
        this.get_selection ().changed.disconnect (selection_change);
        get_selection ().unselect_all ();

        get_selection ().select_iter (iter);
        this.get_selection ().changed.connect (selection_change);
        selectedIter = iter;
    }

    public bool expand_item (Gtk.TreeIter iter, bool expanded) {
        if  (filter.iter_n_children  (convert_to_filter  (iter)) < 1)
            return false;

        Gtk.TreePath? path = filter.get_path  (convert_to_filter  (iter));

        if  (path == null || path.get_depth  () > 1)
            return false;

        if  (expanded)
            return expand_row  (path, false);

        return collapse_row  (path);
    }

    public bool item_expanded  (Gtk.TreeIter? iter) {
        if  (iter != null)
            return is_row_expanded  (filter.get_path  (convert_to_filter  (iter)));

        return false;
    }

    public Object? get_object (Gtk.TreeIter iter) {
        Object o;
        filter.get (iter, Column.COLUMN_OBJECT, out o);
        return o;
    }

    public Gtk.Widget? get_widget (Gtk.TreeIter iter) {
        Gtk.Widget w;
        tree.get (iter, Column.COLUMN_WIDGET, out w);
        return w;
    }

    public Gtk.Widget? get_selected_widget () {
        Gtk.TreeModel m;
        Gtk.TreeIter iter;

        if (!this.get_selection ().get_selected (out m, out iter)) { // user has nothing selected, reselect last selected
            //if (iter == null)
                return null;
        }

        Gtk.Widget w;
        m.get (iter, Column.COLUMN_WIDGET, out w);
        return w;
    }

    public Object? get_selected_object () {
        Gtk.TreeModel m;
        Gtk.TreeIter iter;

        if (!this.get_selection ().get_selected (out m, out iter)) { // user has nothing selected, reselect last selected
            //if (iter == null)
                return null;
        }

        Object o;
        m.get (iter, Column.COLUMN_OBJECT, out o);
        return o;
    }

    /* stops user from selecting the root nodes */
    public void selection_change () {
        Gtk.TreeModel model;
        Gtk.TreeIter pending;

        if (!this.get_selection ().get_selected (out model, out pending)) { // user has nothing selected, reselect last selected
            if (selectedIter != null) {
                this.get_selection ().select_iter (selectedIter);
            }

            return;
        }

        Gtk.TreePath path = model.get_path (pending);

        if (path.get_depth () == 1) {
            this.get_selection ().unselect_all ();
            if (selectedIter != null)
                this.get_selection ().select_iter (selectedIter);
        }
        else if (pending != selectedIter) {
            selectedIter = pending;
            true_selection_change (selectedIter);
        }
    }

    /* click event functions */
    private bool sidebar_click (Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == 1) {
            // select one based on mouse position
            Gtk.TreeIter iter;
            Gtk.TreePath path;
            Gtk.TreeViewColumn column;
            int cell_x;
            int cell_y;

            this.get_path_at_pos ( (int)event.x,  (int)event.y, out path, out column, out cell_x, out cell_y);

            if (!filter.get_iter (out iter, path))
                return false;

            if (over_clickable (iter, column,  (int)cell_x,  (int)cell_y)) {
                clickable_clicked (iter);
            }
            else if (over_expander (iter, column,  (int)cell_x,  (int)cell_y)) {
                if (is_row_expanded (path))
                    this.collapse_row (path);
                else
                    this.expand_row (path, true);
            }
        }

        return false;
    }

    private bool over_clickable (Gtk.TreeIter iter, Gtk.TreeViewColumn col, int x, int y) {
        Gdk.Pixbuf pix;
        filter.get (iter, 5, out pix);

        if (pix == null)
            return false;

        int cell_x;
        int cell_width;
        col.cell_get_position (clickable_cell, out cell_x, out cell_width);

        if (x > cell_x && x < cell_x + cell_width)
            return true;

        return false;
    }

    private bool over_expander (Gtk.TreeIter iter, Gtk.TreeViewColumn col, int x, int y) {
        if (filter.get_path (iter).get_depth () != 1)
            return false;
        else
            return true;

        /* for some reason, the pixbuf SOMETIMES takes space, somtimes doesn't so cope for that *
        int pixbuf_start;
        int pixbuf_width;
        col.cell_get_position (pix_cell, out pixbuf_start, out pixbuf_width);
        int text_start;
        int text_width;
        col.cell_get_position (text_cell, out text_start, out text_width);
        int click_start;
        int click_width;
        col.cell_get_position (clickable_cell, out click_start, out click_width);
        int total = text_start + text_width + click_width - pixbuf_start;

        if (x > total)
            return true;

        return false;*/
    }

    /* Helpers for child->filter, filter->child */
    public Gtk.TreeIter? convert_to_filter (Gtk.TreeIter? child) {
        if (child == null)
            return null;

        Gtk.TreeIter rv;

        if (filter.convert_child_iter_to_iter (out rv, child)) {
            return rv;
        }

        return null;
    }

    public Gtk.TreeIter? convert_to_child (Gtk.TreeIter? filt) {
        if (filt == null)
            return null;

        Gtk.TreeIter rv;
        filter.convert_iter_to_child_iter (out rv, filt);

        return rv;
    }
}
