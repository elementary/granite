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
using Gdk;

public class Granite.GtkPatch.AboutDialog : Gtk.Dialog
{
	/**
	 * The people who contributed artwork to the program, as a null-terminated array of strings.
	 */
	public string[] artists {
		set { _artists = value; update(); }
		get { return _artists; }
	}
	string[] _artists = new string[0];
	
	/**
	 * The authors of the program, as a null-terminated array of strings.
	 */
	public string[] authors {
		set { _authors = value; update(); }
		get { return _authors; }
	}
	string[] _authors = new string[0];
	
	/**
	 * Comments about the program.
	 */
	public string comments {
		set { _comments = value; update(); }
		get { return _comments; }
	}
	string _comments = "";
	
	/**
	 * Copyright information for the program.
	 */
	public string copyright {
		set { _copyright = value; update(); }
		get { return _copyright; }
	}
	string _copyright = "";
	
	/**
	 * The people documenting the program, as a null-terminated array of strings.
	 */
	public string[] documenters {
		set {
			_documenters = value;
			if (documenters.length == 0 || documenters == null)
				documenters_label.hide();
			else {
				documenters_label.show();
				documenters_label.set_text(set_string_from_string_array("Documented by:\n", documenters));
			}
		}
		get { return _documenters; }
	}
	string[] _documenters = new string[0];
	
	/**
	 * The license of the program.
	 */
	public string license {
		set { _license = value; update(); }
		get { return _license; }
	}
	string _license = "";
	
	public License license_type {
		set { _license_type = value; update(); }
		get { return _license_type; }
	}
	License _license_type = License.UNKNOWN;
	
	/**
	 * A logo for the about box.
	 */
	public Pixbuf logo {
		set { _logo = value; update(); }
		get { return _logo; }
	}
	Pixbuf _logo = null;
	
	/**
	 * A named icon to use as the logo for the about box.
	 */
	public string logo_icon_name {
		set { _logo_icon_name = value; update(); }
		get { return _logo_icon_name; }
	}
	string _logo_icon_name = "";
	
	/**
	 * The name of the program.
	 */
	public string program_name {
		set { _program_name = value; update(); }
		get { return _program_name; }
	}
	string _program_name = "";
	
	/**
	 * Credits to the translators.
	 */
	public string translator_credits {
		set { _translator_credits = value; update(); }
		get { return _translator_credits; }
	}
	string _translator_credits = "";
	
	/**
	 * The version of the program.
	 */
	public string version {
		set { _version = value; update(); }
		get { return _version; }
	}
	string _version = "";
	
	/**
	 * The URL for the link to the website of the program.
	 */
	public string website {
		set { _website = value; update(); }
		get { return _website; }
	}
	string _website = "";
	
	/**
	 * The label for the link to the website of the program.
	 */
	public string website_label {
		set { _website_label = value; update(); }
		get { return _website_label; }
	}
	string _website_label = "";
	
	/**
	 * Whether to wrap the text in the license dialog.
	 */
	public bool wrap_license {
		set { _wrap_license = value; update(); }
		get { return _wrap_license; }
	}
	bool _wrap_license = true;
	
	// Signals
	public virtual signal bool activate_link (string uri) {
		return Gtk.show_uri(get_screen(), uri, Gtk.get_current_event_time());
	}
	
	// UI elements
	Image logo_image;
	Label name_label;
	Label copyright_label;
	Label comments_label;
	Label authors_label;
	Label artists_label;
	Label documenters_label;
	Label translators_label;
	Label license_label;
	Button close_button;
	
	public HBox action_hbox;
	public HBox action_homogeneous_hbox;
	
	string big_text_markup_start;
	string big_text_markup_end;
	
	/**
	 * Creates a new Granite.AboutDialog
	 */
	public AboutDialog()
	{
		set_default_response(ResponseType.CANCEL);
		
		// Set the markup used for big text (program name and version)
		big_text_markup_start = "<span weight='heavy' size='x-large'>";
		big_text_markup_end = "</span>";
		
		// Set the default containers
		Box content_area = (Box)get_content_area();
		Box action_area = (Box)get_action_area();
		action_area.realize();
		var content_hbox = new HBox(false, 12);
		var content_scrolled = new ScrolledWindow(null, new Adjustment(0, 0, 100, 1, 10, 0));
		var content_viewport = new Viewport(null, null);
		var content_vbox = new VBox(false, 0);
		action_hbox = new HBox(false, action_area.spacing);
		action_homogeneous_hbox = new HBox(true, action_area.spacing);
		content_hbox.margin = 12;
		action_hbox.margin = 6;
		content_viewport.shadow_type = ShadowType.NONE;
		content_scrolled.hscrollbar_policy = PolicyType.NEVER;
		content_area.pack_start(content_hbox);
		action_area.pack_start(action_hbox);
		
		logo_image = new Image();
		
		name_label = new Label("");
		name_label.xalign = 0;
		name_label.set_line_wrap(true);
		name_label.use_markup = true;
		
		close_button = new Button.from_stock(Stock.CLOSE);
		
		copyright_label = new Label("");
		copyright_label.set_sensitive(false);
		copyright_label.xalign = 0;
		copyright_label.set_line_wrap(true);
		
		comments_label = new Label("");
		comments_label.set_sensitive(false);
		comments_label.xalign = 0;
		comments_label.set_line_wrap(true);
		
		authors_label = new Label("");
		authors_label.set_sensitive(false);
		authors_label.xalign = 0;
		authors_label.set_line_wrap(true);
		
		artists_label = new Label("");
		artists_label.set_sensitive(false);
		artists_label.xalign = 0;
		artists_label.set_line_wrap(true);
		
		documenters_label = new Label("");
		documenters_label.set_sensitive(false);
		documenters_label.xalign = 0;
		documenters_label.set_line_wrap(true);
		
		translators_label = new Label("");
		translators_label.set_sensitive(false);
		translators_label.xalign = 0;
		translators_label.set_line_wrap(true);
		
		license_label = new Label("");
		license_label.set_sensitive(false);
		license_label.xalign = 0;
		license_label.set_line_wrap(true);
		
		content_hbox.pack_start(logo_image);
		content_hbox.pack_start(content_scrolled);
//~ 		content_hbox.pack_start(content_vscrollbar);
		content_scrolled.add(content_viewport);
		content_viewport.add(content_vbox);
		content_vbox.pack_start(name_label);
		content_vbox.pack_start(copyright_label);
		content_vbox.pack_start(comments_label);
		content_vbox.pack_start(authors_label);
		content_vbox.pack_start(artists_label);
		content_vbox.pack_start(documenters_label);
		content_vbox.pack_start(translators_label);
		content_vbox.pack_start(license_label);
		
		action_hbox.pack_start(action_homogeneous_hbox);
		action_homogeneous_hbox.pack_start(close_button);
		
		logo_image.show();
		name_label.show();
		copyright_label.show();
		comments_label.show();
		authors_label.show();
		artists_label.show();
//~ 		documenters_label.show();
		documenters_label.hide();
		translators_label.show();
		license_label.show();
		
		show_all();
		
		close_button.pressed.connect(() => { response(ResponseType.CANCEL); });
	}
		
	private void update ()
	{
		// Update the dialog's title
		set_title("About " + program_name);
		
		// Update the program name and version label
		if (program_name == null && version != null)
			name_label.set_markup(big_text_markup_start + "Version " + version + big_text_markup_end);
		else
			name_label.set_markup(big_text_markup_start + program_name + " " + version + big_text_markup_end);
		
		// Update the logo
		if (logo != null)
			logo_image.set_from_pixbuf(logo);
		else {
			try {
			logo_image.set_from_pixbuf(IconTheme.get_default ().load_icon ("application-default-icon", 128, 0));
		} catch (Error err) {
			stderr.printf ("Unable to load terminal icon: %s", err.message);
		}
		}
		
		// Update the copyright label
		copyright_label.set_text("Copyright: " + copyright + "\n");
		
		// Update the comments label
		comments_label.set_text(comments + "\n");
		
		// Update the authors label
		authors_label.set_text(set_string_from_string_array("Written by:\n", authors));
				
		// Update the artists label
		artists_label.set_text(set_string_from_string_array("Designed by:\n", artists));
		
		// Update the documenters label
//~ 		documenters_label.set_text(set_string_from_string_array("Documented by:\n", documenters));
		
		// Update the translators label
		translators_label.set_text("Translated by: " + translator_credits + "\n");
		
		// Update the license label
		license_label.set_markup(license);
	}
	
	private string set_string_from_string_array(string title, string[] list)
	{
		string text = title;
		foreach (string i in list)
			text += i + "\n";
		return text;
	}
}
