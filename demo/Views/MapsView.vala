/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class MapsView : DemoPage {
    construct {
        title = "Shumate.SimpleMap";

        var registry = new Shumate.MapSourceRegistry.with_defaults ();

        var simple_map = new Shumate.SimpleMap () {
            map_source = registry.get_by_id (Shumate.MAP_SOURCE_OSM_MAPNIK),
            overflow = HIDDEN,
            vexpand = true,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        simple_map.add_css_class (Granite.CssClass.CARD);

        var point = new Shumate.Marker () {
            child = new Gtk.Image.from_icon_name ("emblem-favorite-symbolic"),
            latitude = 38.580753,
            longitude = -121.487300
        };

        var marker_layer = new Shumate.MarkerLayer.full (simple_map.viewport, SINGLE);
        marker_layer.add_marker (point);

        var map_view = simple_map.viewport;
        map_view.zoom_level = 15;

        var map = simple_map.map;
        map.add_layer (marker_layer);
        map.center_on (38.575764, -121.478851);

        child = simple_map;
    }
}
