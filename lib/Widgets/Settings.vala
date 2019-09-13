
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
        private string? _prefers_color_scheme = null;
        public string prefers_color_scheme {
            get {
                if (_prefers_color_scheme == null) {
                    setup_prefers_color_scheme ();
                }
                return _prefers_color_scheme;
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
        }

        private string? _user_path = null;
        private string user_path {
            get {
                if (_user_path == null) {
                    setup_user_path ();
                }
                return _user_path;
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

        private void setup_prefers_color_scheme () {
            try {
                pantheon_act = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                    "org.freedesktop.Accounts",
                    user_path,
                    GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES
                );

                _prefers_color_scheme = pantheon_act.prefers_color_scheme;
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

                _time_format = pantheon_act.time_format;
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
