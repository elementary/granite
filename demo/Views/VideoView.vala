/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class VideoView : DemoPage {
    construct {
        title = "Video";

        var video = new Gtk.Video () {
            file = File.new_for_uri ("https://download.blender.org/peach/trailer/trailer_400p.ogg"),
            loop = true,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            overflow = HIDDEN
        };
        video.add_css_class (Granite.CssClass.CARD);

        child = video;
    }
}
