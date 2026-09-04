/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

[Version (since = "9.0.0")]
public enum Granite.NotificationButtonPurpose {
    /**
     * Accept the incoming call
     */
    CALL_ACCEPT,

    /**
     * Decline the incoming call
     */
    CALL_DECLINE,

    /**
     * Hang up the ongoing call
     */
    CALL_HANG_UP;

    public string to_string () {
        switch (this) {
            case CALL_ACCEPT:
                return "call.accept";
            case CALL_DECLINE:
                return "call.accept";
            case CALL_HANG_UP:
                return "call.accept";
            default:
                return "";
        }
    }
}

[Version (since = "9.0.0")]
public enum Granite.NotificationCategory {
    /**
     * A received instant message notification
     */
    IM_RECEIVED,

    /**
     * For alarm clock apps
     */
    ALARM_RINGING,

    /**
     * A audio or video call is incoming
     */
    CALL_INCOMING,

    /**
     * A audio or video call is ongoing
     */
    CALL_ONGOING,

    /**
     * An incoming audio or video call was not answered
     */
    CALL_UNANSWERED,

    /**
     * Used to display an extreme weather warning
     */
    WEATHER_WARNING_EXTREME,

    /**
     * Used by browsers to mark notifications sent by websites
     */
    BROWSER_WEB_NOTIFICATION;

    public string to_string () {
        switch (this) {
            case IM_RECEIVED:
                return "im.received";
            case ALARM_RINGING:
                return "alarm.ringing";
            case CALL_INCOMING:
                return "call.incoming";
            case CALL_ONGOING:
                return "call.ongoing";
            case CALL_UNANSWERED:
                return "call.unanswered";
            case WEATHER_WARNING_EXTREME:
                return "weather.warning.extreme";
            case BROWSER_WEB_NOTIFICATION:
                return "browser.web-notification";
            default:
                return "";
        }
    }
}

[Flags]
[Version (since = "9.0.0")]
public enum Granite.NotificationDisplayFlags {
    /**
     * The notification is displayed only as a bubble and won’t be kept in the Notifications menu.
     *
     * It’s a programmer error to specify SILENT at the same time.
     */
    TRANSIENT,

    /**
     * No bubble for the notification will be displayed and the notification is placed directly in the Notifications menu
     *
     * It’s a programmer error to specify TRANSIENT at the same time
     */
    SILENT,

    /**
     * Make the notification persistent in the Notifications menu. It cannot be dismissed with a gesture or close button.
     *
     * Will be automatically cleared when the app is no longer running
     */
    ACTIVITY,

    /**
     * Don’t show the notification on the lock screen.
     */
    HIDE_ON_LOCK_SCREEN,

    /**
     * All content of the notification will be hidden on the lock screen.
     */
    HIDE_CONTENT_ON_LOCK_SCREEN,

    /**
     * If a notification with the same id exists already, close the old notification bubble and send a new bubble.
     *
     * If this hint isn’t specified the notification bubble’s content is replaced with an animation
     */
    SHOW_AS_NEW;

    public string[] to_array () {
        string[] array = { };
        if (TRANSIENT in this) {
            array += "transient";
        }

        if (SILENT in this) {
            array += "tray";
        }

        if (ACTIVITY in this) {
            array += "persistent";
        }

        if (HIDE_ON_LOCK_SCREEN in this) {
            array += "hide-on-lock-screen";
        }

        if (HIDE_CONTENT_ON_LOCK_SCREEN in this) {
            array += "hide-content-on-lock-screen";
        }

        if (SHOW_AS_NEW in this) {
            array += "show-as-new";
        }

        return array;
    }
}

[Version (since = "9.0.0")]
public enum Granite.NotificationPriority {
    /**
     * Used for contextual background information or confirmations such as contact birthdays or started background tasks
     *
     * Are automatically cleared from Notifications menu after 24 hours
     */
    LOW,

    /**
     * The default priority used for the majority of notications. For example, new messages or completed background tasks
     */
    NORMAL,

    /**
     * For events that require immediate action. For example, accepting phone calls or silencing alarms
     *
     * Bubbles do not automatically expire, but are automatically cleared from Notifications menu after 24 hours
     */
    TIME_SENSITIVE,

    /**
     * For events that require immediate attention such as imminent danger to this device, or threats to public safety
     *
     * Ignore Do Not Disturb.
     * Play a louder sound and have an exaggerated visual effect.
     * Bubbles do not automatically expire, but are automatically cleared from Notifications menu after 24 hours
     */
     EMERGENCY;

    public string to_string () {
        switch (this) {
            case LOW:
                return "low";
            case NORMAL:
                return "normal";
            case TIME_SENSITIVE:
                return "high";
            case EMERGENCY:
                return "urgent";
            default:
                return "";
        }
    }
}
