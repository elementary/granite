/***
    Copyright (C) 2012-2013 Granite Developers

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

public enum Granite.TextStyle {
    /**
     * Highest level header
     */
    TITLE,
    
    /**
     * Second highest header
     */
    H1,
    
    /**
     * Third highest header
     */
    H2,
    
    /**
     * Fourth Highest Header
     */
    H3;

    /**
     * Gets style sheet of text style
     *
     * @return CSS of text style
     */
    public string get_stylesheet (out string style_class = null) {
        switch (this) {
            case TITLE:
                style_class = StyleClass.TITLE_TEXT;
                return @".$style_class { font: raleway 36; }";
            case H1:
                style_class = StyleClass.H1_TEXT;
                return @".$style_class { font: open sans bold 24; }";
            case H2:
                style_class = StyleClass.H2_TEXT;
                return @".$style_class { font: open sans light 18; }";
            case H3:
                style_class = StyleClass.H3_TEXT;
                return @".$style_class { font: open sans bold 12; }";
            default:
                assert_not_reached ();
        }
    }
}

public enum Granite.CloseButtonPosition
{
	LEFT,
	RIGHT
}

/**
 * This class helps to apply CSS to widgets.
 */
namespace Granite.Widgets.Utils {

    [CCode (cname="get_close_pixbuf")]
    public extern Gdk.Pixbuf get_close_pixbuf ();


    /**
     * Applies the stylesheet to the widget
     * 
     * @param widget widget to apply style to
     * @param stylesheet style to apply to screen
     * @param class_name class name to add style to
     * @param priority priorty of change
     */
    public Gtk.CssProvider? set_theming (Gtk.Widget widget, string stylesheet,
                              string? class_name, int priority) {
        var css_provider = get_css_provider (stylesheet);

        var context = widget.get_style_context ();

        if (css_provider != null)
            context.add_provider (css_provider, priority);

        if (class_name != null && class_name.strip () != "")
            context.add_class (class_name);

        return css_provider;
    }

    /**
     * Applies a stylesheet to the given screen. This will affects all the
     * widgets which are part of that screen.
     * 
     * @param screen Screen to apply style to
     * @param stylesheet style to apply to screen
     * @param priority priorty of change
     */
    public Gtk.CssProvider? set_theming_for_screen (Gdk.Screen screen, string stylesheet, int priority) {
        var css_provider = get_css_provider (stylesheet);

        if (css_provider != null)
            Gtk.StyleContext.add_provider_for_screen (screen, css_provider, priority);

        return css_provider;
    }

    /**
     * @return a new {@link Gtk.CssProvider}, or null in case the parsing of
     *         //stylesheet// failed.
     */
    public Gtk.CssProvider? get_css_provider (string stylesheet) {
        Gtk.CssProvider provider = new Gtk.CssProvider ();

        try {
            provider.load_from_data (stylesheet, -1);
        }
        catch (Error e) {
            warning ("Could not create CSS Provider: %s\nStylesheet:\n%s",
                     e.message, stylesheet);
            return null;
        }

        return provider;
    }

    internal bool is_left_to_right (Gtk.Widget widget) {
        var dir = widget.get_direction ();
        if (dir == Gtk.TextDirection.NONE)
            dir = Gtk.Widget.get_default_direction ();
        return dir == Gtk.TextDirection.LTR;
    }

    /**
     * This method applies given text style to given label
     * 
     * @param text_style text style to apply
     * @param label label to apply style to
     */
    public void apply_text_style_to_label (TextStyle text_style, Gtk.Label label) {
        var style_provider = new Gtk.CssProvider ();
        var style_context = label.get_style_context ();

        string style_class, stylesheet;
        stylesheet = text_style.get_stylesheet (out style_class);
        style_context.add_class (style_class);

        try {
            style_provider.load_from_data (stylesheet, -1);
        } catch (Error err) {
            warning ("Couldn't apply style to label: %s", err.message);
            return;
        }

        style_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

	const string WM_SETTINGS_PATH = "org.gnome.desktop.wm.preferences";
	const string PANTHEON_SETTINGS_PATH = "org.pantheon.desktop.gala.appearance";
	const string WM_BUTTON_LAYOUT_KEY = "button-layout";

	/**
	 * This method returns the close button position as configured for the window manager. If you
	 * need to know when this key changed, it's best to listen on the schema returned by
	 * {@link Granite.Widgets.Utils.get_button_layout_schema} for changes and then call this method again.
	 *
	 * @param failed if no schema was detected by {@link Granite.Widgets.Utils.get_button_layout_schema}
	 *               or there was no close value in the button-layout string, this bool will be true. The
	 *               returned will be LEFT in that case.
	 * @return a {@link Granite.CloseButtonPosition} indicating where to best put the close button
	 */
	public CloseButtonPosition get_default_close_button_position (out bool? failed = null)
	{
		var schema = get_button_layout_schema ();
		if (schema == null) {
			if (failed != null)
				failed = true;
			return CloseButtonPosition.LEFT;
		}

		var layout = new Settings (schema).get_string (WM_BUTTON_LAYOUT_KEY);
		var parts = layout.split (":");

		if (parts.length < 2) {
			if (failed != null)
				failed = true;
			return CloseButtonPosition.LEFT;
		}

		if ("close" in parts[0])
			return CloseButtonPosition.LEFT;
		else if ("close" in parts[1])
			return CloseButtonPosition.RIGHT;
		else {
			if (failed != null)
				failed = true;
			return CloseButtonPosition.LEFT;
		}
	}

	/**
	 * This methods returns the schema used by {@link Granite.Widgets.Utils.get_default_close_button_position}
	 * to determine the close button placement. It will first check for the pantheon/gala schema and then fallback
	 * to the default gnome one. If neither is available, NULL is returned. Make sure to check for this case, 
	 * as otherwise your program may crash on startup.
	 *
	 * @return the schema name
	 */
	public string? get_button_layout_schema ()
	{
		var schemas = GLib.Settings.list_schemas ();

		string schema;
		if (PANTHEON_SETTINGS_PATH in schemas)
			schema = PANTHEON_SETTINGS_PATH;
		else if (WM_SETTINGS_PATH in schemas)
			schema = WM_SETTINGS_PATH;
		else {
			warning ("No schema indicating the button-layout is installed.");
			return null;
		}

		return schema;
	}
}
