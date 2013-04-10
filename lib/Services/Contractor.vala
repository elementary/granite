/***
    Copyright (C) 2011-2013 Lucas Baudin <xapantu@gmail.com>

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

namespace Granite.Services {
    
    public struct GenericContract {
        string id;
        string display_name;
        string description;
        string icon_path;
    }

    [DBus (name = "org.elementary.Contractor")]
    interface ContractorDBus : Object {   
        [Deprecated]
        public abstract GLib.HashTable<string,string>[] GetServicesByLocation (string strlocation, string? file_mime="")    throws IOError;
        [Deprecated]
        public abstract GLib.HashTable<string,string>[] GetServicesByLocationsList (GLib.HashTable<string,string>[] locations)  throws IOError;
        public abstract GenericContract[] list_all_contracts () throws Error;
        public abstract GenericContract[] get_contracts_by_mime (string mime_type) throws Error;
        public abstract GenericContract[] get_contracts_by_mimelist (string[] mime_types) throws Error;
        public abstract int execute_with_uri (string id, string path) throws Error;
        public abstract int execute_with_uri_list (string id, string[] path) throws Error;
    }

    /**
     * A way to handle contractor, a way to communicate between apps.
     * 
     */
    public class Contractor : Object {

        internal ContractorDBus contract;

        internal static Contractor? contractor = null;

        /**
         * This creates a new Contractor 
         */
        private Contractor() {
            try {
                contract = Bus.get_proxy_sync (BusType.SESSION,
                                               "org.elementary.Contractor",
                                               "/org/elementary/contractor");
            } catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }
        }

        internal static void ensure () {
            if(contractor == null) contractor = new Contractor ();
        }

        /**
         * Lists all the contracts
         *
         * @return an array of struct GenericContract
         */
        public static GenericContract[] list_all_contracts () {
            ensure ();
            GenericContract[] contracts = null;

            try {
                contracts = contractor.contract.list_all_contracts ();
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }

        /**
         * This searches for available contracts of a particular file
         *
         * @param mime mime type of file
         * @return an array of struct GenericContract
         */
        public static GenericContract[] get_contracts_by_mime (string mime_type) {
            ensure ();
            GenericContract[] contracts = null;

            try {
                contracts = contractor.contract.get_contracts_by_mime (mime_type);
            } catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }

        /**
         * generate contracts for a list of mime types. the contracts which support
         * all of them are returned
         *
         * @param locations Array of MimeTypes
         * @return array of struct (GenericContract)
         */
        public static GenericContract[] get_contracts_by_mimelist (string[] mime_types) {
            ensure ();
            GenericContract[] contracts = null;

            try {
                contracts = contractor.contract.get_contracts_by_mimelist (mime_types);
            } catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }

        /**
         * This executes the exec parameter provided by the contract of given id
         * with the path as arguments
         *
         * @param id id of the contract
         * @param paths path to execute
         * @return int status of execution
         */
        public static int execute_with_uri (string id, string path) {
            ensure ();
            int ret_val = 1;

            try {
                ret_val = contractor.contract.execute_with_uri (id, path);
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
            return ret_val;
        }

        /**
         * This executes the exec parameter provided by the contract of given id
         * with the paths as arguments
         *
         * @param id id of the contract
         * @param paths array of paths to execute
         * @return int status of execution
         */
        public static int execute_with_uri_list (string id, string[] paths) {
            ensure ();
            int ret_val = 1;

            try {
                ret_val = contractor.contract.execute_with_uri_list (id, paths);
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
            return ret_val;
        }

        /**
         * The functions below have been deprecated in order to support the
         * the new contractor API.
         */

        /**
         * This searches for available contracts of a particular file
         * 
         * @param uri uri of file
         * @param mime mime type of file
         * @return Hashtable of available contracts
         */
        [Deprecated]
        public static GLib.HashTable<string,string>[] get_contract(string uri, string mime) {

            return { new GLib.HashTable<string,string> (null, null) };
        }

        /**
         * generate contracts for rguments and filter them by  common parent mimetype.
         * 
         * @param locations Hashtable of locations
         * @return Hashtable of available contracts
         */
        [Deprecated]
        public static GLib.HashTable<string,string>[] get_selection_contracts (GLib.HashTable<string, string>[] locations) {

            return { new GLib.HashTable<string,string> (null, null) };
        }
    }
}
