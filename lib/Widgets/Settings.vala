
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
        public string prefers_color_scheme { get; private set; }

        private Pantheon.AccountsService pantheon_act;

        private static GLib.Once<Granite.Settings> instance;
        public static unowned Granite.Settings get_default () {
            return instance.once (() => {
                return new Granite.Settings ();
            });
        }

        private Settings () {}

        construct {
            try {
                var accounts_service = GLib.Bus.get_proxy_sync<FDO.Accounts> (
                    GLib.BusType.SYSTEM,
                   "org.freedesktop.Accounts",
                   "/org/freedesktop/Accounts"
                );
                var user_path = accounts_service.find_user_by_name (GLib.Environment.get_user_name ());

                pantheon_act = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                    "org.freedesktop.Accounts",
                    user_path,
                    GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES
                );

                prefers_color_scheme = pantheon_act.prefers_color_scheme;

                ((GLib.DBusProxy) pantheon_act).g_properties_changed.connect ((changed_properties, invalidated_properties) => {
                    string preference;
                    changed_properties.lookup ("PrefersColorScheme", "s", out preference);

                    prefers_color_scheme = preference;
                });
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
