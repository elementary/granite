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

        // These strings will be automatically corrected by the widget
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

        var vbox = new Gtk.VBox(false, 0);
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
        vbox.pack_start(toolbar, false, false);toolbar = new Gtk.Toolbar();
        toolbar.get_style_context().add_class("inline-toolbar");
        toolbutton = new Gtk.ToolItem();
        tool_mode = new ModeButton();
        tool_mode.append(new Gtk.Label("1"));
        tool_mode.append(new Gtk.Label("2"));
        tool_mode.append(new Gtk.Label("3"));
        tool_mode.append(new Gtk.Label("4"));
        toolbutton.add(tool_mode);
        toolbar.insert(toolbutton, -1);
        vbox.pack_start(toolbar, false, false);

        vbox.pack_start(mode_button);

        mode_button = new ModeButton();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;
        mode_button.append(new Gtk.Label("Small"));
        mode_button.append(new Gtk.Label("a"));
        vbox.pack_start(mode_button);
        notebook.append_page(vbox, new Gtk.Label("ModeButton"));

        /* static notebook */
        var staticbox = new Gtk.VBox (false, 5);
        var staticnotebook = new StaticNotebook ();

        var pageone = new Gtk.Label("Page 1");

        staticnotebook.append_page (new Gtk.Label("Page 1"), pageone);
        staticnotebook.append_page (new Gtk.Label("Page 2"), new Gtk.Label("Page 2"));
        staticnotebook.append_page (new Gtk.Label("Page 3"), new Gtk.Label("Page 3"));

        staticnotebook.page_changed.connect(() => pageone.set_text("Page changed"));

        staticbox.add (staticnotebook);

        notebook.append_page (staticbox, new Gtk.Label ("Static Notebook"));
        var button_about = new Gtk.Button.with_label("show_about");
        notebook.append_page (button_about, new Gtk.Label ("About Dialog"));
        button_about.clicked.connect(() => { show_about(win); } );

        var popover_buttons = new Gtk.VBox(false, 0);
        var hbox3 = new Gtk.HBox(false, 0);
        hbox3.halign = Gtk.Align.END;
        var popover1 = new Gtk.Button.with_label("PopOver 1");
        popover1.halign = Gtk.Align.END;
        hbox3.add(popover1);
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
        popover_buttons.pack_start(new Gtk.Label("Let's try the PopOvers!"), false, false);
        popover_buttons.pack_start(hbox3, false, false);
        notebook.append_page (popover_buttons, new Gtk.Label ("PopOvers"));

        var calendar_button = new Gtk.HBox(false, 0);
        var date_button = new Granite.Widgets.DatePicker.with_format("%d-%m-%y");
        date_button.valign = date_button.halign = Gtk.Align.CENTER;
        calendar_button.add(date_button);
        notebook.append_page (calendar_button, new Gtk.Label ("Calendar"));

        /* Contractor */
        var contractor_tab = new Gtk.VBox (false, 0);
        notebook.append_page (contractor_tab, new Gtk.Label ("Contractor"));
        var text_view = new Gtk.TextView ();
        GLib.HashTable<string, string>[] hash_ = Contractor.get_contract("/.zip", "application/zip");
        foreach(var hash in hash_)
        {
            text_view.buffer.text += hash.lookup("Name") + ": " + hash.lookup("Description") +  " icon: " + hash.lookup("Exec") + "\n";
        }
        contractor_tab.add(text_view);
        contractor_tab.add(new ContractorView("file:///home/user/file.txt", "text/plain"));

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

