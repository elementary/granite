/***
    Copyright (C) 2011-2013 Lucas Baudin <xapantu@gmail.com>,
                            Jaap Broekhuizen <jaapz.b@gmail.com>,
                            Victor Eduardo <victoreduardm@gmal.com>,
                            Tom Beckmann <tom@elementaryos.org>

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

public class Granite.Demo : Granite.Application {
    /**
     * Small helper class for constructing labels a bit faster.
     */
    private class LLabel : Gtk.Label {
        public LLabel (string label) {
            this.label = label;
            halign = Gtk.Align.START;
        }

        public LLabel.indent (string label) {
            this.label = label;
            margin_left = 12;
        }

        public LLabel.markup (string label) {
            this.label = label;
            use_markup = true;
        }

        public LLabel.right (string label) {
            this.label = label;
            halign = Gtk.Align.END;
        }

        public LLabel.right_with_markup (string label) {
            this.label = label;
            halign = Gtk.Align.END;
        }
    }

    private class SourceListRootItem : Granite.Widgets.SourceList.ExpandableItem,
                                       Granite.Widgets.SourceListSortable
    {
        public SourceListRootItem () {
            base ("SourceListRootItem");

            user_moved_item.connect ((moved) => {
                message ("Category '%s' moved through DnD", moved.name);
            });
        }

        // allow re-ordering main categories through DnD
        public bool allow_dnd_sorting () {
            return true;
        }

        public int compare (Granite.Widgets.SourceList.Item a,
                            Granite.Widgets.SourceList.Item b)
        {
            // when an item is reordered through DnD, its actual final location
            // is determined by the compare function, so we want to make sure
            // it doesn't conflict with the order established by the user
            return 0;
        }
    }

    private class SourceListSortableItem : Granite.Widgets.SourceList.ExpandableItem,
                                           Granite.Widgets.SourceListSortable
    {
        public SourceListSortableItem (string name) {
            base (name);
        }

        public bool allow_dnd_sorting () {
            return true;
        }

        public int compare (Granite.Widgets.SourceList.Item a,
                            Granite.Widgets.SourceList.Item b)
        {
            // while we could impose some restrictions regarding the order of
            // the items, here we just allow free DnD reordering.
            return 0;
        }
    }

    private class SourceListSortedItem : Granite.Widgets.SourceList.ExpandableItem,
                                         Granite.Widgets.SourceListSortable
    {
        public SourceListSortedItem (string name) {
            base (name);
        }

        public bool allow_dnd_sorting () {
            return false;
        }

        public int compare (Granite.Widgets.SourceList.Item a,
                            Granite.Widgets.SourceList.Item b)
        {
            return strcmp (a.name.collate_key (), b.name.collate_key ());
        }
    }

    /**
     * SourceList item. It stores the number of the corresponding page in the notebook widget.
     */
    private class SourceListItem : Granite.Widgets.SourceList.ExpandableItem,
                                   Granite.Widgets.SourceListDragSource,
                                   Granite.Widgets.SourceListDragDest
    {
        public int page_num { get; set; default = -1; }
        private static Icon? themed_icon;

        public SourceListItem (string title) {
            base (title);
            editable = true;

            if (themed_icon == null)
                themed_icon = new ThemedIcon.with_default_fallbacks ("help-info-symbolic");

            icon = themed_icon;
        }

        public bool draggable () {
            return true;
        }

        public void prepare_selection_data (Gtk.SelectionData data) {
        }

        public bool data_drop_possible (Gdk.DragContext context, Gtk.SelectionData data) {
            return true;
        }

        public Gdk.DragAction data_received (Gdk.DragContext context, Gtk.SelectionData data) {
            message ("drag data dropped into '%s'", name);
            return Gdk.DragAction.COPY;
        }
    }

    private Gtk.Grid main_layout; // outer-most container
    private Granite.Widgets.ModeButton mode_button;
    private int dark_mode_index;

    /**
     * Basic app information for Granite.Application. This is used by the About dialog.
     */
    construct {
        application_id = "org.pantheon.granite.demo";
        flags = ApplicationFlags.FLAGS_NONE;

        program_name = "Granite Demo";
        app_years = "2011 - 2013";

        build_version = "0.2.3";
        app_icon = "text-editor";
        main_url = "https://launchpad.net/granite";
        bug_url = "https://bugs.launchpad.net/granite";
        help_url = "https://answers.launchpad.net/granite";
        translate_url = "https://translations.launchpad.net/granite";

        about_documenters = { null };
        about_artists = { "Daniel P. Fore <daniel@elementaryos.org>" };
        about_authors = {
            "Maxwell Barvian <mbarvian@gmail.com>",
            "Daniel Foré <daniel@elementaryos.org>",
            "Avi Romanoff <aviromanoff@gmail.com>",
            "Lucas Baudin <xapantu@gmail.com>",
            "Victor Eduardo <victoreduardm@gmail.com>",
            "Tom Beckmann <tombeckmann@online.de>",
        };

        about_comments = "A demo of the Granite toolkit";
        about_translators = "Launchpad Translators";
        about_license_type = Gtk.License.GPL_3_0;
    }

    public override void activate () {
        var window = new Gtk.Window ();
        window.title = "Granite Demo";
        window.window_position = Gtk.WindowPosition.CENTER;

        this.add_window (window);

        var main_toolbar = new Gtk.Toolbar ();
        main_toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_PRIMARY_TOOLBAR);
        main_toolbar.hexpand = true;
        main_toolbar.vexpand = false;

        // SourceList
        var sidebar = new Granite.Widgets.SourceList (new SourceListRootItem ());
        sidebar.width_request = 200;

        var page_switcher = new Gtk.Notebook ();
        page_switcher.show_tabs = false;
        page_switcher.show_border = false;
        page_switcher.expand = true;

        sidebar.item_selected.connect ((item) => {
            var sidebar_item = item as SourceListItem;
            if (sidebar_item != null)
                page_switcher.set_current_page (sidebar_item.page_num);
        });

        // Main sidebar categories
        var widgets_category = new SourceListSortedItem ("Widgets");
        var test_category = new SourceListSortableItem ("Test");

        for (int ctr = 0; ctr < 10; ctr++) {
            var item = new SourceListSortableItem ("Item %i".printf (ctr));
            item.selectable = ctr % 3 != 0;

            for (int i = 0; i < 5; i++)
                item.add (new SourceListItem ("SubItem %i / %i".printf (ctr, i)));

            test_category.add (item);
        }

        // Add and expand categories
        sidebar.root.add (widgets_category);
        sidebar.root.add (test_category);
        sidebar.root.expand_all ();

        var sidebar_paned = new Granite.Widgets.ThinPaned ();
        sidebar_paned.pack1 (sidebar, true, false);
        sidebar_paned.pack2 (page_switcher, true, false);
        sidebar_paned.expand = true;

        // Statusbar
        var statusbar = new Granite.Widgets.StatusBar ();
        statusbar.set_text ("Granite.Widgets.StatusBar");
        statusbar.hexpand = true;
        statusbar.vexpand = false;

        // Main widget structure
        main_layout = new Gtk.Grid ();
        main_layout.expand = true;
        main_layout.orientation = Gtk.Orientation.VERTICAL;
        main_layout.add (main_toolbar);
        main_layout.add (sidebar_paned);
        main_layout.add (statusbar);

        window.add (main_layout);

        // Welcome widget
        var welcome_screen = create_welcome_screen ();
        var welcome_item = new SourceListItem ("Welcome");
        widgets_category.add (welcome_item);
        welcome_item.page_num = page_switcher.append_page (welcome_screen, null);

        // Select welcome widget
        sidebar.selected = welcome_item;

        // Light window
        var light_window_icon = new Gtk.Image.from_icon_name ("document-new", Gtk.IconSize.LARGE_TOOLBAR);
        var light_window_item = new Gtk.ToolButton (light_window_icon, "Show LightWindow");
        light_window_item.icon_name = "document-new";
        light_window_item.tooltip_text = "Show Light Window";
        light_window_item.halign = light_window_item.valign = Gtk.Align.CENTER;
        light_window_item.clicked.connect (show_light_window);

        main_toolbar.insert (light_window_item, -1);

        // StaticNotebook
        var staticnotebook = new Granite.Widgets.StaticNotebook ();
        var pageone = new Gtk.Label ("Page 1");

        staticnotebook.append_page (new Gtk.Label ("Page 1"), pageone);
        staticnotebook.append_page (get_overlay_bar_widget (), new Gtk.Label ("Overlay Bar"));
        staticnotebook.append_page (new Gtk.Label ("Page 3"), new Gtk.Label ("Page 3"));

        staticnotebook.page_changed.connect (() => {
            pageone.set_text ("Page changed");
        });

        var static_notebook_item = new SourceListItem ("StaticNotebook");
        static_notebook_item.page_num = page_switcher.append_page (staticnotebook, null);
        widgets_category.add (static_notebook_item);

        // ModeButton
        mode_button = new Granite.Widgets.ModeButton ();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;

        var normal_mode_index = mode_button.append (new Gtk.Label ("Light"));
        dark_mode_index = mode_button.append (new Gtk.Label ("Dark"));

        mode_button.selected = normal_mode_index;

        on_theme_mode_button_changed ();

        mode_button.mode_changed.connect (on_theme_mode_button_changed);

        var mode_button_item = new Gtk.ToolItem ();
        mode_button_item.add (mode_button);
        main_toolbar.insert (mode_button_item, -1);

        mode_button_item.halign = mode_button_item.valign = Gtk.Align.CENTER;

        // PopOvers
        var popover_statusbar_item = new Gtk.Button ();
        popover_statusbar_item.relief = Gtk.ReliefStyle.NONE;
        popover_statusbar_item.tooltip_text = "Show PopOver";
        popover_statusbar_item.add (new Gtk.Image.from_icon_name ("help-info-symbolic",
                                                                  Gtk.IconSize.MENU));
        statusbar.insert_widget (popover_statusbar_item);

        popover_statusbar_item.clicked.connect (() => {
            var pop = new Granite.Widgets.PopOver ();

            var pop_hbox = pop.get_content_area () as Gtk.Container;
            pop_hbox.add (new Granite.Widgets.HintedEntry ("This is an HintedEntry"));
            pop_hbox.add (new Gtk.Label ("Another label"));

            var mode_pop = new Granite.Widgets.ModeButton ();
            mode_pop.append (new Gtk.Label ("Mode 1"));
            mode_pop.append (new Gtk.Label ("Mode 2"));
            mode_pop.append (new Gtk.Label ("Mode 3"));

            pop_hbox.add (mode_pop);
            pop_hbox.add (new Granite.Widgets.DatePicker ());

            pop.set_parent_pop (window);
            pop.move_to_widget (popover_statusbar_item);

            pop.show_all ();
            pop.present ();
            pop.run ();
            pop.destroy ();
        });

        // Date widget
        var calendar_tool_item = new Gtk.ToolItem ();
        calendar_tool_item.margin_left = 12;
        var date_button = new Granite.Widgets.DatePicker.with_format ("%d-%m-%y");
        calendar_tool_item.add (date_button);
        main_toolbar.insert (calendar_tool_item, -1);

        // Time widget
        var time_tool_item = new Gtk.ToolItem ();
        time_tool_item.margin_left = 12;
        time_tool_item.valign = Gtk.Align.CENTER;
        var time_button = new Granite.Widgets.TimePicker ();
        time_tool_item.add (time_button);
        main_toolbar.insert (time_tool_item, -1);

        // Dynamic notebook
        var dynamic_notebook = create_dynamic_notebook ();
        var dynamic_notebook_item = new SourceListItem ("DynamicNotebook");
        widgets_category.add (dynamic_notebook_item);
        dynamic_notebook_item.page_num = page_switcher.append_page (dynamic_notebook, null);

        var right_sep = new Gtk.SeparatorToolItem ();
        right_sep.draw = false;
        right_sep.set_expand (true);
        main_toolbar.insert (right_sep, -1);

        // Search Entry
        var search_entry = new Granite.Widgets.SearchBar ("Search");
        var search_item = new Gtk.ToolItem ();
        search_item.add (search_entry);
        search_item.margin_left = 12;
        main_toolbar.insert (search_item, -1);

        // App Menu (this gives access to the About dialog)
        var main_menu = create_appmenu (new Gtk.Menu ());
        main_menu.margin_left = 12;
        main_toolbar.insert (main_menu, -1);

        window.set_default_size (800, 550);
        window.show_all ();
    }

    private void on_theme_mode_button_changed () {
        var settings = Gtk.Settings.get_default ();
        settings.gtk_application_prefer_dark_theme = (mode_button.selected == dark_mode_index);
    }

    private Granite.Widgets.Welcome create_welcome_screen () {
        var welcome = new Granite.Widgets.Welcome ("Granite's Welcome Screen",
                                                    "This Is Granite's Welcome Widget.");

        Gdk.Pixbuf? pixbuf = null;

        try {
            pixbuf = Gtk.IconTheme.get_default ().load_icon ("document-new", 48,
                                                             Gtk.IconLookupFlags.GENERIC_FALLBACK);
        } catch (Error e) {
            warning ("Could not load icon, %s", e.message);
        }

        Gtk.Image? image = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.DIALOG);

        // Adding elements. Use the most convenient method to add an icon
        welcome.append_with_pixbuf (pixbuf, "Create", "Write a new document.");
        welcome.append_with_image (image, "Open", "Select a file.");
        welcome.append ("document-save", "Save", "With a much longer description.");

        welcome.activated.connect ((index) => {
            var button = welcome.get_button_from_index (index);

            button.title = "You clicked on the button: %d".printf(index);
            button.description = "This label, description and icon were changed after creating of this button.";
            button.icon.icon_name = "edit";
        });

        return welcome;
    }

    private void show_light_window () {
        var light_window = new Granite.Widgets.LightWindow ();

        var light_window_notebook = new Granite.Widgets.StaticNotebook ();
        var entry = new Gtk.Entry ();
        var open_drop = new Gtk.ComboBoxText ();
        var open_lbl = new LLabel ("Alwas Open Mpeg Video Files with Audience");

        var grid = new Gtk.Grid ();
        grid.attach (new Gtk.Image.from_icon_name ("video-x-generic", Gtk.IconSize.DIALOG), 0, 0, 1, 2);
        grid.attach (entry, 1, 0, 1, 1);
        grid.attach (new LLabel ("1.13 GB, Mpeg Video File"), 1, 1, 1, 1);

        grid.attach (light_window_notebook, 0, 2, 2, 1);

        var general = new Gtk.Grid ();
        general.attach (new LLabel.markup ("<b>Info:</b>"), 0, 0, 2, 1);

        general.attach (new LLabel.right ("Created:"), 0, 1, 1, 1);
        general.attach (new LLabel.right ("Modified:"), 0, 2, 1, 1);
        general.attach (new LLabel.right ("Opened:"), 0, 3, 1, 1);
        general.attach (new LLabel.right ("Mimetype:"), 0, 4, 1, 1);
        general.attach (new LLabel.right ("Location:"), 0, 5, 1, 1);

        general.attach (new LLabel ("Today at 9:50 PM"), 1, 1, 1, 1);
        general.attach (new LLabel ("Today at 9:50 PM"), 1, 2, 1, 1);
        general.attach (new LLabel ("Today at 10:00 PM"), 1, 3, 1, 1);
        general.attach (new LLabel ("video/mpeg"), 1, 4, 1, 1);
        general.attach (new LLabel ("/home/daniel/Downloads"), 1, 5, 1, 1);

        general.attach (new LLabel.markup ("<b>Open with:</b>"), 0, 6, 2, 1);
        general.attach (open_drop, 0, 7, 2, 1);
        general.attach (open_lbl, 0, 8, 2, 1);

        light_window_notebook.append_page (general, new Gtk.Label ("General"));
        light_window_notebook.append_page (new Gtk.Label ("More"), new Gtk.Label ("More"));
        light_window_notebook.append_page (new Gtk.Label ("Sharing"), new Gtk.Label ("Sharing"));

        open_lbl.margin_left = 24;
        open_drop.margin_left = 12;
        open_drop.append ("audience", "Audience");
        open_drop.active = 0;
        grid.margin = 12;
        grid.margin_top = 24;
        grid.margin_bottom = 24;
        entry.text = "Cool Hand Luke";
        general.column_spacing = 6;
        general.row_spacing = 6;

        light_window.add (grid);
        light_window.show_all ();
    }

    private Granite.Widgets.DynamicNotebook create_dynamic_notebook () {
        int i = 3;

        var dynamic_notebook = new Granite.Widgets.DynamicNotebook ();

        dynamic_notebook.allow_duplication = true;
        dynamic_notebook.allow_restoring = true;
        dynamic_notebook.max_restorable_tabs = 5;
        dynamic_notebook.allow_pinning = true;
        dynamic_notebook.show_icons = true;
        dynamic_notebook.add_button_tooltip = "New user tab";

        var tab = new Granite.Widgets.Tab ("user1@elementaryos: ~",
                                           new ThemedIcon ("empty"),
                                           new Gtk.Label ("Page 1"));
        tab.restore_data = "1";
        tab.working = true;
        dynamic_notebook.insert_tab (tab, -1);

        var tab2 = new Granite.Widgets.Tab ("user2@elementaryos: ~",
                                            new ThemedIcon ("empty"),
                                            new Gtk.Label ("Page 2"));
        tab2.restore_data = "2";
        dynamic_notebook.insert_tab (tab2, -1);

        dynamic_notebook.new_tab_requested.connect (() => {
            var t = new Granite.Widgets.Tab (@"user$i@elementaryos: ~",
                                             new ThemedIcon ("empty"),
                                             new Gtk.Label (@"Page $i"));
            t.restore_data = i.to_string ();
            i++;
            dynamic_notebook.insert_tab (t, -1);
        });

        dynamic_notebook.tab_restored.connect ((label, data, icon) => {
            var t = new Granite.Widgets.Tab (label,
                                             icon,
                                             new Gtk.Label ("Page " + data));
            t.restore_data = data;
            dynamic_notebook.insert_tab (t, -1);
            print ("Restored tab %s\n", label);
        });

        dynamic_notebook.tab_duplicated.connect ((t) => {
            var num = t.restore_data;
            var t2 = new Granite.Widgets.Tab (@"user$num@elementaryos: ~",
                                              new ThemedIcon ("empty"),
                                              new Gtk.Label (@"Page $num"));

            t2.restore_data = t.restore_data;
            dynamic_notebook.insert_tab (t2, -1);
            print ("Duplicated tab %s\n", t2.label);
        });

        dynamic_notebook.tab_moved.connect ((t, p) => {
            print ("Moved tab %s to %i\n", t.label, p);
        });

        dynamic_notebook.tab_switched.connect ((old_t, new_t) => {
            print ("Switched from %s to %s\n", old_t.label, new_t.label);
        });

        dynamic_notebook.tab_removed.connect ((t) => {
            print ("Removed tab %s\n", t.label);
        });

        return dynamic_notebook;
    }

    private Gtk.Widget get_overlay_bar_widget () {
        // OverlayBar (inside StaticNotebook)
        var overlay = new Gtk.Overlay ();
        overlay.add (new Gtk.Label ("Try to touch the Overlay Bar!"));

        var overlay_bar = new Granite.Widgets.OverlayBar (overlay);
        overlay_bar.status = "Overlay Bar Example";

        return overlay;
    }

    public static int main (string[] args) {
        var application = new Granite.Demo ();

        return application.run (args);
    }
}
