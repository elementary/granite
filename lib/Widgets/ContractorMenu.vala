/*
 * Copyright (c) 2012 Andrea Basso
 *
 * This is a free software; you can redistribute it and/or
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
 *
 */


public class Granite.Widgets.ContractorMenu : Gtk.Menu {
    HashTable<string,string>[] contracts;
    Gee.HashMap <string,string> execs;
    public delegate void ContractCallback ();
    private string filepath;
    private string filemime;
    
    public ContractorMenu (string filename, string mime) {
        filepath = filename;
        filemime = mime;
        load_items (filename, mime);
    }
    
    public void add_item (string name, string icon_name, int position, ContractCallback method) {
        var item = new Gtk.ImageMenuItem ();
        item.set_always_show_image (true);
        var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.MENU);
        item.set_label (name);
        item.set_image (image);
        item.activate.connect (()=>{method();});
        insert(item, position);
        item.show ();
    }
    
    public void name_blacklist (string[] names) {
        this.foreach ((item)=> {
            if (((Gtk.MenuItem)item).get_label () in names)
                remove (item);
        });
    }
    
    private void load_items (string filename, string mime) {
        contracts = Granite.Services.Contractor.get_contract (filename, mime);
        execs = new Gee.HashMap<string,string> ();
        
        for (int i=0;i<contracts.length;i++) {
            execs[contracts[i].lookup ("Name")] = contracts[i].lookup ("Exec");
            
            var item = new Gtk.ImageMenuItem ();
            item.set_always_show_image (true);
            var image = new Gtk.Image.from_icon_name (contracts[i].lookup ("IconName"), Gtk.IconSize.MENU);
            item.set_label (contracts[i].lookup ("Name"));
            item.set_image (image);
            item.activate.connect ( ()=> {
                try {
 	                Process.spawn_command_line_async (execs.get(item.get_label ()));
 	            } catch (Error e) {
 	                error (e.message);
 	            }
            });
            append (item);
            item.show_all ();
        }
    }
    
    public void update (string? filename, string? mime) {
        this.foreach ((w) => {remove (w);});
        
        string fn = "";
        string mm = "";
        
        if (filename != null) {
            fn = filename;
            filepath = filename;
        } else {
            fn = filepath;
        }
        
        if (mime != null) {
            mm = mime;
            filemime = mime;
        } else {
            mm = filemime;
        }
    
        load_items (fn, mm);
    }
}
