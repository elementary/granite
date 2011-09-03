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
        
        var mode_button = new ModeButton();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;
        mode_button.append(new Gtk.Label("Hardware"));
        mode_button.append(new Gtk.Label("Input"));
        mode_button.append(new Gtk.Label("Output"));
        mode_button.append(new Gtk.Label("Quite long"));
        mode_button.append(new Gtk.Label("Veruy very long \n with a line break"));
        
        var vbox = new Gtk.VBox(false, 0);
        
        vbox.pack_start(mode_button);

        mode_button = new ModeButton();
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;
        mode_button.append(new Gtk.Label("Small"));
        mode_button.append(new Gtk.Label("a"));
        vbox.pack_start(mode_button);
        notebook.append_page(vbox, new Gtk.Label("ModeButton"));
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