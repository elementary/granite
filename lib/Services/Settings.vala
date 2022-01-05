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
}
