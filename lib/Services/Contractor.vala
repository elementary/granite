/***
    Copyright (C) 2011-2013 Lucas Baudin <xapantu@gmail.com>,
                            Akshay Shekher <voldyman666@gmail.com>,
                            Victor Martinez <victoreduardm@gmail.com>

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
    public interface Contract : Object {
        public abstract string get_display_name ();
        public abstract string get_description ();
        public abstract Icon get_icon ();
        public abstract int execute_with_file (File file) throws Error;
        public abstract int execute_with_files (File[] files) throws Error;
    }

    internal struct ContractData {
        string id;
        string display_name;
        string description;
        string icon_path;
    }

    [DBus (name = "org.elementary.Contractor")]
    internal interface ContractorDBus : Object {
        public abstract ContractData[] list_all_contracts () throws Error;
        public abstract ContractData[] get_contracts_by_mime (string mime_type) throws Error;
        public abstract ContractData[] get_contracts_by_mimelist (string[] mime_types) throws Error;
        public abstract int execute_with_uri (string id, string uri) throws Error;
        public abstract int execute_with_uri_list (string id, string[] uri) throws Error;
    }

    public class Contractor {
        private class GenericContract : Object, Contract {
            private ContractData data;
            private Icon icon;

            public GenericContract (ContractData data) {
                this.data = data;
            }

            public string get_display_name () {
                return data.display_name;
            }

            public string get_description () {
                return data.description;
            }

            public Icon get_icon () {
                if (icon == null) {
                    var icon_file = File.new_for_path (data.icon_path);
                    icon = new FileIcon (icon_file);
                }

                return icon;
            }

            public int execute_with_file (File file) throws Error {
                return Contractor.execute_with_uri (data.id, file.get_uri ());
            }

            public int execute_with_files (File[] files) throws Error {
                string[] uris = new string[files.length];

                foreach (var file in files)
                    uris += file.get_uri ();

                return Contractor.execute_with_uri_list (data.id, uris);
            }
        }


        private static ContractorDBus contractor_dbus;

        /* Used to keep references of contracts around. Contracts are unowned by the map
         * because their references are only useful if the client code still has its own
         * references around. Otherwise no client code would have reference for us to compare
         * against, so keeping our own one would not be useful for our purposes.
         */
        private static Gee.HashMap<string, unowned Contract> contracts;

        private Contractor () {
        }

        private static void ensure () {
            if (contractor_dbus == null) {
                try {
                    contractor_dbus = Bus.get_proxy_sync (BusType.SESSION,
                                                          "org.elementary.Contractor",
                                                          "/org/elementary/contractor");
                } catch (IOError e) {
                    warning (e.message);
                }
            }

            if (contracts == null)
                contracts = new Gee.HashMap<string, unowned Contract> ();
        }

        private static int execute_with_uri (string id, string uri) throws Error {
            ensure ();
            return contractor_dbus.execute_with_uri (id, uri);
        }

        private static int execute_with_uri_list (string id, string[] uris) throws Error {
            ensure ();
            return contractor_dbus.execute_with_uri_list (id, uris);
        }

        /**
         * Provides all the contracts.
         *
         * @return List containing all the contracts available in the system.
         */
        public static List<Contract> get_all_contracts () {
            ensure ();
            ContractData[] data = null;

            try {
                data = contractor_dbus.list_all_contracts ();
            } catch (Error e) {
                warning (e.message);
            }

            return get_contracts_from_data (data);
        }

        /**
         * This searches for available contracts of a particular file type.
         *
         * @param mime Mimetype of file.
         * @return List of contracts that support the given mimetype.
         */
        public static List<Contract> get_contracts_by_mime (string mime_type) {
            ensure ();
            ContractData[] data = null;

            try {
                data = contractor_dbus.get_contracts_by_mime (mime_type);
            } catch (Error e) {
                warning (e.message);
            }

            return get_contracts_from_data (data);
        }

        /**
         * Generate contracts for a list of mimetypes.
         *
         * Only the contracts that support all the mimetypes are returned.
         *
         * @param locations Array of mimetypes.
         * @return List of contracts that support the given mimetypes.
         */
        public static List<Contract> get_contracts_by_mimelist (string[] mime_types) {
            ensure ();
            ContractData[] data = null;

            try {
                data = contractor_dbus.get_contracts_by_mimelist (mime_types);
            } catch (Error e) {
                warning (e.message);
            }

            return get_contracts_from_data (data);
        }

        private static List<Contract> get_contracts_from_data (ContractData[] data) {
            var contract_list = new List<Contract> ();

            if (data != null && data.length > 0) {
                foreach (var contract_data in data) {
                    string contract_id = contract_data.id;

                    /* See if we have a contract already. Otherwise create a new one.
                     * We do this in order to be able to compare contracts by reference
                     * from client code.
                     */
                    var contract = contracts.get (contract_id);

                    if (contract == null) {
                        contract = new GenericContract (contract_data);
                        contracts.set (contract_id, contract);
                    }

                    contract_list.prepend (contract);
                }
            }

            return contract_list;
        }

        /**
         * This searches for available contracts of a particular file
         *
         * @param uri uri of file
         * @param mime mime type of file
         * @return Hashtable of available contracts
         */
        [Deprecated (since = "0.2", replacement = "Granite.Services.Contractor.get_contracts_by_mime")]
        public static GLib.HashTable<string,string>[] get_contract(string uri, string mime) {
            return { new GLib.HashTable<string,string> (null, null) };
        }

        /**
         * generate contracts for arguments and filter them by  common parent mimetype.
         *
         * @param locations Hashtable of locations
         * @return Hashtable of available contracts
         */
        [Deprecated (since = "0.2", replacement = "Granite.Services.Contractor.get_contracts_by_mimelist")]
        public static GLib.HashTable<string,string>[] get_selection_contracts (GLib.HashTable<string, string>[] locations) {
            return { new GLib.HashTable<string,string> (null, null) };
        }
    }
}
