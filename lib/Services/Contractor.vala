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

    [DBus (name = "org.elementary.contractor")]
    interface ContractorDBus : Object
    {
        public abstract GLib.HashTable<string,string>[] GetServicesByLocation (string strlocation, string? file_mime="")    throws IOError;
        public abstract GLib.HashTable<string,string>[] GetServicesByLocationsList (GLib.HashTable<string,string>[] locations)  throws IOError;
    }

    /**
     * A way to handle contractor, a way to communicate between apps.
     * 
     * /!\ Highly unstable API
     */
    public class Contractor : Object
    {

        internal ContractorDBus contract;

        internal static Contractor? contractor = null;

        /**
         * This creates a new Contractor 
         */
        public Contractor()
        {
            try
            {
                contract = Bus.get_proxy_sync (BusType.SESSION,
                                               "org.elementary.contractor",
                                               "/org/elementary/contractor");
            }
            catch (IOError e)
            {
                stderr.printf ("%s\n", e.message);
            }
        }

        internal static void ensure ()
        {
            if(contractor == null) contractor = new Contractor ();
        }

        /**
         * This searches for available contracts of a particular file
         * 
         * @param uri uri of file
         * @param mime mime type of file
         * @return Hashtable of available contracts
         */
        public static GLib.HashTable<string,string>[] get_contract(string uri, string mime)
        {
            ensure ();
            GLib.HashTable<string,string>[] contracts = null;

            try {
                contracts = contractor.contract.GetServicesByLocation(uri, mime);
            }catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }

        /**
         * generate contracts for rguments and filter them by  common parent mimetype.
         * 
         * @param locations Hashtable of locations
         * @return Hashtable of available contracts
         */
        public static GLib.HashTable<string,string>[] get_selection_contracts (GLib.HashTable<string, string>[] locations)
        {
            ensure ();
            GLib.HashTable<string,string>[] contracts = null;

            try {
                contracts = contractor.contract.GetServicesByLocationsList (locations);
            }catch (IOError e) {
                stderr.printf ("%s\n", e.message);
            }

            return contracts;
        }
    }
}
