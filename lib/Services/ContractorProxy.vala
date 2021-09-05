/*
 * Copyright 2011-2013 Lucas Baudin <xapantu@gmail.com>
 * Copyright 2011-2013 Akshay Shekher <voldyman666@gmail.com>
 * Copyright 2011-2013 Victor Martinez <victoreduardm@gmail.com>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite.Services {
    /**
     * Interface for executing and accessing properties of Contractor actions
     */
    public interface Contract : Object {

        /**
         * Returns the display name of the contract, already internationalized
         *
         * @return The internationalized value of the 'Name' key in the .contract file.
         * As of 2014, Contractor uses gettext to handle internationalization.
         */
        public abstract string get_display_name ();

        /**
         * Returns the description of the contract, already internationalized
         *
         * @return The internationalized value of the 'Description' key in the .contract file.
         * As of 2014, Contractor uses gettext to handle internationalization.
         */
        public abstract string get_description ();

        /**
         * Returns an icon for this contract
         *
         * @return {@link GLib.Icon} based on the 'Icon' key in the .contract file.
         */
        public abstract Icon get_icon ();

        /**
         * Executes the action on the given file
         */
        public abstract void execute_with_file (File file) throws Error;

        /**
         * Executes the action on the given list of files
         */
        public abstract void execute_with_files (File[] files) throws Error;
    }

    /**
     * thrown by {@link Granite.Services.ContractorProxy}
     */
    public errordomain ContractorError {
        /**
         * Usually means that Contractor is not installed or not configured properly
         *
         * Contractor is not a compile-time dependency, so it is possible to
         * install an application that uses it without installing Contractor.
         *
         * Upon receiving this error the application should disable its Contractor-related
         * functionality, which typically means hiding the relevant UI elements.
         */
        SERVICE_NOT_AVAILABLE
    }

    internal struct ContractData {
        string id;
        string display_name;
        string description;
        string icon;
    }

    [DBus (name = "org.elementary.Contractor")]
    internal interface ContractorDBusAPI : Object {
        public signal void contracts_changed ();

        public abstract ContractData[] list_all_contracts () throws Error;
        public abstract ContractData[] get_contracts_by_mime (string mime_type) throws Error;
        public abstract ContractData[] get_contracts_by_mimelist (string[] mime_types) throws Error;
        public abstract void execute_with_uri (string id, string uri) throws Error;
        public abstract void execute_with_uri_list (string id, string[] uri) throws Error;
    }

    /**
     * Provides a convenient GObject wrapper around Contractor's D-bus API
     */
    public class ContractorProxy : Object {
        private class GenericContract : Object, Contract {
            public string id { get; private set; }

            private string display_name;
            private string description;
            private string icon_key;

            private Icon icon;

            public GenericContract (ContractData data) {
                icon_key = "";
                update_data (data);
            }

            public void update_data (ContractData data) {
                id = data.id ?? "";
                display_name = data.display_name ?? "";
                description = data.description ?? "";

                if (icon_key != data.icon) {
                    icon_key = data.icon ?? "";
                    icon = null;
                }
            }

            public string get_display_name () {
                return display_name;
            }

            public string get_description () {
                return description;
            }

            public Icon get_icon () {
                if (icon == null) {
                    if (Path.is_absolute (icon_key))
                        icon = new FileIcon (File.new_for_path (icon_key));
                    else
                        icon = new ThemedIcon.with_default_fallbacks (icon_key);
                }

                return icon;
            }

            public void execute_with_file (File file) throws Error {
                ContractorProxy.execute_with_uri (id, file.get_uri ());
            }

            public void execute_with_files (File[] files) throws Error {
                string[] uris = new string[0];

                foreach (var file in files)
                    uris += file.get_uri ();

                ContractorProxy.execute_with_uri_list (id, uris);
            }
        }

        /**
         * Emitted when the list of actions available to Contractor changes.
         * Application should generally request the updated list of actions upon receiving this signal.
         *
         * This is not obligatory for frequently updated lists (e.g. in context menus), 
         * but essential for applications that display action lists without re-requesting them.
         */
        public signal void contracts_changed ();

        private static ContractorDBusAPI contractor_dbus;
        private static Gee.HashMap<string, GenericContract> contracts;
        private static ContractorProxy instance;

        private ContractorProxy () throws Error {
            ensure ();
        }

        public static ContractorProxy get_instance () throws Error {
            if (instance == null)
                instance = new ContractorProxy ();
            return instance;
        }

        private static void ensure () throws Error {
            if (contractor_dbus == null) {
                try {
                    contractor_dbus = Bus.get_proxy_sync (BusType.SESSION,
                                                          "org.elementary.Contractor",
                                                          "/org/elementary/contractor");
                    contractor_dbus.contracts_changed.connect (on_contracts_changed);
                } catch (IOError e) {
                    throw new ContractorError.SERVICE_NOT_AVAILABLE (e.message);
                }
            }

            if (contracts == null)
                contracts = new Gee.HashMap<string, GenericContract> ();
        }

        private static void on_contracts_changed () {
            try {
                var all_contracts = get_all_contracts ();
                var to_remove = new Gee.LinkedList<GenericContract> ();

                // Remove contracts no longer present in the system.
                // get_all_contracts already provided references to the contracts
                // that have not been removed, so those are kept.
                foreach (var contract in contracts.values) {
                    if (!all_contracts.contains (contract))
                        to_remove.add (contract);
                }

                foreach (var contract in to_remove)
                    contracts.unset (contract.id);

                int diff = contracts.size - all_contracts.size;

                if (diff < 0)
                    critical ("Failed to add %d contracts.", diff);
                else if (diff > 0)
                    critical ("Failed to remove %d contracts.", diff);

                if (instance != null)
                    instance.contracts_changed ();
            } catch (Error err) {
                warning ("Could not process changes in contracts: %s", err.message);
            }
        }

        private static void execute_with_uri (string id, string uri) throws Error {
            ensure ();
            contractor_dbus.execute_with_uri (id, uri);
        }

        private static void execute_with_uri_list (string id, string[] uris) throws Error {
            ensure ();
            contractor_dbus.execute_with_uri_list (id, uris);
        }

        /**
         * Provides all the contracts.
         *
         * @return {@link Gee.List} containing all the contracts available in the system.
         */
        public static Gee.List<Contract> get_all_contracts () throws Error {
            ensure ();

            var data = contractor_dbus.list_all_contracts ();

            return get_contracts_from_data (data);
        }

        /**
         * Returns actions (contracts) applicable to the given mimetypes.
         *
         * @param mime_type Mimetype of file.
         * @return {@link Gee.List} of contracts that support the given mimetype.
         */
        public static Gee.List<Contract> get_contracts_by_mime (string mime_type) throws Error {
            ensure ();

            var data = contractor_dbus.get_contracts_by_mime (mime_type);

            return get_contracts_from_data (data);
        }

        /**
         * Returns actions (contracts) applicable to all given mimetypes.
         *
         * Only the contracts that support all of the mimetypes are returned.
         *
         * @param mime_types Array of mimetypes.
         * @return {@link Gee.List} of contracts that support the given mimetypes.
         */
        public static Gee.List<Contract> get_contracts_by_mimelist (string[] mime_types) throws Error {
            ensure ();

            var data = contractor_dbus.get_contracts_by_mimelist (mime_types);

            return get_contracts_from_data (data);
        }

        /**
         * Returns actions (contracts) applicable to the given file.
         *
         * Errors occurring in {@link GLib.File.query_info} method while looking up
         * the file (e.g. if the file is deleted) are forwarded to the caller.
         *
         * @param file An existing file.
         * @return {@link Gee.List} of contracts applicable to the given file.
         */
        public static Gee.List<Contract> get_contracts_for_file (File file) throws Error {
            File[] files = { file };
            return get_contracts_for_files (files);
        }

        /**
         * Returns actions (contracts) applicable to all given files.
         *
         * Only the contracts that support all of the files are returned.<<BR>>
         * Errors occurring in {@link GLib.File.query_info} method while looking up
         * the file (e.g. if the file is deleted) are forwarded to the caller.<<BR>>
         *
         * @param files Array of existing files.
         * @return {@link Gee.List} of contracts applicable to any of the given files.
         */
        public static Gee.List<Contract> get_contracts_for_files (File[] files) throws Error {
            var mime_types = new Gee.HashSet<string> (); //for automatic deduplication

            foreach (var file in files) {
                var content_type = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE,
                                                    FileQueryInfoFlags.NONE).get_content_type ();
                mime_types.add (ContentType.get_mime_type (content_type));
            }

            return get_contracts_by_mimelist (mime_types.to_array ());
        }

        private static Gee.List<Contract> get_contracts_from_data (ContractData[] data) {
            var contract_list = new Gee.LinkedList<Contract> ();

            if (data != null) {
                foreach (var contract_data in data) {
                    string contract_id = contract_data.id;

                    // See if we have a contract already. Otherwise create a new one.
                    // We do this in order to be able to compare contracts by reference
                    // from client code.
                    var contract = contracts.get (contract_id);

                    if (contract == null) {
                        contract = new GenericContract (contract_data);
                        contracts.set (contract_id, contract);
                    } else {
                        contract.update_data (contract_data);
                    }

                    contract_list.add (contract);
                }
            }

            return contract_list;
        }
    }
}
