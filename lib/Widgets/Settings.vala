
namespace Granite {
    [DBus (name = "io.elementary.pantheon.AccountsService")]
    private interface Pantheon.AccountsService : Object {
        public abstract string prefers_color_scheme { owned get; set; }
        public abstract string time_format { owned get; set; }
    }

    [DBus (name = "org.freedesktop.Accounts")]
    interface FDO.Accounts : Object {
        public abstract string find_user_by_name (string username) throws GLib.Error;
    }

    public class Settings : Object{
        private bool? _user_prefers_dark = null;
        public bool user_prefers_dark {
            get {
                if (_user_prefers_dark == null) {
                    setup_user_prefers_dark ();
                }
                return _user_prefers_dark;
            }
            private set {
                _user_prefers_dark = value;
            }
        }

        private string? _time_format = null;
        public string time_format {
            get {
                if (_time_format == null) {
                    setup_time_format ();
                }
                return _time_format;
            }
            private set {
                _time_format = value;
            }
        }

        private string? _user_path = null;
        private string user_path {
            get {
                if (_user_path == null) {
                    setup_user_path ();
                }
                return _user_path;
            }
            private set {
                _user_path = value;
            }
        }

        private static GLib.Once<Granite.Settings> instance;
        public static unowned Granite.Settings get_default () {
            return instance.once (() => {
                return new Granite.Settings ();
            });
        }

        private FDO.Accounts? accounts_service = null;
        private Pantheon.AccountsService? pantheon_act = null;

        private Settings () {}

        private void setup_user_path () {
            try {
                accounts_service = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                   "org.freedesktop.Accounts",
                   "/org/freedesktop/Accounts"
                );

                _user_path = accounts_service.find_user_by_name (GLib.Environment.get_user_name ());
            } catch (Error e) {
                critical (e.message);
            }
        }

        private void setup_user_prefers_dark () {
            try {
                pantheon_act = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                    "org.freedesktop.Accounts",
                    user_path,
                    GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES
                );

                user_prefers_dark = pantheon_act.prefers_color_scheme == "dark";

                ((GLib.DBusProxy) pantheon_act).g_properties_changed.connect ((changed_properties, invalidated_properties) => {
                    string prefers_color_scheme;
                    changed_properties.lookup ("PrefersColorScheme", "s", out prefers_color_scheme);
                    user_prefers_dark = prefers_color_scheme == "dark";
                });
            } catch (Error e) {
                critical (e.message);
            }
        }

        private void setup_time_format () {
            try {
                pantheon_act = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                    "org.freedesktop.Accounts",
                    user_path,
                    GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES
                );

                time_format = pantheon_act.time_format;

                ((GLib.DBusProxy) pantheon_act).g_properties_changed.connect ((changed_properties, invalidated_properties) => {
                    string _time_format;
                    changed_properties.lookup ("TimeFormat", "s", out _time_format);
                    time_format = _time_format;
                });
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
