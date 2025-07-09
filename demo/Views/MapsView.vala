/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class MapsView : DemoPage {
    private string styles = "
        map-marker.self {
            background-color: @base_color;
            border-radius: 50%;
            box-shadow:
                0 0 0 1px @borders,
                0 3px 4px alpha(black, 0.15),
                0 3px 3px -3px alpha(black, 0.35);
            padding: 0.25rem;
        }

        map-marker.self grid {
            background: @accent_color;
            color: white;
            border-radius: 50%;
            min-height: 1rem;
            min-width: 1rem;
        }
    ";

    construct {
        title = "Shumate.SimpleMap";

        var style_provider = new Gtk.CssProvider ();
        style_provider.load_from_string (styles);

        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

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
            child = new Gtk.Image.from_icon_name ("map-marker") { pixel_size = 48 },
            latitude = 38.580753,
            longitude = -121.487300
        };

        var self_point = new Shumate.Marker () {
            child = new Gtk.Grid (),
            latitude = 38.575764,
            longitude = -121.478851
        };
        self_point.add_css_class ("self");

        var marker_layer = new Shumate.MarkerLayer.full (simple_map.viewport, SINGLE);
        marker_layer.add_marker (point);
        marker_layer.add_marker (self_point);

        var map_view = simple_map.viewport;
        map_view.zoom_level = 15;

        var map = simple_map.map;
        map.add_layer (marker_layer);
        map.center_on (self_point.latitude, self_point.longitude);

        child = simple_map;
    }
}
