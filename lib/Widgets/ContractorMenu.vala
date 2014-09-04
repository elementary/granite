/*
 *  Copyright (C) 2012-2013 Andrea Basso <andrea@elementaryos.org>
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

/**
 * This class provides a simple menu for managing Contractor.
 * It uses a long-obsolete and unused revision of Contractor API and will not
 * work with stable releases of Contractor.
 */
[Deprecated (since = "0.2")]
public class Granite.Widgets.ContractorMenu : Gtk.Menu {
    /**
     * The Hashtable of available contracts
     */
    HashTable<string,string>[] contracts;
    /**
     * The Hashtable of executables
     */
    Gee.HashMap <string,string> execs;
    public delegate void ContractCallback ();
    private string filepath;
    private string filemime;
    
    /**
     * Passes when contract is clicked
     */
    public signal void contract_activated (string contract_name);
    
    /**
     * Makes new Contractor Meu
     *
     * @param filename the filename of the file
     * @param mime the mime-type of the file
     */
    public ContractorMenu (string filename, string mime) {
        filepath = filename;
        filemime = mime;
        load_items (filename, mime);
    }
    
    /**
     * Adds new item to Contractor Menu
     *
     * @param name name of menu item
     * @param icon_name the desired icon for menu item
     * @param position desired position of menu item
     * @param method method to be called when menu item is clicked
     * @param use_stock tells whether to use stock for menu item
     */
    public void add_item (string name, string icon_name, int position, ContractCallback method, bool use_stock = true) {
        var item = new Gtk.ImageMenuItem ();
        item.set_always_show_image (true);
        item.set_use_stock (use_stock);
        var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.MENU);
        item.set_label (name);
        item.set_image (image);
        item.activate.connect (()=> {
            contract_activated (name);
            method();
        });
        insert(item, position);
        item.show ();
    }
    
    /**
     * Deletes a group of menu items
     *
     * @param names of menu items to delete
     */
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
    
    /**
     * Updates Contractor menu items
     *
     * @param filename the filename of the file
     * @param mime the mime-type of the file
     */
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
