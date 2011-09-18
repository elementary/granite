/*
 * Copyright (c) 2011 Lucas Baudin <xapantu@gmail.com>, Jaap Broekhuizen <jaapz.b@gmail.com>
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
        var win = new Gtk.Window();
        win.delete_event.connect( () => { Gtk.main_quit(); return false; });
        
        var notebook = new Gtk.Notebook();
        win.add(notebook);
        
        /* welcome */
        var welcome = new Welcome("Granite", "Let's try...");
        notebook.append_page(welcome, new Gtk.Label("Welcome"));
        welcome.append("gtk-open", "Open", "Open a file");
        welcome.append("gtk-save", "Save", "Save with a much longer description");
        
        /* modebutton */
        var mode_button = new ModeButton();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;
        mode_button.append(new Gtk.Label("Hardware"));
        mode_button.append(new Gtk.Label("Input"));
        mode_button.append(new Gtk.Label("Output"));
        mode_button.append(new Gtk.Label("Quite long"));
        mode_button.append(new Gtk.Label("Veruy very long \n with a line break"));
        
        var vbox = new Gtk.VBox(false, 0);
        
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
        
        /* window properties */
        win.show_all();
        win.resize(800, 600);
    }

    public static int main(string[] args)
    {
        Gtk.init(ref args);
        new Granite.Demo();
        
        Gtk.main();
        
        return 0;
    }
}

