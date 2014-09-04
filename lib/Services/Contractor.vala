/*
 *  Copyright (C) 2011-2013 Lucas Baudin <xapantu@gmail.com>
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

namespace Granite.Services {
    [DBus (name = "org.elementary.Contractor")]
    interface ContractorDBus : Object {
        public abstract GLib.HashTable<string,string>[] GetServicesByLocation (string strlocation, string? file_mime = "") throws IOError;
        public abstract GLib.HashTable<string,string>[] GetServicesByLocationsList (GLib.HashTable<string,string>[] locations) throws IOError;
    }

    /**
     * Wrapper around a long-obsolete and unused revision of Contractor API
     */
    [Deprecated (replacement = "Granite.Services.ContractorProxy", since = "0.2")]
    public class Contractor : Object {
        internal ContractorDBus contract;
        internal static Contractor? contractor = null;

        /**
         * This creates a new Contractor 
         */
        public Contractor () {
        }

        internal static void ensure () {
        }

        /**
         * This searches for available contracts of a particular file
         *
         * @param uri uri of file
         * @param mime mime type of file
         * @return Hashtable of available contracts
         */
        public static GLib.HashTable<string,string>[] get_contract (string uri, string mime) {
            return { new GLib.HashTable<string,string> (null, null) };
        }

        /**
         * generate contracts for arguments and filter them by common parent mimetype.
         *
         * @param locations Hashtable of locations
         * @return Hashtable of available contracts
         */
        public static GLib.HashTable<string,string>[] get_selection_contracts (GLib.HashTable<string, string>[] locations) {
            return { new GLib.HashTable<string,string> (null, null) };
        }
    }
}
