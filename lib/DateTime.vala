/*
 *  Copyright (C) 2012-2017 Granite Developers
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
 * The DateTime namespace contains useful functions for
 * getting the default translated format for either date and time.
 */
namespace Granite.DateTime {
    /**
     * Gets a default translated time format.
     * The function constructs a new string interpreting the //is_12h// and //with_second// parameters
     * so that it can be used with formatting functions like {@link GLib.DateTime.format}.
     *
     * The returned string is formatted and translated. This function is mostly used to display
     * the time in various user interfaces like the time displayed in the top panel.
     *
     * @param is_12h if the returned string should be formatted in 12h format
     * @param with_second if the returned string should include seconds
     *
     * @return the formatted and located time string.
     */
    public static string get_default_time_format (bool is_12h = false, bool with_second = false) {
        if (is_12h == true) {
            if (with_second == true) {
                /// TRANSLATORS: a GLib.DateTime format showing the hour (12h format) with seconds
                return _("%l:%M:%S %p");
            } else {
                /// TRANSLATORS: a GLib.DateTime format showing the hour (12h format)
                return _("%l:%M %p");
            }
        } else {
            if (with_second == true) {
                /// TRANSLATORS: a GLib.DateTime format showing the hour (24h format) with seconds
                return _("%H:%M:%S");
            } else {
                /// TRANSLATORS: a GLib.DateTime format showing the hour (24h format)
                return _("%H:%M");
            }
        }
    }

    /**
     * Gets the //clock-format// key from //org.gnome.desktop.interface// schema
     * and determines if the clock format is 12h based
     *
     * @return true if the clock format is 12h based, false otherwise.
     */
    private static bool is_clock_format_12h () {
        var h24_settings = new Settings ("org.gnome.desktop.interface");
        var format = h24_settings.get_string ("clock-format");
        return (format.contains ("12h"));
    }

    /**
     * Gets the default translated date format.
     * The function constructs a new string interpreting the //with_weekday//, //with_day// and //with_year// parameters
     * so that it can be used with formatting functions like {@link GLib.DateTime.format}.
     *
     * As the {@link Granite.DateTime.get_default_time_format}, the returned string is formatted, translated and is also mostly used to display
     * the date in various user interfaces like the date displayed in the top panel.
     *
     * @param with_weekday if the returned string should contain the abbreviated weekday name
     * @param with_day if the returned string should contain contain the day of the month as a decimal number (range 1 to 31)
     * @param with_year if the returned string should contain the year as a decimal number including the century
     *
     * @return returns the formatted and located date string. If for some reason, the function could not determine the format to use,
     *         an empty string will be returned.
     */
    public static string get_default_date_format (bool with_weekday = false, bool with_day = true, bool with_year = false) {
        if (with_weekday == true && with_day == true && with_year == true) {
            /// TRANSLATORS: a GLib.DateTime format showing the weekday, date, and year
            return _("%a %b %e %Y");
        } else if (with_weekday == false && with_day == true && with_year == true) {
            /// TRANSLATORS: a GLib.DateTime format showing the date and year
            return _("%b %e %Y");
        } else if (with_weekday == false && with_day == false && with_year == true) {
            /// TRANSLATORS: a GLib.DateTime format showing the year
            return _("%Y");
        } else if (with_weekday == false && with_day == true && with_year == false) {
            /// TRANSLATORS: a GLib.DateTime format showing the date
            return _("%b %e");
        } else if (with_weekday == true && with_day == false && with_year == true) {
            /// TRANSLATORS: a GLib.DateTime format showing the weekday and year.
            return _("%a %Y");
        } else if (with_weekday == true && with_day == false && with_year == false) {
            /// TRANSLATORS: a GLib.DateTime format showing the weekday
            return _("%a");
        } else if (with_weekday == true && with_day == true && with_year == false) {
            /// TRANSLATORS: a GLib.DateTime format showing the weekday and date
            return _("%a %b %e");
        } else if (with_weekday == false && with_day == false && with_year == false) {
            /// TRANSLATORS: a GLib.DateTime format showing the month.
            return _("%b");
        }

        return "";
    }
}
