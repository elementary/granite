/***
    Copyright (C) 2011-2013 Adrien Plazas <kekun.plazas@laposte.net>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/

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
                artists_label.set_markup(set_string_from_string_array("<span size=\"small\">" + _("Designed by:") + "</span>\n", _artists));
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
                authors_label.set_markup(set_string_from_string_array("<span size=\"small\">" + _("Written by:") + "</span>\n", _authors));
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
                copyright_label.set_markup ("<span size=\"small\">" + _("© %s").printf (_copyright.replace("&", "&amp;")) + "</span>\n");
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
                documenters_label.set_markup(set_string_from_string_array("<span size=\"small\">"+_("Documented by:")+"</span>\n", documenters));
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
                translators_label.set_markup("<span size=\"small\">" + _("Translated by %s").printf(_translator_credits.replace("&", "&amp;")) + "</span>");
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
    private Image logo_image;
    private Label name_label;
    private Label copyright_label;
    private Label comments_label;
    private Label authors_label;
    private Label artists_label;
    private Label documenters_label;
    private Label translators_label;
    private Label license_label;
    private Label website_url_label;
    private Button close_button;

    private const string STYLESHEET = """
        * {
            -GtkDialog-action-area-border: 12px;
            -GtkDialog-button-spacing: 10px;
            -GtkDialog-content-area-border: 0;
        }
    """;

    /**
     * Creates a new Granite.AboutDialog
     */
    public AboutDialog()
    {
        title = "";
        has_resize_grip = false;
        resizable = false;
        deletable = false; // Hide the window's close button when possible
        set_default_response(ResponseType.CANCEL);


        Granite.Widgets.Utils.set_theming (this, STYLESHEET, null,
                                           Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Set the default containers
        Box content_area = (Box)get_content_area();
        Box action_area = (Box)get_action_area();

        var content_hbox = new Box(Orientation.HORIZONTAL, 12);
        var content_right_box = new Box(Orientation.VERTICAL, 0);
        var content_scrolled = new ScrolledWindow(null, new Adjustment(0, 0, 100, 1, 10, 0));
        var content_scrolled_vbox = new Box(Orientation.VERTICAL, 0);
        var title_vbox = new Box(Orientation.VERTICAL, 0);
        var logo_vbox = new Box(Orientation.VERTICAL, 0);

        content_scrolled.shadow_type = ShadowType.NONE;
        content_scrolled.hscrollbar_policy = PolicyType.NEVER;
        content_scrolled.vscrollbar_policy = PolicyType.AUTOMATIC;

        content_area.pack_start(content_hbox, true, true, 0);

        logo_image = new Image();
        logo_vbox.pack_start(logo_image, false, false, 12);
        logo_vbox.pack_end(new Box(Orientation.VERTICAL, 0), true, true, 0);

        // Adjust sizes
        content_hbox.height_request = 160;
        content_scrolled_vbox.width_request = 288;
        logo_image.set_size_request(128, 128);

        name_label = new Label("");
        name_label.halign = Gtk.Align.START;
        name_label.set_line_wrap(true);
        name_label.set_selectable(true);

        Granite.Widgets.Utils.apply_text_style_to_label (TextStyle.H2, name_label);

        copyright_label = new Label("");
        copyright_label.set_selectable(true);
        copyright_label.halign = Gtk.Align.START;
        copyright_label.set_line_wrap(true);

        comments_label = new Label("");
        comments_label.set_selectable(true);
        comments_label.halign = Gtk.Align.START;
        comments_label.set_line_wrap(true);

        authors_label = new Label("");
        authors_label.set_selectable(true);
        authors_label.halign = Gtk.Align.START;
        authors_label.set_line_wrap(true);

        artists_label = new Label("");
        artists_label.set_selectable(true);
        artists_label.halign = Gtk.Align.START;
        artists_label.set_line_wrap(true);

        documenters_label = new Label("");
        documenters_label.set_selectable(true);
        documenters_label.halign = Gtk.Align.START;
        documenters_label.set_line_wrap(true);

        translators_label = new Label("");
        translators_label.set_selectable(true);
        translators_label.halign = Gtk.Align.START;
        translators_label.set_line_wrap(true);

        license_label = new Widgets.WrapLabel("");
        license_label.set_selectable(true);

        website_url_label = new Label ("");
        website_url_label.set_selectable (true);
        website_url_label.halign = Gtk.Align.START;
        website_url_label.set_line_wrap (true);

        // left and right padding
        content_hbox.pack_start(new Box(Orientation.VERTICAL, 0), false, false, 0);
        content_hbox.pack_end(new Box(Orientation.VERTICAL, 0), false, false, 0);

        content_hbox.pack_start(logo_vbox);
        content_hbox.pack_start(content_right_box);

        content_scrolled.add_with_viewport(content_scrolled_vbox);

        title_vbox.pack_start(name_label, false, false, 12); //FIXME

        content_right_box.pack_start(title_vbox, false, false, 0);
        content_right_box.pack_start(content_scrolled, true, true, 0);
        // Extra padding between the scrolled window and the action area
        content_right_box.pack_end(new Box(Orientation.VERTICAL, 0), false, false, 6);

        content_scrolled_vbox.pack_start(comments_label);
        content_scrolled_vbox.pack_start(website_url_label);

        content_scrolled_vbox.pack_start(copyright_label);
        content_scrolled_vbox.pack_start(license_label);

        content_scrolled_vbox.pack_start(authors_label);
        content_scrolled_vbox.pack_start(artists_label);
        content_scrolled_vbox.pack_start(documenters_label);
        content_scrolled_vbox.pack_start(translators_label);

        close_button = new Button.with_label(_("Close"));
        close_button.clicked.connect(() => { response(ResponseType.CANCEL); });
        action_area.pack_end (close_button, false, false, 0);

        close_button.grab_focus();
    }

    private string set_string_from_string_array(string title, string[] peoples,bool tooltip=false)
    {
        if (tooltip)
            return string.joinv ("\n",peoples);

        string text  = "";
        string name  = "";
        string email = "" ;
        string _person_data;
        bool email_started= false;
        text += title + "<span size=\"small\">";
        for (int i= 0;i<peoples.length;i++){
            if (peoples[i] == null)
                break;
            _person_data = peoples[i];

            for (int j=0;j< _person_data.length;j++){

                if ( _person_data.get (j) == '<')
                    email_started = true;

                if (!email_started)
                    name += _person_data[j].to_string ();

                else
                    if (_person_data.get (j) != '>' && _person_data.get (j) != '<')
                        email +=_person_data[j].to_string ();

            }
            if (email == "")
                text += "<u>%s</u>\n".printf (name.strip ());
            else
                text += "<a href=\"mailto:%s\" title=\"%s\">%s</a>\n".printf (email,email,name.strip ());
            email = ""; name =""; email_started=false;
        }
        text += "</span>";
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
            set_generic_license("http://www.gnu.org/licenses/old-licenses/gpl-2.0.html", "gpl-2.0");
            break;
        case License.GPL_3_0:
            set_generic_license("http://www.gnu.org/licenses/gpl.html", "gpl");
            break;
        case License.LGPL_2_1:
            set_generic_license("http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html", "lgpl-2.1");
            break;
        case License.LGPL_3_0:
            set_generic_license("http://www.gnu.org/licenses/lgpl.html", "lgpl");
            break;
        case License.BSD:
            set_generic_license("http://opensource.org/licenses/bsd-license.php", "bsd");
            break;
        case License.MIT_X11:
            set_generic_license("http://opensource.org/licenses/mit-license.php", "mit");
            break;
        case License.ARTISTIC:
            set_generic_license("http://opensource.org/licenses/artistic-license-2.0.php", "artistic");
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

    private void set_generic_license(string url, string license_type)
    {
        license_label.set_markup("<span size=\"small\">" + _("This program is published under the terms of the ") + license_type + _(" license, it comes with ABSOLUTELY NO WARRANTY; for details, visit ") + "<a href=\"" + url + "\">" + url + "</a></span>\n");
        license_label.show();
    }

    private void set_name_and_version()
    {
        if (program_name != null && program_name != "")
        {
            name_label.set_text(program_name);
            if (version != null && version != "")
                name_label.set_text(name_label.get_text() + " " + version);
            name_label.show();
        }
        else
            name_label.hide();
    }

    private void update_website () {
        if (website != null && website != "") {

            if (website_label != null && website_label != "")
                website_url_label.set_markup ("<a href=\"%s\" title=\"%s\">%s</a>\n".printf
                                              (website, website, website_label.replace("&", "&amp;")));
            else
                website_url_label.set_markup ("<a href=\"%s\" title=\"%s\">%s</a>\n".printf
                                              (website, website, website));

            website_url_label.show ();
        }
        else
            website_url_label.hide ();
    }
}

