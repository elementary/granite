/*
 * Copyright (c) 2012 Tom Beckmann
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

using Gtk;

public class Granite.Widgets.ContractorView : TreeView {
    
    /**
     * indicates if it was possible to connect to contractor
     **/
    public bool contractor_available;
    
    public delegate void DelegateType ();
    
    /**
     * A general item that can be inserted in the tree, even if it isn't a contract
     * @param name the name
     * @param text the description
     * @param icon_name the name of the icon to show
     * @param icon_size the size of the icon in pixel
     * @param position the posion the item will be inserted at (first position  is 0)
     * @param method a general method that contains all the methods which should be called when the item is activated
     *        (must return void and mustn't have any parameter)
     **/
    public struct Item {string name; string text; string icon_name; int icon_size; int position; DelegateType method;}
    private Gee.HashMap<int, Item?> outsiders;
    
    /**
     * the index of the currently selected contract
     **/
     
    public int selected {
        get {
            TreePath path;
            this.get_cursor (out path, null);
            return int.parse (path.to_string ());
        }
        set {
            this.set_cursor (new TreePath.from_string (value.to_string ()), null, false);
        }
    }
    
    /**
     * the original array of contracts returned by contractor
     **/
    HashTable<string,string>[] contracts;
    
    /**
     * Create the default ContractorView
     * @param filename the file
     * @param mime the mimetype of the file
     * @param icon_size the size of the icon in pixel
     * @param show_contract_name show the name of the contract in the list
     **/
    public ContractorView (string filename, string mime, int icon_size = 32, bool show_contract_name = true, Item[] items = {}, string[] name_blacklist = {}) {
    
        /* Setup the ListStore */
        var list = new ListStore (2, typeof (Gdk.Pixbuf), typeof (string));
        this.model = list;
        
        /* GUI */
        this.headers_visible = false;
        this.hexpand = true;
        
        /* Events */
        row_activated.connect(() => { run_selected(); });
        
        /* View */
        var cell1 = new CellRendererPixbuf ();
        cell1.set_padding (5, 8);
        this.insert_column_with_attributes (-1, "", cell1, "pixbuf", 0);
        
        var cell2 = new CellRendererText ();
        cell2.set_padding (2, 8);
        this.insert_column_with_attributes (-1, "", cell2, "markup", 1);
        this.contracts = Granite.Services.Contractor.get_contract (filename, mime);
        if (this.contracts == null || this.contracts.length == 0) {
            warning ("You should install contractor (or no contracts found for this mime).\n");
            contractor_available = false;
            TreeIter it;
            list.append (out it);
            bool contractor_installed = this.contracts == null;
            string message = contractor_installed ? _("Could not contact Contractor. You may need to install it") : _("No action found for this file");
            try {
                var icon = IconTheme.get_default ().load_icon (
                    contractor_installed ? Gtk.Stock.DIALOG_ERROR : Gtk.Stock.DIALOG_INFO, 
                    icon_size, 0);
                list.set (it, 
                    0, icon, 1, message);
            }
            catch (Error e) {
                warning("%s\n", e.message);
            }
            set_sensitive(false);
        }
        else {
            contractor_available = true;
            
            int correction = 0;
            outsiders = new Gee.HashMap<int, Item?> ();
            for (var i=0; i<(this.contracts.length+items.length); i++){
                bool is_item = false;
                Item? item = null;            
                foreach (Item cur_item in items) {
                    if (cur_item.position == i) {
                        is_item = true;
                        item = cur_item;
                        outsiders[i] = cur_item;
                        correction++;
                        break;
                    }
                }
                
                if ((!is_item) && this.contracts[i-correction].lookup ("Name") in name_blacklist) {
                    continue;
                }
                
                TreeIter it;
                list.append (out it);
                string text = is_item ? item.text : this.contracts[i-correction].lookup ("Description");
                
                if (show_contract_name)
                    text = "<b>"+ (is_item ? item.name : this.contracts[i-correction].lookup ("Name") )+"</b>\n"+text;
                try{
                    string icon_name = is_item ? item.icon_name : this.contracts[i-correction].lookup ("IconName");
                    list.set (it, 0, IconTheme.get_default ().load_icon (icon_name, icon_size, 0), 1, text);
                }
                catch (Error e) {
                    error (e.message);
                }
            }
            this.selected = 0;
        }
    }
    
    public void run_selected () {
        if (this.selected in outsiders.keys ) {
            outsiders[this.selected].method ();
        } else {
            try {
                Process.spawn_command_line_async (
                    this.contracts[this.selected].lookup ("Exec"));
            }
            catch (Error e) {
                error (e.message);
            }
        }
    }
}
