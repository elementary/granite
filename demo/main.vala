using Granite.Widgets;

public class Granite.Demo : Granite.Application
{
    public Demo()
    {
        Object(application_id:"demo.granite.org");
        var win = new Gtk.Window();
        win.delete_event.connect( () => { Gtk.main_quit(); return false; });
        
        var notebook = new Gtk.Notebook();
        win.add(notebook);
        
        /* welcome */
        var welcome = new Welcome("Granite", "Let's try...");
        notebook.append_page(welcome, new Gtk.Label("Welcome"));
        welcome.append("gtk-open", "Open", "Open a file");
        welcome.append("gtk-save", "Save", "Save with a much longer description");
        win.show_all();
        win.resize(800, 600);
    }

    public static int main(string[] args)
    {
        Gtk.init(ref args);
        new Granite.Demo();
        
        Gtk.main();
        
        return 0;
    }
}