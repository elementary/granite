/*
 * Copyright 2011-2013 Robert Dyer
 * Copyright 2011-2013 Rico Tzschichholz <ricotz@ubuntu.com>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite.Services {

    /**
     * This interface is used by objects that need to be serialized in a Settings.
     * The object must have a string representation and provide these methods to
     * translate between the string and object representations.
     */
    public interface SettingsSerializable : GLib.Object {
        /**
         * Serializes the object into a string representation.
         *
         * @return the string representation of the object
         */
        public abstract string settings_serialize ();

        /**
         * Un-serializes the object from a string representation.
         *
         * @param s the string representation of the object
         */
        public abstract void settings_deserialize (string s);
    }

    /**
     * Class for interacting with an internal {@link GLib.Settings} using native Vala properties.
     * Clients of this class should not connect to the {@link GLib.Object.notify} signal.
     * Instead, they should connect to the {@link Granite.Services.Settings.changed} signal.
     *
     * For example, if a developer wanted to interact with desktop.Wallpaper's (http:/www.launchpad.net/pantheon-wallpaper) schema,
     * this is what his/her subclass might look like:
     *
     * {{{
     *    public class WallpaperSettings : Granite.Services.Settings {
     *
     *        public PictureMode picture_mode { get; set; }
     *
     *        public string picture_path { get; set; }
     *
     *        public string background_color { get; set; }
     *
     *        public WallpaperSettings () {
     *            base ("desktop.Wallpaper");
     *        }
     *
     *        protected override void verify (string key) {
     *
     *            switch (key) {
     *
     *                case "background-color":
     *                    Gdk.Color bg;
     *                    if (!Gdk.Color.parse (background_color, out bg))
     *                        background_color = "#000000";
     *                    break;
     *            }
     *        }
     *
     *    }
     * }}}
     *
     * Keep in mind that the developer must define his/her enums to match the schema's.
     *
     * The following is a simplified explanation of how this library works:
*
     *  1. Any subclass looks at all properties it contains, and loads their initial values from the keys they represent.
     *     Because Vala properties are stored as GLib properties, the string representation of a property replaces underscores with
     *     hyphens (i.e. property_name becomes "property-name"). This is how this library knows which keys to load from. If the key
     *     does not exist, it will result in a fatal error.
     *  1. When a property of the subclass changes, the library will first verify the data before emitting a changed signal. If necessary,
     *     the library will change the value of the property while verifying.
     *     This is why developers should only act upon emissions of the changed () signal and never the native {@link GLib.Object.notify} signal.
     *  1. When the corresponding key of one of the properties of the subclass changes, it will also verify the data and change it, if necessary,
     *     before loading it into as the corresponding property's value.
     */
    [Version (deprecated = true, deprecated_since = "5.4.0", replacement = "GLib.Settings")]
    public abstract class Settings : GLib.Object {

        /**
         * Used internally to avoid mutual signal calls.
         */
        bool saving_key;

        /**
         * This signal is to be used in place of the standard {@link GLib.Object.notify} signal.
         *
         * This signal ''only'' emits after a property's value was verified.
         *
         * Note that in the case where a property was set to an invalid value,
         * (and thus, sanitized to a valid value), the {@link GLib.Object.notify} signal will emit
         * twice: once with the invalid value and once with the sanitized value.
         */
        [Signal (no_recurse = true, run = "first", action = true, no_hooks = true, detailed = true)]
        public signal void changed ();

        public GLib.Settings schema { get; construct; }

        /**
         * Creates a new {@link Granite.Services.Settings} object for the supplied schema.
         *
         * @param schema the name of the schema to interact with
         */
        protected Settings (string schema) {
            Object (schema: new GLib.Settings (schema));
        }

        /**
         * Creates a new {@link Granite.Services.Settings} object for the supplied schema and {@link GLib.SettingsBackend}.
         *
         * @param schema the name of the schema to interact with
         * @param backend the desired backend to use
         */
        protected Settings.with_backend (string schema, SettingsBackend backend) {
            Object (schema: new GLib.Settings.with_backend (schema, backend));
        }

        /**
         * Creates a new {@link Granite.Services.Settings} object for the supplied schema, {@link GLib.SettingsBackend}, and path.
         *
         *
         * @param schema the name of the schema to interact with
         * @param backend the desired backend to use
         * @param path the path to use
         */
        protected Settings.with_backend_and_path (string schema, SettingsBackend backend, string path) {
            Object (schema: new GLib.Settings.with_backend_and_path (schema, backend, path));
        }

        /**
         * Creates a new {@link Granite.Services.Settings} object for the supplied schema, and path.
         *
         * You only need to do this if you want to directly create a settings object with a schema that
         * doesn't have a specified path of its own. That's quite rare.
         *
         * It is a programmer error to call this function for a schema that has an explicitly specified path.
         *
         * @param schema the name of the schema to interact with
         * @param path the path to use
         */
        protected Settings.with_path (string schema, string path) {
            Object (schema: new GLib.Settings.with_path (schema, path));
        }

        construct {

            debug ("Loading settings from schema '%s'", schema.schema_id);

            var obj_class = (ObjectClass) get_type ().class_ref ();
            var properties = obj_class.list_properties ();
            foreach (var prop in properties)
                load_key (prop.name);

            start_monitor ();
        }

        ~Settings () {
            stop_monitor ();
        }

        private void stop_monitor () {

            schema.changed.disconnect (load_key);
        }

        private void start_monitor () {

            schema.changed.connect (load_key);
        }

        void handle_notify (Object sender, ParamSpec property) {

            notify.disconnect (handle_notify);
            call_verify (property.name);
            notify.connect (handle_notify);

            save_key (property.name);
        }

        void handle_verify_notify (Object sender, ParamSpec property) {

            warning ("Key '%s' failed verification in schema '%s', changing value", property.name, schema.schema_id);
        }

        private void call_verify (string key) {

            notify.connect (handle_verify_notify);
            verify (key);
            changed[key] ();
            notify.disconnect (handle_verify_notify);
        }

        /**
         * Verify the given key, changing the property if necessary. Refer to the example given for the class.
         *
         * @param key the key in question
         */
        protected virtual void verify (string key) {
            // do nothing, this isn't abstract because we don't
            // want to force subclasses to implement this
        }

        private void load_key (string key) {
            if (key == "schema")
                return;

            var obj_class = (ObjectClass) get_type ().class_ref ();
            var prop = obj_class.find_property (key);

            // If a property for the key is not found, just return. Subclasses do not
            // necessarily have to import all the keys from a given schema.
            if (prop == null)
                return;

            notify.disconnect (handle_notify);

            var type = prop.value_type;
            var val = Value (type);
            this.get_property (prop.name, ref val);

            if (val.type () == prop.value_type) {
                // As all of these Properties are equal to their Settings Key, we can
                // apply them directly without problems.
                if (type == typeof (int))
                    set_property (prop.name, schema.get_int (key));
                else if (type == typeof (uint))
                    set_property (prop.name, schema.get_uint (key));
                else if (type == typeof (double))
                    set_property (prop.name, schema.get_double (key));
                else if (type == typeof (string))
                    set_property (prop.name, schema.get_string (key));
                else if (type == typeof (string[]))
                    set_property (prop.name, schema.get_strv (key));
                else if (type == typeof (bool))
                    set_property (prop.name, schema.get_boolean (key));
                else if (type == typeof (int64))
                    set_property (prop.name, schema.get_value (key).get_int64 ());
                else if (type == typeof (uint64))
                    set_property (prop.name, schema.get_value (key).get_uint64 ());
                else if (type.is_enum ())
                    set_property (prop.name, schema.get_enum (key));
            } else if (type.is_a (typeof (SettingsSerializable))) {
                get_property (key, ref val);
                (val.get_object () as SettingsSerializable).settings_deserialize (schema.get_string (key));
                notify.connect (handle_notify);
                return;
            } else {
                debug (
                    "Unsupported settings type '%s' for key '%s' in schema '%s'",
                    type.name (),
                    key,
                    schema.schema_id
                );
                notify.connect (handle_notify);
                return;
            }

            call_verify (key);

            notify.connect (handle_notify);
        }

        void save_key (string key) {
            if (key == "schema" || saving_key) {
                return;
            }

            var obj_class = (ObjectClass) get_type ().class_ref ();
            var prop = obj_class.find_property (key);

            // Do not attempt to save a non-mapped key
            if (prop == null) {
                return;
            }

            bool success = true;

            saving_key = true;
            notify.disconnect (handle_notify);

            var type = prop.value_type;
            var val = Value (type);
            this.get_property (prop.name, ref val);

            if (val.type () == prop.value_type) {
                if (type == typeof (int)) {
                    if (val.get_int () != schema.get_int (key)) {
                        success = schema.set_int (key, val.get_int ());
                    }
                } else if (type == typeof (uint)) {
                    if (val.get_uint () != schema.get_uint (key)) {
                        success = schema.set_uint (key, val.get_uint ());
                    }
                } else if (type == typeof (int64)) {
                    if (val.get_int64 () != schema.get_value (key).get_int64 ()) {
                        success = schema.set_value (key, new Variant.int64 (val.get_int64 ()));
                    }
                } else if (type == typeof (uint64)) {
                    if (val.get_uint64 () != schema.get_value (key).get_uint64 ()) {
                        success = schema.set_value (key, new Variant.uint64 (val.get_uint64 ()));
                    }
                } else if (type == typeof (double)) {
                    if (val.get_double () != schema.get_double (key)) {
                        success = schema.set_double (key, val.get_double ());
                    }
                } else if (type == typeof (string)) {
                    if (val.get_string () != schema.get_string (key)) {
                        success = schema.set_string (key, val.get_string ());
                    }
                } else if (type == typeof (string[])) {
                    string[] strings = null;
                    this.get (key, &strings);
                    if (strings != schema.get_strv (key)) {
                        success = schema.set_strv (key, strings);
                    }
                } else if (type == typeof (bool)) {
                    if (val.get_boolean () != schema.get_boolean (key)) {
                        success = schema.set_boolean (key, val.get_boolean ());
                    }
                } else if (type.is_enum ()) {
                    if (val.get_enum () != schema.get_enum (key)) {
                        success = schema.set_enum (key, val.get_enum ());
                    }
                }
            } else if (type.is_a (typeof (SettingsSerializable))) {
                success = schema.set_string (key, (val.get_object () as SettingsSerializable).settings_serialize ());
            } else {
                debug (
                    "Unsupported settings type '%s' for key '%s' in schema '%s'",
                    type.name (),
                    key,
                    schema.schema_id
                );
            }

            if (!success) {
                warning ("Key '%s' could not be written to.", key);
            }

            notify.connect (handle_notify);
            saving_key = false;
        }
    }
}
