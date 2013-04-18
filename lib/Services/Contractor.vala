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

    public struct ContractorContract {
        string id;
        string display_name;
        string description;
        string icon_path;

        public int execute_uri (string uri) {
            return Contractor.execute_with_uri (this.id, uri);
        }
        public int execute_uris (string[] uris) {
            return Contractor.execute_with_uri_list (this.id, uris);
        }
    }

    [DBus (name = "org.elementary.Contractor")]
    internal interface ContractorDBus : Object {
        [Deprecated]
        public abstract GLib.HashTable<string,string>[] GetServicesByLocation (string strlocation, string? file_mime="")    throws IOError;
        [Deprecated]
        public abstract GLib.HashTable<string,string>[] GetServicesByLocationsList (GLib.HashTable<string,string>[] locations)  throws IOError;
        public abstract ContractorContract[] list_all_contracts () throws Error;
        public abstract ContractorContract[] get_contracts_by_mime (string mime_type) throws Error;
        public abstract ContractorContract[] get_contracts_by_mimelist (string[] mime_types) throws Error;
        public abstract int execute_with_uri (string id, string uri) throws Error;
        public abstract int execute_with_uri_list (string id, string[] uri) throws Error;
    }

    /*
     * interface that the contractor class must implement
     */
    public interface ContractorIface {
        public abstract ContractorContract[] get_contracts () throws ContractError;
        public abstract ContractorContract get_for_id (string id) throws ContractError;
    }

    /**
     * A way to handle contractor, a way to communicate between apps.
     *
     */
    public class Contractor : Object, ContractorIface {

        private string? mime_type;
        private string[]? mime_types;
        private ContractorContract[]? contracts;


        internal ContractorDBus contract;

        internal static Contractor? contractor = null;

        /**
         * This creates a new Contractor
         */
        private Contractor () {
            try {
                contract = Bus.get_proxy_sync (BusType.SESSION,
                                               "org.elementary.Contractor",
                                               "/org/elementary/contractor");
            } catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }
        }

        internal static void ensure () {
            if (contractor == null) {
                contractor = new Contractor ();
            }
        }

        /*
         * Class constructor for single mime type
         */
        public Contractor.for_mime (string mime) {
            this.mime_type = mime;
            this.mime_types = null;
        }

        /*
         * Class constructor for multiple mime types
         */
        public Contractor.for_mime_list (string[] mimes) {
            this.mime_types = mimes;
            this.mime_type = null;
        }

        /*
         * searches for contracts that support the specified mime type(s)
         * throws error if mime type is not set.
         */
        public ContractorContract[] get_contracts () throws ContractError {
            if (this.mime_type != null) {
                this.contracts = get_contracts_by_mime (this.mime_type);
                return contracts;
            } else if (this.mime_types != null) {
                contracts = get_contracts_by_mimelist (this.mime_types);
                return this.contracts;
            }
            throw new ContractError.OBJECT_ERROR ("data members are null");
        }

        /*
         * Searches for the contract with with the id as specified
         * if not found, throws NOT_FOUND error
         */
        public ContractorContract get_for_id (string id) throws ContractError {
            if (this.contracts == null) {
                throw new ContractError.NOT_FOUND ("contracts were not found");
            }
            foreach (var cont in this.contracts) {
                if (cont.id == id)
                    return cont;
            }
            throw new ContractError.NOT_FOUND ("Contract of this ID was not found");
        }

        /**
         * Lists all the contracts
         *
         * @return an array of struct ContractorContract
         */
        public static ContractorContract[] list_all_contracts () {
            ensure ();
            ContractorContract[] contracts = null;

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
         * @return an array of struct ContractorContract
         */
        public static ContractorContract[] get_contracts_by_mime (string mime_type) {
            ensure ();
            ContractorContract[] contracts = null;

            try {
                contracts = contractor.contract.get_contracts_by_mime (mime_type);
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }

        /**
         * generate contracts for a list of mime types. the contracts which support
         * all of them are returned
         *
         * @param locations Array of MimeTypes
         * @return array of struct (ContractorContract)
         */
        public static ContractorContract[] get_contracts_by_mimelist (string[] mime_types) {
            ensure ();
            ContractorContract[] contracts = null;

            try {
                contracts = contractor.contract.get_contracts_by_mimelist (mime_types);
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }

        /**
         * This executes the exec parameter provided by the contract of given id
         * with the uri as arguments
         *
         * @param id id of the contract
         * @param uris uri to execute
         * @return int status of execution
         */
        public static int execute_with_uri (string id, string uri) {
            ensure ();
            int ret_val = 1;

            try {
                ret_val = contractor.contract.execute_with_uri (id, uri);
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
            return ret_val;
        }

        /**
         * This executes the exec parameter provided by the contract of given id
         * with the uris as arguments
         *
         * @param id id of the contract
         * @param uris array of uris to execute
         * @return int status of execution
         */
        public static int execute_with_uri_list (string id, string[] uris) {
            ensure ();
            int ret_val = 1;

            try {
                ret_val = contractor.contract.execute_with_uri_list (id, uris);
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

    public errordomain ContractError {
        OBJECT_ERROR,
        NOT_FOUND
    }
}
