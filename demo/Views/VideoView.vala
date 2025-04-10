/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class VideoView : DemoPage {
    construct {
        title = "Video";

// https://studio.blender.org/download-source/73/73d768aef999befe39cf31c75903e849/73d768aef999befe39cf31c75903e849.1080p.mp4
// https://download.blender.org/peach/trailer/trailer_400p.ogg
// https://studio.blender.org/download-source/75/75f9da14c75a29048774666126b6ebf5/75f9da14c75a29048774666126b6ebf5.1080p.mp4

        var video = new Gtk.Video () {
            file = File.new_for_uri ("https://studio.blender.org/download-source/75/75f9da14c75a29048774666126b6ebf5/75f9da14c75a29048774666126b6ebf5.1080p.mp4"),
            loop = true,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            overflow = HIDDEN
        };
        video.add_css_class (Granite.CssClass.CARD);

        content = video;
    }
}
