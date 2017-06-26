/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public abstract class Granite.SettingsPage : Gtk.ScrolledWindow {
    public const string DISABLED = _("Disabled");
    public const string ENABLED = _("Enabled");

    public enum StatusType {
        ERROR,
        OFFLINE,
        SUCCESS,
        WARNING,
        NONE
    }

    public StatusType status_type { get; set; default = StatusType.NONE; } // Making the enum nullable seems to break it
    public Gtk.Widget? display_widget { get; construct; }
    public string? header { get; construct; }
    public string? icon_name { get; construct; }
    public string status { get; set; }
    public string title { get; construct; }
}
