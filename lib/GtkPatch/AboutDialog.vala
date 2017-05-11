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

public class Granite.GtkPatch.AboutDialog : Gtk.Dialog {
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
                if (copyright_label.get_style_context ().get_direction () == Gtk.TextDirection.RTL) {
                    copyright_label.set_markup ("<span size=\"small\">" + "%s ©".printf (GLib.Markup.escape_text (_copyright)) + "</span>\n");
                } else {
                    copyright_label.set_markup ("<span size=\"small\">" + "© %s".printf (GLib.Markup.escape_text (_copyright)) + "</span>\n");
                }
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

    public Gtk.License license_type {
        set { _license_type = value; update_license(); }
        get { return _license_type; }
    }
    Gtk.License _license_type = Gtk.License.UNKNOWN;

    /**
     * A logo for the about box.
     */
    public Gdk.Pixbuf logo {
        set { _logo = value; update_logo_image(); }
        get { return _logo; }
    }
    Gdk.Pixbuf _logo = null;

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
            if (_translator_credits == null || _translator_credits == "" || _translator_credits == "translator-credits") {
                translators_label.hide();
                translators_label.set_text("");
            }
            else {
                translators_label.set_markup("<span size=\"small\">" + _("Translated by %s").printf(GLib.Markup.escape_text (_translator_credits)) + "</span>");
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
    private Gtk.Image logo_image;
    private Gtk.Label name_label;
    private Gtk.Label copyright_label;
    private Gtk.Label comments_label;
    private Gtk.Label authors_label;
    private Gtk.Label artists_label;
    private Gtk.Label documenters_label;
    private Gtk.Label translators_label;
    private Gtk.Label license_label;
    private Gtk.Label website_url_label;
    private Gtk.Button close_button;

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
    public AboutDialog () {
        title = "";
        has_resize_grip = false;
        resizable = false;
        deletable = false; // Hide the window's close button when possible
        set_default_response (Gtk.ResponseType.CANCEL);

        Granite.Widgets.Utils.set_theming (this, STYLESHEET, null,
                                           Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        logo_image = new Gtk.Image ();

        name_label = new Gtk.Label ("");
        name_label.halign = Gtk.Align.START;
        name_label.set_line_wrap (true);
        name_label.set_selectable (true);

        Granite.Widgets.Utils.apply_text_style_to_label (TextStyle.H2, name_label);

        copyright_label = new Gtk.Label ("");
        copyright_label.set_selectable (true);
        copyright_label.halign = Gtk.Align.START;
        copyright_label.set_line_wrap (true);

        comments_label = new Gtk.Label ("");
        comments_label.set_selectable (true);
        comments_label.halign = Gtk.Align.START;
        comments_label.set_line_wrap(true);

        authors_label = new Gtk.Label ("");
        authors_label.set_selectable (true);
        authors_label.halign = Gtk.Align.START;
        authors_label.set_line_wrap (true);

        artists_label = new Gtk.Label ("");
        artists_label.set_selectable (true);
        artists_label.halign = Gtk.Align.START;
        artists_label.set_line_wrap(true);

        documenters_label = new Gtk.Label ("");
        documenters_label.set_selectable(true);
        documenters_label.halign = Gtk.Align.START;
        documenters_label.set_line_wrap(true);

        translators_label = new Gtk.Label ("");
        translators_label.set_selectable(true);
        translators_label.halign = Gtk.Align.START;
        translators_label.set_line_wrap(true);

        license_label = new Widgets.WrapLabel("");
        license_label.set_selectable(true);

        website_url_label = new Gtk.Label ("");
        website_url_label.set_selectable (true);
        website_url_label.halign = Gtk.Align.START;
        website_url_label.set_line_wrap (true);

        var content_scrolled_vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        content_scrolled_vbox.pack_start(comments_label);
        content_scrolled_vbox.pack_start(website_url_label);
        content_scrolled_vbox.pack_start(copyright_label);
        content_scrolled_vbox.pack_start(license_label);
        content_scrolled_vbox.pack_start(authors_label);
        content_scrolled_vbox.pack_start(artists_label);
        content_scrolled_vbox.pack_start(documenters_label);
        content_scrolled_vbox.pack_start(translators_label);

        var content_scrolled = new Gtk.ScrolledWindow (null, null);
        content_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        content_scrolled.vexpand = true;
        content_scrolled.width_request = 344;
        content_scrolled.add (content_scrolled_vbox);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.height_request = 136;
        grid.margin = 12;
        grid.attach (logo_image, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0, 1, 1);
        grid.attach (content_scrolled, 1, 1, 1, 1);

        var content_area = (Gtk.Box) get_content_area ();
        content_area.add (grid);

        close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            response (Gtk.ResponseType.CANCEL);
        });

        close_button.grab_focus ();

        var action_area = (Gtk.Box) get_action_area ();
        action_area.pack_end (close_button, false, false, 0);
    }

    private string set_string_from_string_array (string title, string[] peoples,bool tooltip=false) {
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

    private void update_logo_image () {
        logo_image.pixel_size = 128;

        if (logo_icon_name != null && logo_icon_name != "") {
            logo_image.icon_name = logo_icon_name;
        } else if (logo != null) {
            logo_image.pixbuf = logo;
        } else {
            logo_image.icon_name = "application-default-icon";
        }
    }

    private void update_license () {
        switch (license_type) {
        case Gtk.License.GPL_2_0:
            set_generic_license("http://www.gnu.org/licenses/old-licenses/gpl-2.0.html", "GPL 2.0");
            break;
        case Gtk.License.GPL_3_0:
            set_generic_license("http://www.gnu.org/licenses/gpl.html", "GPL");
            break;
        case Gtk.License.LGPL_2_1:
            set_generic_license("http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html", "LGPL 2.1");
            break;
        case Gtk.License.LGPL_3_0:
            set_generic_license("http://www.gnu.org/licenses/lgpl.html", "LGPL");
            break;
        case Gtk.License.BSD:
            set_generic_license("http://opensource.org/licenses/bsd-license.php", "BSD");
            break;
        case Gtk.License.MIT_X11:
            set_generic_license("http://opensource.org/licenses/mit-license.php", "MIT");
            break;
        case Gtk.License.ARTISTIC:
            set_generic_license("http://opensource.org/licenses/artistic-license-2.0.php", "Artistic");
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

    private void set_generic_license (string url, string license_type) {
        license_label.set_markup("<span size=\"small\">" + _("This program is published under the terms of the %s license, it comes with ABSOLUTELY NO WARRANTY; for details, visit %s").printf (license_type, "<a href=\"" + url + "\">" + url + "</a></span>\n"));
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
                                              (website, website, GLib.Markup.escape_text (website_label)));
            else
                website_url_label.set_markup ("<a href=\"%s\" title=\"%s\">%s</a>\n".printf
                                              (website, website, website));

            website_url_label.show ();
        }
        else
            website_url_label.hide ();
    }
}
