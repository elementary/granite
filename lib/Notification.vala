/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public namespace NotificationCategory {
    /**
     * A received instant message notification
     */
     public const string IM_RECEIVED = "im.received";
}

public enum NotificationCategory {
    /**
     * A received instant message notification
     */
    IM_RECEIVED,

    public string to_string () {
        switch (this) {
            case IM_RECEIVED:
                return "im.received"
        }
    }
}


// // For alarm clock apps
// ALARM_RINGING = "alarm.ringing";
// // A audio or video call is incoming
// CALL_INCOMING = "call.incoming";
// // A audio or video call is ongoing.
// CALL_ONGOING = "call.ongoing";
// // An incoming audio or video call was not answered
// CALL_UNANSWERED = "call.unanswered";
// // Used to display an extreme weather warning.
// WEATHER_WARNING_EXTREME = "weather.warning.extreme";
// // A nationwide or presidential warnings broadcasted by the cell network
// CELLBROADCAST_DANGER_PRESIDENTIAL = "cellbroadcast.danger.presidential";
// // Used to display extreme danger warnings broadcasted by the cell network.
// CELLBROADCAST_DANGER.EXTREME = "cellbroadcast.danger.extreme";
// // Used to display severe danger warnings broadcasted by the cell network.
// CELLBROADCAST_DANGER.SEVERE = "cellbroadcast.danger.severe";
// // Used to display public safety warnings broadcasted by the cell network.
// CELLBROADCAST_PUBLIC-SAFETY = "cellbroadcast.public-safety";
// // Used to display amber alerts broadcasted by the cell network.
// CELLBROADCAST_AMBER-ALERT = "cellbroadcast.amber-alert";
// // Used to display tests broadcasted by the cell network.
// CELLBROADCAST_TEST = "cellbroadcast.test";
// // Used to indicate that the system is low on battery.
// OS_BATTERY_LOW = "os.battery.low";
// // Used by browsers to mark notifications sent by websites
// BROWSER_WEB_NOTIFICATION = "browser.web-notification"

