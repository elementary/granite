//  
//  Copyright (C) 2011 Adrien Plazas
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 
// 
//  Authors:
//      Adrien Plazas <kekun.plazas@laposte.net>
//  Artists:
//      Daniel Foré <daniel@elementaryos.org>
// 

using Gtk;

public class Granite.Widget.AboutDialog : Granite.GtkPatch.AboutDialog
{
	/**
	 * The URL for the link to the website of the program.
	 */
	public string help {
		set { _help = value; update(); }
		get { return _help; }
	}
	string _help = "";
	
	/**
	 * The URL for the link to the website of the program.
	 */
	public string translate {
		set { _translate = value; update(); }
		get { return _translate; }
	}
	string _translate = "";
	
	/**
	 * The URL for the link to the website of the program.
	 */
	public string bug {
		set { _bug = value; update(); }
		get { return _bug; }
	}
	string _bug = "";
	
	/**
	 * Creates a new Granite.AboutDialog
	 */
	public AboutDialog()
	{
		Button help;
		Button translate;
		Button report;
		help = new Button.with_label(" ? ");
		translate = new Button.with_label("Translate this app");
		report = new Button.with_label("Report a problem");
		action_hbox.pack_start(help);
		action_hbox.reorder_child(help, 0);
		action_homogeneous_hbox.pack_start(translate);
		action_homogeneous_hbox.pack_start(report);
		action_homogeneous_hbox.reorder_child(report, 0);
		action_homogeneous_hbox.reorder_child(translate, 0);
		help.show();
		translate.show();
		report.show();
	}
	
	public void update()
	{
		
	}
}
