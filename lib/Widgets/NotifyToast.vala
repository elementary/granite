/*
 * Copyright 2012–2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public enum Granite.NotifyToastPosition {
    TOP_LEFT,
    TOP_CENTER,
    TOP_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_CENTER,
    BOTTOM_RIGHT
}

public class Granite.NotifyToast : GLib.Object {
    public string title { get; set construct; }
    public NotifyToastPosition position { get; set; default = NotifyToastPosition.TOP_CENTER; }

    public NotifyToast (string title) {
        Object (title: title);
    }

    construct {

    }
}