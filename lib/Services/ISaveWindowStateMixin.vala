/*
 *  Copyright (C) 2012-2017 elementary LLC. (https://elementary.io)
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

/**
 * Add state saving feature to windows
 *
 * Mixin that saves Gtk.Window and inherited classes the position, size and maximize states
 * implementing [[https://elementary.io/docs/human-interface-guidelines#saving-state|elementary's HIG]]
 * accordingly with the [[https://elementary.io/docs/code/reference#saving-window-state|official reference]]
 * To use this you should have your gsetting schema like this:
 * {{{
 * <key name="window-maximized" type="b">
 *   <default>false</default>
 *   <summary>Maximized</summary>
 *   <description>Whether the window is maximized</description>
 * </key>
 * <key name="window-position" type="(ii)">
 *   <default>(1024, 750)</default>
 *   <summary>Window position</summary>
 *   <description>Most recent window position (x, y)</description>
 * </key>
 * <key name="window-size" type="(ii)">
 *   <default>(-1, -1)</default>
 *   <summary>Window size</summary>
 *   <description>Most recent window size (width, height)</description>
 * </key>
 * }}}
 *
 * If your window keys differs or you wish to save another window state you should override
 * getters putting you key names:
 *
 * ''Example:'' //ApplicationWindow//
 *
 * {{{
 *  public class ApplicationWindow : Gtk.ApplicationWindow, Granite.Services.ISaveWindowStateMixin {
 *    public ApplicationWindow () {
 *      // Restores the last window state and saves subsequent changes
 *      enable_restore_state (Application.settings);
 *      ...
 *    }
 *
 *    // If you need to use custom key names
 *    public override string get_window_maximized_key () {
 *       return "second-window-maximized"
 *    }
 *
 *    public override string get_window_position_key () {
 *       return "second-window-position"
 *    }
 *
 *    public override string get_window_size_key () {
 *       return "second-window-size"
 *    }
 *  }
 * }}}
 */
public interface Granite.Services.ISaveWindowStateMixin : Gtk.Window {

    /**
     * Allows Gtk.Window to save it's position, size and maximized state.
     *
     * Restores last known states of the window and listen to state changes
     * from event on Gtk.Window configure_event () to save state
     *
     * @param GLib.Settings The settings instance to save to.
     */
    public virtual void enable_restore_state (GLib.Settings settings) {
        configure_window (settings);
        configure_event.connect ((event) => on_configure_event (event, settings));
    }

    /**
     * Return the gsettings key for window maximized state key,
     * override method to use custom key
     * @return string "window-maximized"
     */
    public virtual string get_window_maximized_key () {
        return "window-maximized";
    }

    /**
     * Return the gsettings key for window position state key,
     * override method to use custom
     * @return string "window-position"
     */
    public virtual string get_window_position_key () {
        return "window-position";
    }

    /**
     * Return the gsettings key for window size state key,
     * override method to use custom
     * @return string "window-size"
     */
    public virtual string get_window_size_key () {
        return "window-size";
    }

    bool on_configure_event (Gdk.EventConfigure event, GLib.Settings settings) {
        delay_write_settings (settings);

        save_maximize_state (settings);
        save_window_postion_state (settings);
        save_window_size_state (settings);

        return false;
    }

    /**
     * Delay write settings on disk
     */
    void delay_write_settings (GLib.Settings settings, uint timeout = 1000) {
        settings.delay ();

        Timeout.add (timeout, () => {
            if (settings.has_unapplied) {
                settings.apply ();
            }

            return false;
        });
    }

    void configure_window (GLib.Settings settings) {
        restore_maximize_state (settings);
        restore_window_postion_state (settings);
        restore_window_size_state (settings);
    }

    void save_maximize_state (GLib.Settings settings) {
        settings.set_boolean (get_window_maximized_key (), is_maximized);
    }

    void save_window_postion_state (GLib.Settings settings) {
        int window_x, window_y;
        get_position (out window_x, out window_y);
        settings.set (get_window_position_key (), "(ii)", window_x, window_y);
    }

    void save_window_size_state (GLib.Settings settings) {
        int window_width, window_height;
        get_size (out window_width, out window_height);
        settings.set (get_window_size_key (), "(ii)", window_width, window_height);
    }

    void restore_maximize_state (GLib.Settings settings) {
        if (settings.get_boolean (get_window_maximized_key ())) {
            this.maximize ();
        }
    }

    void restore_window_postion_state (GLib.Settings settings) {
        int window_x, window_y;
        settings.get (get_window_position_key (), "(ii)", out window_x, out window_y);

        if (window_x != -1 ||  window_y != -1) {
            this.move (window_x, window_y);
        }
    }

    void restore_window_size_state (GLib.Settings settings) {
        int window_width, window_height;
        settings.get (get_window_size_key (), "(ii)", out window_width, out window_height);

        if (window_width + window_height > 0) {
            this.default_width = window_width;
            this.default_height = window_height;
        }
    }
}
