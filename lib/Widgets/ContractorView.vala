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
    
    public delegate void ContractCallback ();
    private Gee.HashMap<int, DelegateWrapper?> outsiders;
    private int[] blacklisted_pos;
    private ListStore list;
    
    private struct DelegateWrapper {ContractCallback method;}
    
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
    public ContractorView (string filename, string mime, int icon_size = 32, bool show_contract_name = true) {
        /* Setup the ListStore */
        list = new ListStore (2, typeof (Gdk.Pixbuf), typeof (string));
        outsiders = new Gee.HashMap<int, DelegateWrapper?> ();
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
            
            for (var i=0; i<this.contracts.length; i++){
                TreeIter it;
                list.append (out it);
                string text = this.contracts[i].lookup ("Description");
                if (show_contract_name)
                    text = "<b>"+this.contracts[i].lookup ("Name")+"</b>\n"+text;
                try{
                    list.set (it, 
                        0, IconTheme.get_default ().load_icon (this.contracts[i].lookup ("IconName"), 
                        icon_size, 0), 1, text);
                }
                catch (Error e) {
                    warning (e.message);
                }
            }
            this.selected = 0;
        }
    }
    
    /**
    * A method to add items to the tree
    * @param name the name
    * @param text the description
    * @param icon_name the name of the icon to show
    * @param icon_size the size of the icon in pixel
    * @param position the posion the item will be inserted at (first position  is 0)
    * @param method a general method containing all the methods that should be called when the item is activated
    *        (must return void and mustn't have any parameter)
    **/ 
    public void add_item (string name, string desc, string icon_name, int icon_size, int position, ContractCallback method) {
        TreeIter it;
        list.insert (out it, position);
        
        string text = "<b>" + name + "</b>\n" + desc;
        
        try{
            list.set (it, 0, IconTheme.get_default ().load_icon (icon_name, icon_size, 0), 1, text);
        } catch (Error e) {
            error (e.message);
        }
        
        DelegateWrapper wr = {method};
        outsiders[position] = wr;
        
        this.selected = 0;
    }
    
    public void name_blacklist (string[] names) {
        TreeIter it;
        TreeIter it2;
        Value value;
        bool check;
        int cur_pos = 0;
        list.get_iter_first (out it);
        list.get_iter_first (out it2);
        
        while (true) {
	        list.get_value (it, 1, out value);
	        check = list.iter_next (ref it2);
	        string text = value.get_string ();
	        
	        if (text[3:text.index_of ("</b>")] in names) {
	            list.remove (it);
	            blacklisted_pos += cur_pos;
            }
	        if (!check)
	            break;
	            
            it = it2;
	        cur_pos++;	            
        }
    }
        
    
    public void run_selected () {
        if (this.selected in outsiders.keys ) {
            outsiders[this.selected].method ();
        } else {
            try {
                int corr = 0;
                foreach (int i in outsiders.keys) { //adjust in case of items added
                    if (i > this.selected)
                        break;
                    corr++;
                }
                foreach (int i in blacklisted_pos) { //adjust in case of items removed
                    if (i > this.selected)
                        break;
                    corr--;
                }
                Process.spawn_command_line_async (
                    this.contracts[this.selected-corr].lookup ("Exec"));
            } catch (Error e) {
                error (e.message);
            }
        }
    }
}
