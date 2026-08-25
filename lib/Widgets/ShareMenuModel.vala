public class Granite.ShareMenuModel : Object {
    private Gtk.PopoverMenu _popovermenu;
    public Gtk.PopoverMenu popovermenu {
        get {
            return _popovermenu;
        }
        set {
            _popovermenu = value;

            var email_button = new ImageModelButton (_("Send by Mail"), ACTION_PREFIX + EMAIL_ACTION, "io.elementary.mail");
            var bluetooth_button = new ImageModelButton (_("Send by Bluetooth"), ACTION_PREFIX + WALLPAPER_ACTION, "io.elementary.bluetooth");
            var wallpaper_button = new ImageModelButton (_("Use as Wallpaper"), ACTION_PREFIX + WALLPAPER_ACTION, "preferences-desktop-wallpaper");
            var open_button = new ImageModelButton (_("Open With…"), ACTION_PREFIX + WALLPAPER_ACTION, "document-open");

            var app_box = new Granite.Box (HORIZONTAL, NONE) {
                homogeneous = true
            };
            app_box.add_css_class ("inline-buttons");
            app_box.append (email_button);
            app_box.append (bluetooth_button);
            app_box.append (wallpaper_button);
            app_box.append (open_button);

            _popovermenu.insert_action_group (ACTION_GROUP, action_group);
            _popovermenu.add_child (app_box, "apps");
        }
    }

    private const string ACTION_GROUP = "share";
    private const string ACTION_PREFIX = ACTION_GROUP + ".";
    private const string EMAIL_ACTION = "email";
    private const string WALLPAPER_ACTION = "wallpaper";

    private SimpleActionGroup action_group;

    //TODO: decide arg type
    public GLib.MenuItem get_section_for_files () {
        var email_action = new SimpleAction (EMAIL_ACTION, null);
        email_action.activate.connect (action_email);

        var wallpaper_action = new SimpleAction (WALLPAPER_ACTION, null);

        action_group = new SimpleActionGroup ();
        action_group.add_action (email_action);

        var app_section = new MenuItem (null, null);
        app_section.set_attribute_value ("custom", "apps");

        var system_section = new Menu ();
        system_section.append (_("Save to Files"), ACTION_PREFIX + WALLPAPER_ACTION);
        system_section.append (_("Print"), ACTION_PREFIX + WALLPAPER_ACTION);
        system_section.append (_("Move to Trash"), ACTION_PREFIX + WALLPAPER_ACTION);

        var menu = new Menu ();
        menu.append_item (app_section);
        menu.append_section (null, system_section);

        return new MenuItem.section (null, menu);
    }

    private void action_email () {
        var active_window = (Gtk.Window) _popovermenu.get_root ();
        Xdp.Parent? parent = active_window != null ? Xdp.parent_new_gtk (active_window) : null;

        critical ("emailing");

        string[] attachments = {"file:///dogwater"};

        var portal = new Xdp.Portal ();
        portal.compose_email.begin (parent, null, null, null, null, null, attachments, NONE, null, (obj, res) => {
            try {
                portal.compose_email.end (res);
            } catch (Error e) {
                // FIXME: throw error dialog
                critical (e.message);
            }
        });

    }

    private class ImageModelButton : Gtk.Button {
        public string action_name { get; construct; }
        public string icon_name { get; construct; }
        public string label { get; construct; }

        public ImageModelButton (string label, string action_name, string icon_name) {
            Object (
                label: label,
                action_name: action_name,
                icon_name: icon_name
            );
        }

        construct {
            accessible_role = MENU_ITEM;

            var image = new Gtk.Image.from_icon_name (icon_name) {
                icon_size = LARGE
            };

            var label_widget = new Gtk.Label (label) {
                ellipsize = MIDDLE,
                justify = CENTER,
                lines = 2,
                max_width_chars = 8
            };
            label_widget.add_css_class (Granite.CssClass.SMALL);

            var box = new Granite.Box (VERTICAL, HALF);
            box.append (image);
            box.append (label_widget);

            child = box;
            action_name = action_name;
            has_frame = false;
            add_css_class ("model");
        }
    }
}
