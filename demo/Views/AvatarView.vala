/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class AvatarView : DemoPage {
    construct {
        title = "Avatar";

        var frame_avatar = new Granite.Avatar ("Jane Doe") {
            has_frame = true,
            pixel_size = 64
        };

        var color_box = new Granite.Box (HORIZONTAL);

            // Granite.AccentColor.BLUE,
            // Granite.AccentColor.TEAL,
            // Granite.AccentColor.GREEN,
            // Granite.AccentColor.YELLOW,
            // Granite.AccentColor.ORANGE,
            // Granite.AccentColor.RED,
            // Granite.AccentColor.PINK,
            // Granite.AccentColor.PURPLE,
            // Granite.AccentColor.BROWN,
            // Granite.AccentColor.GRAY,
            // Granite.AccentColor.LATTE,

        string[] names = {
            "",
            "Helen Elliott",
            "Mary Bradshaw",
            "",
            "Ruth Atkins",
            "Gladys Lyons",
            "",
            "Emma Prince",
            "Edna Campbell",
            "Anna Chavez",
            ""
        };
        foreach (unowned var name in names) {
            color_box.append (new Granite.Avatar (name));
        }

        var box = new Granite.Box (VERTICAL, DOUBLE) {
            halign = CENTER,
            valign = CENTER
        };
        box.append (frame_avatar);
        box.append (color_box);

        child = box;
    }
}
