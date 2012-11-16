/*
 * Copyright (c) 2011-2012 Lucas Baudin <xapantu@gmail.com>, Jaap Broekhuizen <jaapz.b@gmail.com>
 *
 * This is a free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

using Granite.Widgets;
using Granite.Services;

public class Granite.Demo : Granite.Application
{
    construct
    {
        application_id = "demo.granite.org";
        program_name = "Granite Demo";
        app_years = "2011";

        build_version = "1.0";
        app_icon = "text-editor";
        main_url = "https://launchpad.net/granite";
        bug_url = "https://bugs.launchpad.net/granite";
        help_url = "https://answers.launchpad.net/granite";
        translate_url = "https://translations.launchpad.net/granite";
        about_authors = {"Kekun",
                         null
                         };
        about_documenters = {"Valadoc",
                             null
                             };
        about_artists = {"Daniel P. Fore",
                         null
                         };

        about_authors = {"Maxwell Barvian <mbarvian@gmail.com>",
                         "Daniel Foré <bunny@go-docky.com>",
                         "Avi Romanoff <aviromanoff@gmail.com>",
                         null
                         };

        about_comments = "A demo of the Granite toolkit";
        about_translators = "Launchpad Translators";
        about_license_type = Gtk.License.GPL_3_0;
    }
    public Demo()
    {
    }

    public override void activate() {
        var win = new Gtk.Window();
        win.delete_event.connect( () => { Gtk.main_quit(); return false; });

        var notebook = new Gtk.Notebook();
        win.add(notebook);

        /* welcome */

        // These strings wtieill be automatically corrected by the widget
        var welcome = new Welcome("Granite's Welcome Screen", "This is Granite's Welcome widget.");
        notebook.append_page(welcome, new Gtk.Label("Welcome"));

        Gdk.Pixbuf? pixbuf = null;

        try {
            pixbuf = Gtk.IconTheme.get_default().load_icon ("document-new", 48, Gtk.IconLookupFlags.GENERIC_FALLBACK);
        }
        catch(Error e) {
            warning("Could not load icon, %s", e.message);
        }

        Gtk.Image? image = new Gtk.Image.from_icon_name("document-open", Gtk.IconSize.DIALOG);
        // Adding elements. Use the most convenient function to add an icon
        welcome.append_with_pixbuf(pixbuf, "Create", "Write a new document.");
        welcome.append_with_image(image, "Open", "select a file.");
        welcome.append("document-save", "Save", "With a much longer description.");
        welcome.append("help-info", "Discover", "Learn more about this application.");

        /* modebutton */
        var mode_button = new ModeButton();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;
        mode_button.append(new Gtk.Label("Hardware"));
        mode_button.append(new Gtk.Label("Input"));
        mode_button.append(new Gtk.Label("Output"));
        mode_button.append(new Gtk.Label("Quite long"));
        mode_button.append(new Gtk.Label("Very very long \n with a line break"));

        var vbox = new Gtk.Grid ();
        var toolbar = new Gtk.Toolbar();
        toolbar.get_style_context().add_class("primary-toolbar");
        var toolbutton = new Gtk.ToolItem();
        var tool_mode = new ModeButton();
        tool_mode.append_icon ("view-list-column-symbolic", Gtk.IconSize.MENU);
        tool_mode.append_icon ("view-list-details-symbolic", Gtk.IconSize.MENU);
        tool_mode.append_icon ("view-list-icons-symbolic", Gtk.IconSize.MENU);
        tool_mode.append_icon ("view-list-video-symbolic", Gtk.IconSize.MENU);
        toolbutton.add(tool_mode);
        toolbar.insert(toolbutton, -1);
        toolbar.insert(create_appmenu(new Gtk.Menu()), -1);
        vbox.attach (toolbar, 0, 0, 1, 1);toolbar = new Gtk.Toolbar();
        toolbar.get_style_context().add_class("inline-toolbar");
        toolbutton = new Gtk.ToolItem();
        tool_mode = new ModeButton();
        tool_mode.append(new Gtk.Label("1"));
        tool_mode.append(new Gtk.Label("2"));
        tool_mode.append(new Gtk.Label("3"));
        tool_mode.append(new Gtk.Label("4"));
        toolbutton.add(tool_mode);
        toolbar.insert(toolbutton, -1);
        vbox.attach(toolbar, 0, 1, 1, 1);

        vbox.attach(mode_button, 0, 2, 1, 1);

        mode_button = new ModeButton();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;
        mode_button.append(new Gtk.Label("Small"));
        mode_button.append(new Gtk.Label("a"));
        vbox.attach(mode_button, 0, 3, 1, 1);
        notebook.append_page(vbox, new Gtk.Label("ModeButton"));

        /* static notebook */
        var staticbox = new Gtk.Grid ();
        var staticnotebook = new StaticNotebook ();

        var pageone = new Gtk.Label("Page 1");

        staticnotebook.append_page (new Gtk.Label("Page 1"), pageone);
        staticnotebook.append_page (new Gtk.Label("Page 2"), new Gtk.Label("Page 2"));
        staticnotebook.append_page (new Gtk.Label("Page 3"), new Gtk.Label("Page 3"));

        staticnotebook.page_changed.connect(() => pageone.set_text("Page changed"));

        staticbox.attach (staticnotebook, 0, 0, 1, 1);

        notebook.append_page (staticbox, new Gtk.Label ("Static Notebook"));
        var button_about = new Gtk.Button.with_label("show_about");
        notebook.append_page (button_about, new Gtk.Label ("About Dialog"));
        button_about.clicked.connect(() => { show_about(win); } );

        var popover_buttons = new Gtk.Grid ();
        var hbox3 = new Gtk.Grid ();
        hbox3.halign = Gtk.Align.END;
        var popover1 = new Gtk.Button.with_label("PopOver 1");
        popover1.halign = Gtk.Align.END;
        hbox3.attach(popover1, 0, 0, 1, 1);
        popover1.clicked.connect( () => {
            var pop = new PopOver();
            var pop_hbox = (Gtk.Box)pop.get_content_area();
            pop_hbox.add(new HintedEntry("This is an HIntedEntry"));
            pop_hbox.add(new Gtk.Label("Another label"));
            var mode_pop = new ModeButton();
            mode_pop.append(new Gtk.Label("ele"));
            mode_pop.append(new Gtk.Label("ment"));
            mode_pop.append(new Gtk.Label("tary"));
            pop_hbox.add(mode_pop);
            pop_hbox.add(new DatePicker());
            pop.set_parent_pop (win);
            pop.move_to_widget(popover1);
            pop.show_all();
            pop.present();
            pop.run ();
            pop.destroy ();
        });
        popover_buttons.attach(new Gtk.Label("Let's try the PopOvers!"), 0, 0, 1, 1);
        popover_buttons.attach(hbox3, 0, 1, 1, 1);
        notebook.append_page (popover_buttons, new Gtk.Label ("PopOvers"));

        var calendar_button = new Gtk.Grid ();
        var date_button = new Granite.Widgets.DatePicker.with_format("%d-%m-%y");
        var time_button = new Granite.Widgets.TimePicker ();
        date_button.valign = date_button.halign = Gtk.Align.CENTER;
        time_button.valign = time_button.halign = Gtk.Align.CENTER;
        calendar_button.attach(date_button, 0, 0, 1, 1);
        calendar_button.attach(time_button, 1, 0, 1, 1);
        notebook.append_page (calendar_button, new Gtk.Label ("Calendar"));

        /* Contractor */
        var contractor_tab = new Gtk.Grid ();
        notebook.append_page (contractor_tab, new Gtk.Label ("Contractor"));
        
        var tb = new Gtk.Toolbar ();
        tb.set_icon_size (Gtk.IconSize.LARGE_TOOLBAR);
        var bt = new ToolButtonWithMenu (new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR), "Share", new ContractorMenu ("/home/user/file.txt", "text"));
        tb.insert (bt, 0);
        contractor_tab.attach (tb, 0, 0, 1, 1);
        
        var text_view = new Gtk.TextView ();
        GLib.HashTable<string, string>[] hash_ = Contractor.get_contract("/.zip", "application/zip");
        foreach(var hash in hash_)
        {
            text_view.buffer.text += hash.lookup("Name") + ": " + hash.lookup("Description") +  " icon: " + hash.lookup("Exec") + "\n";
        }
        contractor_tab.attach(text_view, 0, 1, 1, 1);
        contractor_tab.attach(new ContractorView("file:///home/user/file.txt", "text/plain"), 0, 2, 1, 1);


        /* DynamicNotebook */
        var dynamic_notebook = new DynamicNotebook ();
        
        notebook.append_page (dynamic_notebook, new Gtk.Label ("Dynamic Notebook"));
        var tab = new Tab ("Page 1", new ThemedIcon ("empty"), new Gtk.Label ("Page 1"));
        dynamic_notebook.insert_tab (tab, -1);
        tab.working = true;
        dynamic_notebook.insert_tab (new Tab ("Page 2", new ThemedIcon ("empty"), new Gtk.Label ("Page 2")), -1);
        dynamic_notebook.tab_added.connect ( (t) => {
        	t.page = new Gtk.Label ("new!");
        	t.label = "New Page";
    	});
    	dynamic_notebook.tab_moved.connect ((t, p) => { print ("Moved tab %s to %i\n", t.label, p);});
    	dynamic_notebook.tab_switched.connect ((old_t, new_t) => { print ("Switched from %s to %s\n", old_t.label, new_t.label);});
		dynamic_notebook.tab_removed.connect ((t) => { print ("Going to remove %s\n", t.label); return true;});

        /*Light window*/
        var light_window_button = new Gtk.Button.with_label ("Show LightWindow");
        
        light_window_button.clicked.connect ( () => { 
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
        });
        
        notebook.append_page (light_window_button, new Gtk.Label ("Light Window"));

        /* window properties */
        win.show_all();
        win.resize(800, 600);
    }

    public static int main(string[] args)
    {
        new Granite.Demo().run(args);

        Gtk.main();

        return 0;
    }
}

/*little helper class for constructing labels a bit faster*/

class LLabel : Gtk.Label{
    public LLabel (string label){
        this.set_halign (Gtk.Align.START);
        this.label = label;
    }
    public LLabel.indent (string label){
        this (label);
        this.margin_left = 10;
    }
    public LLabel.markup (string label){
        this (label);
        this.use_markup = true;
    }
    public LLabel.right (string label){
        this.set_halign (Gtk.Align.END);
        this.label = label;
    }
    public LLabel.right_with_markup (string label){
        this.set_halign (Gtk.Align.END);
        this.use_markup = true;
        this.label = label;
    }
}

