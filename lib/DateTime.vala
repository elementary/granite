/*
 * Copyright 2012-2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
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
                return _("%-l:%M:%S %p");
            } else {
                /// TRANSLATORS: a GLib.DateTime format showing the hour (12h format)
                return _("%-l:%M %p");
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
     * Compares a {@link GLib.DateTime} to {@link GLib.DateTime.now_local} and returns a location, relative date and
     * time string. Results appear as natural-language strings like "Now", "5m ago", "Yesterday"
     *
     * @param date_time a {@link GLib.DateTime} to compare against {@link GLib.DateTime.now_local}
     *
     * @return a localized, relative date and time string
     */
    public static string get_relative_datetime (GLib.DateTime date_time) {
        var now = new GLib.DateTime.now_local ();
        var diff = now.difference (date_time);

        if (is_same_day (date_time, now)) {
            if (diff > 0) {
                if (diff < TimeSpan.MINUTE) {
                    return _("Now");
                } else if (diff < TimeSpan.HOUR) {
                    var minutes = diff / TimeSpan.MINUTE;
                    return dngettext (GETTEXT_PACKAGE, "%dm ago", "%dm ago", (ulong) (minutes)).printf ((int) (minutes));
                } else if (diff < 12 * TimeSpan.HOUR) {
                    int rounded = (int) Math.round ((double) diff / TimeSpan.HOUR);
                    return dngettext (GETTEXT_PACKAGE, "%dh ago", "%dh ago", (ulong) rounded).printf (rounded);
                }
            } else {
                diff = -1 * diff;
                if (diff < TimeSpan.HOUR) {
                    var minutes = diff / TimeSpan.MINUTE;
                    return dngettext (GETTEXT_PACKAGE, "in %dm", "in %dm", (ulong) (minutes)).printf ((int) (minutes));
                } else if (diff < 12 * TimeSpan.HOUR) {
                    int rounded = (int) Math.round ((double) diff / TimeSpan.HOUR);
                    return dngettext (GETTEXT_PACKAGE, "in %dh", "in %dh", (ulong) rounded).printf (rounded);
                }
            }

            return date_time.format (get_default_time_format (is_clock_format_12h (), false));
        } else if (is_same_day (date_time.add_days (1), now)) {
            return _("Yesterday");
        } else if (is_same_day (date_time.add_days (-1), now)) {
            return _("Tomorrow");
        } else if (diff < 6 * TimeSpan.DAY && diff > -6 * TimeSpan.DAY) {
            return date_time.format (get_default_date_format (true, false, false));
        } else if (date_time.get_year () == now.get_year ()) {
            return date_time.format (get_default_date_format (false, true, false));
        } else {
            return date_time.format ("%x");
        }
    }

    /**
     * Gets the //clock-format// key from //org.gnome.desktop.interface// schema
     * and determines if the clock format is 12h based
     *
     * @return true if the clock format is 12h based, false otherwise.
     */
    private static bool is_clock_format_12h () {
        string format = null;
        try {
            var portal = Portal.Settings.get ();
            var variant = portal.read ("org.gnome.desktop.interface", "clock-format").get_variant ();
            format = variant.get_string ();
        } catch (Error e) {
            debug ("cannot use portal, using GSettings: %s", e.message);
        }

        if (format == null) {
            var h24_settings = new GLib.Settings ("org.gnome.desktop.interface");
            format = h24_settings.get_string ("clock-format");
        }

        return (format.contains ("12h"));
    }

    /**
     * Compare two {@link GLib.DateTime} and return true if they occur on the same day of the same year
     *
     * @param day1 a {@link GLib.DateTime} to compare against day2
     * @param day2 a {@link GLib.DateTime} to compare against day1
     *
     * @return true if day1 and day2 occur on the same day of the same year. False otherwise
     */
    public static bool is_same_day (GLib.DateTime day1, GLib.DateTime day2) {
        return day1.get_day_of_year () == day2.get_day_of_year () && day1.get_year () == day2.get_year ();
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
            return _("%a, %b %e, %Y");
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
            return _("%a, %b %e");
        } else if (with_weekday == false && with_day == false && with_year == false) {
            /// TRANSLATORS: a GLib.DateTime format showing the month.
            return _("%b");
        }

        return "";
    }

    /**
     * Converts seconds into the ISO 8601 standard date format for minutes (e.g. 100s to 01:40).
     * Output of negative seconds is prepended with minus character.
     *
     * @param seconds the number of seconds to convert into ISO 8601
     *
     * @return returns an ISO 8601 formatted string
     */
    public static string seconds_to_time (int seconds) {
        int sign = 1;
        if (seconds < 0) {
            seconds = -seconds;
            sign = -1;
        }

        int hours = seconds / 3600;
        int min = (seconds % 3600) / 60;
        int sec = (seconds % 60);

        if (hours > 0) {
            return ("%d:%02d:%02d".printf (sign * hours, min, sec));
        } else {
            return ("%02d:%02d".printf (sign * min, sec));
        }
    }
}
