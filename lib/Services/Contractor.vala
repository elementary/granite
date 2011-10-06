[DBus (name = "org.elementary.contractor")]
interface ContractorDBus : Object
{
    public abstract GLib.HashTable<string,string>[] GetServicesByLocation (string strlocation, string? file_mime="")    throws IOError;
    public abstract GLib.HashTable<string,string>[] GetServicesByLocationsList (GLib.HashTable<string,string>[] locations)  throws IOError;
}

public class Contractor : Object
{

    internal ContractorDBus contract;

    internal static Contractor? contractor = null;

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
