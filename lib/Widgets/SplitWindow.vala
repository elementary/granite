/*
* Copyright 2019 Alex Angelou
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

/**
 * A split ApplicationWindow that appears to have no titlebar. This type of window is perfect for very sidebar based workflows.
 *
 * Warning:
 * Due to the nature of Gtk, such a window is not possible to have an edge-to-edge top/bottom layout.
 * Please use the headerbars and the separators provided, and mind the 4px margin on the bottom.
 * Also, mind that you will have to properly size your application and margin the headerbar widgets properly.
 * 
 * ''Example''<<BR>>
 * {{{
 * public class Application : Gtk.Application {
 * 
 *     delegate void VoidFunc ();
 * 
 *     public Application () {
 *         Object (
 *             flags: ApplicationFlags.FLAGS_NONE
 *         );
 *     }
 * 
 *     protected override void activate () {
 *         var welcome = new Granite.Widgets.Welcome ("Split Window demo", "Show yourself around");
 *         welcome.append ("text-x-vala", "Read the code", "Read the code of this demo on GitHub");
 *         welcome.set_size_request (450, 400);
 * 
 *         var provider = new Gtk.CssProvider ();
 *         try {
 *             provider.load_from_data ("""
 *                 .normal-bg {
 *                     background-color: @bg-color;
 *                 }
 *             """);
 *         } catch (Error e) {
 *             assert_not_reached ();
 *         }
 * 
 *         var welcome_style = welcome.get_style_context ();
 *         welcome_style.add_class ("normal-bg");
 *         welcome_style.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
 * 
 *         var locations_category = new Granite.Widgets.SourceList.ExpandableItem ("Locations");
 *         for (var i=0; i<10; i++) {
 *             var item = new Granite.Widgets.SourceList.Item (@"Location $i");
 *             locations_category.add (item);
 *         }
 *         locations_category.expanded = true;
 * 
 *         var source_list = new Granite.Widgets.SourceList ();
 *         source_list.set_size_request (150, -1);
 * 
 *         var root = source_list.root;
 *         root.add (locations_category);
 * 
 *         var main_window = new SplitWindow (this);
 *         main_window.main_add (welcome);
 *         main_window.sidebar_add (locations_category);
 *         main_window.has_main_separator = true;
 * 
 *         var hb_main_button = new Gtk.Button.with_label ("Show main separator");
 *         hb_main_button.margin = 6;
 *         hb_main_button.margin_end = 0;
 *         hb_main_button.clicked.connect (() => {
 *             main_window.has_main_separator = ! main_window.has_main_separator;
 *         });
 * 
 *         var hb_sidebar_button = new Gtk.Button.with_label ("Show sidebar separator");
 *         hb_sidebar_button.margin = 6;
 *         hb_sidebar_button.margin_end = 0;
 *         hb_sidebar_button.clicked.connect (() => {
 *             main_window.has_sidebar_separator = ! main_window.has_sidebar_separator;
 *         });
 * 
 *         var main_hb = main_window.main_headerbar;
 *         main_hb.pack_start (hb_main_button);
 *         main_hb.pack_start (hb_sidebar_button);
 * 
 *         var sidebar_hb = main_window.sidebar_headerbar;
 *         sidebar_hb.title = "Example";
 * 
 *         main_window.paned_separator_position = 150;
 *         main_window.set_size_request (600, 400);
 *         main_window.set_default_size (600, 400);
 *         main_window.show_all ();
 *     }
 * }
 * 
 * public static int main (string[] args) {
 *     var app = new Application ();
 *     return app.run (args);
 * }
 * }}}
 */
public class Granite.Widgets.SplitWindow : Gtk.ApplicationWindow {

    private Gtk.Paned header_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
    private Gtk.Paned paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

    private Gtk.Grid sidebar = new Gtk.Grid ();
    private Gtk.Grid main_box = new Gtk.Grid ();
    private Gtk.HeaderBar mainbox_header = new Gtk.HeaderBar ();
    private Gtk.HeaderBar sidebar_header = new Gtk.HeaderBar ();
    private Gtk.Separator main_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
    private Gtk.Separator sidebar_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

    /**
     * The position of the separator that separates the the sidebar and the main view
     */
    public int paned_separator_position {
        get {
            return paned.position;
        }
        set {
            paned.position = value;
        }
    }

    /**
     * Gets the headerbar which sits on top of the main part of the window.
     */
    public Gtk.HeaderBar main_headerbar {
        get {
            return mainbox_header;
        }
    }

    /**
     * Gets the headerbar which sits on top of the sidebar.
     */
    public Gtk.HeaderBar sidebar_headerbar {
        get {
            return sidebar_header;
        }
    }

    /**
     * Show or hide the seperator between the main part of the window and its headerbar.
     * *important*: don't forget to margin the headerbar widgets properly.
     */
    public bool has_main_separator {
        get {
            return main_separator.visible;
        }
        set {
            main_separator.visible = value;
        }
    }

    /**
     * Show or hide the seperator between the sidebar and its headerbar.
     * *important*: don't forget to margin the headerbar widgets properly.
     */
    public bool has_sidebar_separator {
        get {
            return sidebar_separator.visible;
        }
        set {
            sidebar_separator.visible = value;
        }
    }

    /** 
     * Creates a new SplitWindow.
     *
     * @param a Gtk.Application
     */
    public SplitWindow (Gtk.Application application) {
        Object (
            application: application
        );
    }

    construct {
        var header_provider = new Gtk.CssProvider ();
        try {
            // header_provider.load_from_path ("HeaderBar.css");
            header_provider.load_from_data ("""
                .sidebar-header {
                    background-color: shade (@bg_color, 0.92);
                    color: mix (@bg_color, @text_color, 0.77);
                }

                .sidebar-header:dir(ltr) {
                    border-top-right-radius: 0;
                }

                .sidebar-header:dir(rtl) {
                    border-top-left-radius: 0;
                }

                .main-view-header:dir(ltr) {
                    border-top-left-radius: 0;
                }

                .main-view-header:dir(rtl) {
                    border-top-right-radius: 0;
                }

                paned {
                    background-color: @bg_color;
                    border-top-left-radius: 4px;
                    border-top-right-radius: 4px;
                }
            """);
        } catch (Error e) {
            assert_not_reached ();
        }

        main_separator.no_show_all = true;
        main_separator.hide ();

        sidebar_separator.no_show_all = true;
        sidebar_separator.hide ();

        sidebar_header.decoration_layout = "close:";
        sidebar_header.has_subtitle = false;
        sidebar_header.show_close_button = true;

        unowned Gtk.StyleContext sidebar_header_context = sidebar_header.get_style_context ();
        sidebar_header_context.add_class ("sidebar-header");
        sidebar_header_context.add_class ("titlebar");
        sidebar_header_context.add_class ("default-decoration");
        sidebar_header_context.add_class (Gtk.STYLE_CLASS_FLAT);
        sidebar_header_context.add_provider (header_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        mainbox_header.has_subtitle = false;
        mainbox_header.decoration_layout = ":maximize";
        mainbox_header.show_close_button = true;

        unowned Gtk.StyleContext mainbox_header_context = mainbox_header.get_style_context ();
        mainbox_header_context.add_class ("mainbox-header");
        mainbox_header_context.add_class ("titlebar");
        mainbox_header_context.add_class ("default-decoration");
        mainbox_header_context.add_class (Gtk.STYLE_CLASS_FLAT);
        mainbox_header_context.add_provider (header_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        header_paned.pack1 (sidebar_header, false, false);
        header_paned.pack2 (mainbox_header, true, false);

        var sidebar_provider = new Gtk.CssProvider ();
        try {
            // sidebar_provider.load_from_path ("Sidebar.css");
            sidebar_provider.load_from_data ("""
                .sidebar {
                    border-bottom-left-radius: 4px;
                }

                .sidebar:dir(rtl) {
                    border-bottom-right-radius: 4px;
                }
            """);
        } catch (Error e) {
            assert_not_reached ();
        }

        sidebar.margin_bottom = 4;

        var sidebar_box_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar_box_wrapper.pack_start (sidebar_separator, false, false, 0);
        sidebar_box_wrapper.pack_start (sidebar, true, true, 0);

        unowned Gtk.StyleContext sidebar_wrapper_style_context = sidebar_box_wrapper.get_style_context ();
        sidebar_wrapper_style_context.add_provider (sidebar_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        sidebar_wrapper_style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);

        var main_provider = new Gtk.CssProvider ();
        try {
            // main_provider.load_from_path ("MainBox.css");
            main_provider.load_from_data ("""
                .main_box:dir(rtl) {
                    border-bottom-left-radius: 4px;
                }

                .main_box:dir(ltr) {
                    border-bottom-right-radius: 4px;
                }
            """);
        } catch (Error e) {
            assert_not_reached ();
        }

        main_box.get_style_context ().add_class ("main_box");
        main_box.margin_bottom = 4;

        var main_box_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box_wrapper.get_style_context ().add_provider (main_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        main_box_wrapper.get_style_context ().add_class ("main_box");
        main_box_wrapper.pack_start (main_separator, false, false, 0);
        main_box_wrapper.pack_start (main_box, true, true, 0);

        paned.pack1 (sidebar_box_wrapper, false, false);
        paned.pack2 (main_box_wrapper, true, false);

        set_titlebar (header_paned);
        add (paned);

        unowned Gtk.StyleContext header_paned_context = header_paned.get_style_context ();
        header_paned_context.remove_class ("titlebar");
        header_paned_context.add_provider (header_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        get_style_context ().add_class ("rounded");

        paned.bind_property ("position", header_paned, "position", GLib.SettingsBindFlags.BIDIRECTIONAL);
    }

    /**
     * Add a widget to the main part of the program
     *
     * @param a Gtk.Widget to add
     */
    public void main_add (Gtk.Widget widget) {
        main_box.add (widget);
    }

    /**
     * Add a widget to the sidebar
     *
     * @param a Gtk.Widget to add
     */
    public void sidebar_add (Gtk.Widget widget) {
        sidebar.add (widget);
    }
}
