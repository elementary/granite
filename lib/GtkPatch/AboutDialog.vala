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

/* TODO
 * GtkPatch : update_website
 * Demo : 
 */
using Gtk;
using Gdk;

public class Granite.GtkPatch.AboutDialog : Gtk.Dialog
{
	/**
	 * The people who contributed artwork to the program, as a null-terminated array of strings.
	 */
	public string[] artists {
		set {
			_artists = value;
			if (_artists == null || _artists.length == 0) {
				artists_label.hide();
				artists_label.set_text("");
			}
			else {
				artists_label.set_text(set_string_from_string_array("Designed by" + ":\n", _artists));
				artists_label.show();
			}
		}
		get { return _artists; }
	}
	string[] _artists = new string[0];
	
	/**
	 * The authors of the program, as a null-terminated array of strings.
	 */
	public string[] authors {
		set {
			_authors = value;
			if (_authors == null || _authors.length == 0) {
				authors_label.hide();
				authors_label.set_text("");
			}
			else {
				authors_label.set_text(set_string_from_string_array("Written by" + ":\n", _authors));
				authors_label.show();
			}
		}
		get { return _authors; }
	}
	string[] _authors = new string[0];
	
	/**
	 * Comments about the program.
	 */
	public string comments {
		set {
			_comments = value;
			if (_comments == null || _comments == "") {
				comments_label.hide();
				comments_label.set_text("");
			}
			else {
				comments_label.set_text(_comments + "\n");
				comments_label.show();
			}
		}
		get { return _comments; }
	}
	string _comments = "";
	
	/**
	 * Copyright information for the program.
	 */
	public string copyright {
		set {
			_copyright = value;
			if (_copyright == null || _copyright == "") {
				copyright_label.hide();
				copyright_label.set_text("");
			}
			else {
				copyright_label.set_text("Copyright © " + _copyright + "\n");
				copyright_label.show();
			}
		}
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
		set { _license = value; update_license(); }
		get { return _license; }
	}
	string _license = "";
	
	public License license_type {
		set { _license_type = value; update_license(); }
		get { return _license_type; }
	}
	License _license_type = License.UNKNOWN;
	
	/**
	 * A logo for the about box.
	 */
	public Pixbuf logo {
		set { _logo = value; update_logo_image(); }
		get { return _logo; }
	}
	Pixbuf _logo = null;
	
	/**
	 * A named icon to use as the logo for the about box.
	 */
	public string logo_icon_name {
		set { _logo_icon_name = value; update_logo_image(); }
		get { return _logo_icon_name; }
	}
	string _logo_icon_name = "";
	
	/**
	 * The name of the program.
	 */
	public string program_name {
		set { _program_name = value; set_name_and_version(); }
		get { return _program_name; }
	}
	string _program_name = "";
	
	/**
	 * Credits to the translators.
	 */
	public string translator_credits {
		set {
			_translator_credits = value;
			if (_translator_credits == null || _translator_credits == "") {
				translators_label.hide();
				translators_label.set_text("");
			}
			else {
				translators_label.set_text("Translated by: " + _translator_credits + "\n");
				translators_label.show();
			}
		}
		get { return _translator_credits; }
	}
	string _translator_credits = "";
	
	/**
	 * The version of the program.
	 */
	public string version {
		set { _version = value; set_name_and_version(); }
		get { return _version; }
	}
	string _version = "";
	
	/**
	 * The URL for the link to the website of the program.
	 */
	public string website {
		set { _website = value; update_website(); }
		get { return _website; }
	}
	string _website = "";
	
	/**
	 * The label for the link to the website of the program.
	 */
	public string website_label {
		set { _website_label = value; update_website(); }
		get { return _website_label; }
	}
	string _website_label = "";
	
	/**
	 * Whether to wrap the text in the license dialog.
	 */
	public bool wrap_license {
		set {
			_wrap_license = value;
			license_label.set_line_wrap(_wrap_license);
		}
		get { return _wrap_license; }
	}
	bool _wrap_license = true;
	
	// Signals
	public virtual signal bool activate_link (string uri) {
		// Improve error management FIXME
		bool result = false;
		if (uri != null)
		{
			try {
				result = Gtk.show_uri(get_screen(), uri, Gtk.get_current_event_time());
			} catch (Error err) {
				stderr.printf ("Unable to open the URI: %s", err.message);
			}
		}
		return result;
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
	Label website_url_label;
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
		set_title("");
		has_resize_grip = false;
		resizable = false;
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
		
		content_viewport.shadow_type = ShadowType.NONE;
		content_scrolled.hscrollbar_policy = PolicyType.NEVER;
		content_area.pack_start(content_hbox);
		action_area.pack_start(action_hbox);
		
		logo_image = new Image();
		
		// Adjust sizes
		content_hbox.margin = 12;
		action_hbox.margin = 6;
		content_hbox.height_request = 160;
		content_vbox.width_request = 288;
		logo_image.set_size_request(128, 128);
		
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
		license_label.set_line_wrap(wrap_license);
		
		website_url_label = new Label("");
		website_url_label.set_sensitive(false);
		website_url_label.xalign = 0;
		website_url_label.set_line_wrap(true);
		
		content_hbox.pack_start(logo_image);
		content_hbox.pack_start(content_scrolled);
		content_scrolled.add(content_viewport);
		content_viewport.add(content_vbox);
		
		content_vbox.pack_start(name_label);
		content_vbox.pack_start(comments_label);
		content_vbox.pack_start(website_url_label);
		
		content_vbox.pack_start(copyright_label);
		content_vbox.pack_start(license_label);
		
		content_vbox.pack_start(authors_label);
		content_vbox.pack_start(artists_label);
		content_vbox.pack_start(documenters_label);
		content_vbox.pack_start(translators_label);
		
		action_hbox.pack_start(action_homogeneous_hbox);
		action_homogeneous_hbox.pack_start(close_button);
		
		action_area.show_all();
		content_area.show();
		content_hbox.show();
		content_scrolled.show();
		content_viewport.show();
		content_vbox.show();
		logo_image.show();
		
		close_button.pressed.connect(() => { response(ResponseType.CANCEL); });
	}
	
	private string set_string_from_string_array(string title, string[] list)
	{
		string text = title;
		foreach (string i in list)
			text += i + "\n";
		return text;
	}
	
	private void update_logo_image()
	{
		try {
			logo_image.set_from_pixbuf(IconTheme.get_default ().load_icon ("application-default-icon", 128, 0));
		} catch (Error err) {
			stderr.printf ("Unable to load terminal icon: %s", err.message);
		}
		if (logo_icon_name != null && logo_icon_name != "") {
			try {
			logo_image.set_from_pixbuf(IconTheme.get_default ().load_icon (logo_icon_name, 128, 0));
			} catch (Error err) {
				stderr.printf ("Unable to load terminal icon: %s", err.message);
			}
		}
		else if (logo != null)
			logo_image.set_from_pixbuf(logo);
	}
	
	private void update_license()
	{
		switch (license_type) {
		case License.GPL_2_0:
			set_generic_license("http://www.gnu.org/licenses/old-licenses/gpl-2.0.html");
			break;
		case License.GPL_3_0:
			set_generic_license("http://www.gnu.org/licenses/gpl.html");
			break;
		case License.LGPL_2_1:
			set_generic_license("http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html");
			break;
		case License.LGPL_3_0:
			set_generic_license("http://www.gnu.org/licenses/lgpl.html");
			break;
		case License.BSD:
			set_generic_license("http://opensource.org/licenses/bsd-license.php");
			break;
		case License.MIT_X11:
			set_generic_license("http://opensource.org/licenses/mit-license.php");
			break;
		case License.ARTISTIC:
			set_generic_license("http://opensource.org/licenses/artistic-license-2.0.php");
			break;
		default:
			if (license != null && license != "") {
				license_label.set_markup(license + "\n");
				license_label.show();
			}
			else
				license_label.hide();
			break;
		}
	}
	
	private void set_generic_license(string url)
	{
		license_label.set_markup("This program comes with ABSOLUTELY NO WARRANTY; for details, visit <a href=\"" + url + "\">" + url + "</a>\n");
		license_label.show();
	}
	
	private void set_name_and_version()
	{
		if (program_name != null && program_name != "")
		{
			name_label.set_text(program_name);
			if (version != null && version != "")
				name_label.set_text(name_label.get_text() + " " + version);
			name_label.set_markup(big_text_markup_start + name_label.get_text() + big_text_markup_end + "\n");
			name_label.show();
		}
		else
			name_label.hide();
	}
	
	private void update_website()
	{
		if (website != null && website != "") {
			if (website != null && website != "") {
				website_url_label.set_markup("<a href=\"" + website + "\">" + website_label + "</a>\n");
			}
			else
				website_url_label.set_markup("<a href=\"" + website + "\">" + website + "</a>\n");
			website_url_label.show();
		}
		else
			website_url_label.hide();
	}
}
