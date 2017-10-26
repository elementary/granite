/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * The Palette class is used to extract most dominant colors (so called swatches)
 * from an image.
 * 
 * The API itself is mostly similar and based on the original [[https://android.googlesource.com/platform/frameworks/support.git/+/master/v7/palette/src/main/java/android/support/v7/graphics/Palette.java|Android implementation.]] It uses the [[https://en.wikipedia.org/wiki/Median_cut|median cut algorithm]] to determine most dominant, vibrant or muted colors.
 */
public class Granite.Drawing.Palette : Object {
    const double TARGET_DARK_LUMA = 0.26;

    const double MAX_DARK_LUMA = 0.45;

    const double MIN_LIGHT_LUMA = 0.55;

    const double TARGET_LIGHT_LUMA = 0.74;

    const double MIN_NORMAL_LUMA = 0.3;

    const double TARGET_NORMAL_LUMA = 0.5;

    const double MAX_NORMAL_LUMA = 0.7;

    const double TARGET_MUTED_SATURATION = 0.3;

    const double MAX_MUTED_SATURATION = 0.4;

    const double TARGET_VIBRANT_SATURATION = 1;

    const double MIN_VIBRANT_SATURATION = 0.35;

    const double WEIGHT_SATURATION = 0.24;

    const double WEIGHT_LUMA = 0.52;

    const double WEIGHT_POPULATION = 0.24;

    public class Swatch : Granite.Drawing.Color {
        public int population { get; construct; }

        public Swatch (uint8 red, uint8 green, uint8 blue, int population) {
            Object (population: population);

            R = red / 255.0f;
            G = green / 255.0f;
            B = blue / 255.0f;
            A = 1.0f;
        }
    }

    // TODO: Get this API to the Granite.Drawing.Color itself
    private class Color : Object {
        public uint8 red { get; set; }
        public uint8 green { get; set; }
        public uint8 blue { get; set; }

        public Color.from_rgb (int rgb) {
            red = (uint8)((rgb >> 16) & 0xFF);
            green = (uint8)((rgb >> 8) & 0xFF);
            blue = (uint8)(rgb & 0xFF);
        }

        public Color (uint8 red, uint8 green, uint8 blue) {
            this.red = red;
            this.green = green;
            this.blue = blue;
        }

        public int to_rgb () {
            return (0xFF << 24) | (red << 16) | (green << 8) | blue;
        }

        public uint8 get_component (ColorComponent component) {
            switch (component) {
                case ColorComponent.RED:
                    return red;
                case ColorComponent.GREEN:
                    return green;
                case ColorComponent.BLUE:
                    return blue;
            }

            return 0;
        }
    }

    private Gee.List<Swatch> _swatches;
    public Gee.List<Swatch> swatches {
        owned get {
            return _swatches.read_only_view;
        }
    }

    public Swatch? vibrant_swatch { get; private set; }
    public Swatch? light_vibrant_swatch { get; private set; }
    public Swatch? dark_vibrant_swatch { get; private set; }
    public Swatch? muted_swatch { get; private set; }
    public Swatch? light_muted_swatch { get; private set; }
    public Swatch? dark_muted_swatch { get; private set; }

    public Swatch? dominant_swatch { get; private set; }
    public Swatch? title_swatch { get; private set; }
    public Swatch? body_swatch { get; private set; }

    private int max_population = 0;

    public Gdk.Pixbuf? pixbuf { get; construct; }
    public int max_depth { get; construct; }
    public int quality { get; construct; }

    private Gee.HashMap<int, int> histogram;
    private uint8[] pixel_data;
    private bool has_alpha;

    private enum ColorComponent {
        RED,
        GREEN,
        BLUE
    }

    construct {
        histogram = new Gee.HashMap<int, int> ();

        Gee.List<Color> pixels;
        if (pixbuf != null) {
            pixels = convert_pixels_to_rgb (pixbuf.get_pixels_with_length (), pixbuf.has_alpha);
        } else {
            pixels = convert_pixels_to_rgb (pixel_data, has_alpha);
        }

        _swatches = quantize (pixels, 0, max_depth);
        _swatches.sort ((c1, c2) => {
            return c2.population - c1.population;
        });

        if (_swatches.size > 0) {
            dominant_swatch = _swatches[0];
        }

        max_population = int.MIN;
        foreach (var swatch in _swatches) {
            if (swatch.population > max_population) {
                max_population = swatch.population;
            }
        }

        create_swatch_targets ();
    }

    public Palette.from_pixbuf (Gdk.Pixbuf pixbuf, int max_depth = 6, int quality = 5) {
        Object (pixbuf: pixbuf, max_depth: max_depth, quality: quality);
    }

    public Palette.from_data (owned uint8[] pixels, bool has_alpha, int max_depth = 6, int quality = 5) {
        this.pixel_data = pixels;
        this.has_alpha = has_alpha;
        Object (max_depth: max_depth, quality: quality);
    }

    private Palette () {

    }

    private Gee.ArrayList<Color> convert_pixels_to_rgb (uint8[] pixels, bool has_alpha) {
        var list = new Gee.ArrayList<Color> ();

        int factor;
        if (has_alpha) {
            factor = 4;
        } else {
            factor = 3;
        }

        int i = 0;
        int count = pixels.length / factor;
        while (i < count) {
            int offset = i * factor;
            uint8 red = pixels[offset];
            uint8 green = pixels[offset + 1];
            uint8 blue = pixels[offset + 2];
            
            var color = new Color (red, green, blue);
            int rgb = color.to_rgb ();
            if (histogram.has_key (rgb)) {
                histogram[rgb] = histogram[rgb] + 1;
            } else {
                histogram[rgb] = 1;
            }

            i += 5;
        }

        histogram.@foreach ((entry) => {
            var color = entry.key;
            list.add (new Color.from_rgb (color));
            return true;
        });

        return list;
    }


    private ColorComponent find_biggest_range (Gee.List<Color> pixels) {
        int r_min = int.MAX;
        int r_max = int.MIN;

        int g_min = int.MAX;
        int g_max = int.MIN;

        int b_min = int.MAX;
        int b_max = int.MIN;

        foreach (var pixel in pixels) {
            r_min = int.min (r_min, pixel.red);
            r_max = int.max (r_max, pixel.red);

            g_min = int.min (g_min, pixel.green);
            g_max = int.max (g_max, pixel.green);

            b_min = int.min (b_min, pixel.blue);
            b_max = int.max (b_max, pixel.blue);
        }

        int r_range = r_max - r_min;
        int g_range = g_max - g_min;
        int b_range = b_max - b_min;

        if (r_range >= g_range && r_range >= b_range) {
            return ColorComponent.RED;
        } else if (g_range >= r_range && g_range >= b_range) {
            return ColorComponent.GREEN;
        } else {
            return ColorComponent.BLUE;
        }
    }

    // TODO: Perhaps abstract this?
    private Gee.List<Swatch> quantize (Gee.List<Color> pixels, int depth = 0, int max_depth = 16) {
        if (depth == max_depth) {
            int r = 0, g = 0, b = 0;
            int population = 0;

            int red_sum = 0;
            int green_sum = 0;
            int blue_sum = 0;

            foreach (var pixel in pixels) {
                int color_pop = histogram[pixel.to_rgb ()];

                red_sum += color_pop * pixel.red;
                green_sum += color_pop * pixel.green;
                blue_sum += color_pop * pixel.blue;

                population += color_pop;
            }

            r = (int)Math.round (red_sum / (float)population);
            g = (int)Math.round (green_sum / (float)population);
            b = (int)Math.round (blue_sum / (float)population);

            var color = new Swatch ((uint8)r, (uint8)g, (uint8)b, population);
            
            var list = new Gee.ArrayList<Swatch> ();
            list.add (color);
            return list;
        }

        ColorComponent component = find_biggest_range (pixels);
        pixels.sort ((c1, c2) => {
            return c1.get_component (component) - c2.get_component (component);
        });

        int mid = pixels.size / 2;

        var first = quantize (pixels.slice (0, mid), depth + 1, max_depth);
        var second = quantize (pixels.slice (mid + 1, pixels.size - 1), depth + 1, max_depth);

        var swatches = new Gee.ArrayList<Swatch> ();
        swatches.add_all (first);
        swatches.add_all (second);

        return swatches;
    }

    private void create_swatch_targets () {
        vibrant_swatch = find_color_variation (TARGET_NORMAL_LUMA, MIN_NORMAL_LUMA, MAX_NORMAL_LUMA, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, 1);
        light_vibrant_swatch = find_color_variation (TARGET_LIGHT_LUMA, MIN_LIGHT_LUMA, 1, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, 1);
        dark_vibrant_swatch = find_color_variation (TARGET_DARK_LUMA, 0, MAX_DARK_LUMA, TARGET_VIBRANT_SATURATION, MIN_VIBRANT_SATURATION, 1);
        muted_swatch = find_color_variation (TARGET_NORMAL_LUMA, MIN_NORMAL_LUMA, MAX_NORMAL_LUMA, TARGET_MUTED_SATURATION, 0, MAX_MUTED_SATURATION);
        light_muted_swatch = find_color_variation (TARGET_LIGHT_LUMA, MIN_LIGHT_LUMA, 1, TARGET_MUTED_SATURATION, 0, MAX_MUTED_SATURATION);
        dark_muted_swatch = find_color_variation (TARGET_DARK_LUMA, 0, MAX_DARK_LUMA, TARGET_MUTED_SATURATION, 0, MAX_MUTED_SATURATION);

        if (dominant_swatch != null) {
            foreach (var swatch in _swatches) {
                bool aa_level, aaa_level;
                passes_wcag_guidelines (dominant_swatch, swatch, out aa_level, out aaa_level);
                if (aa_level && title_swatch == null) {
                    title_swatch = swatch;
                }

                if (aaa_level && body_swatch == null) {
                    body_swatch = swatch;
                }
            }

            // TODO: Be a little smarter here
            bool is_dark_color = is_dark_color (dominant_swatch);
            if (title_swatch == null) {
                if (is_dark_color) {
                    title_swatch = new Swatch (255, 255, 255, 0);
                } else {
                    title_swatch = new Swatch (0, 0, 0, 0);
                }
            }

            if (body_swatch == null) {
                if (is_dark_color) {
                    body_swatch = new Swatch (255, 255, 255, 0);
                } else {
                    body_swatch = new Swatch (0, 0, 0, 0);
                }
            }
        }
    }

    private static void passes_wcag_guidelines (Granite.Drawing.Color bg, Granite.Drawing.Color fg, out bool aa_level, out bool aaa_level) {
        var bg_luminance = get_luminance_wcag (bg);
        var fg_luminance = get_luminance_wcag (fg);

        double contrast_ratio;
        if (bg_luminance > fg_luminance) {
            contrast_ratio = (bg_luminance + 0.05) / (fg_luminance + 0.05);
        } else {
            contrast_ratio = (fg_luminance + 0.05) / (bg_luminance + 0.05);
        }

        if (contrast_ratio >= 4.5) {
            aa_level = true;
        } else {
            aa_level = false;
        }

        if (contrast_ratio >= 7) {
            aaa_level = true;
        } else {
            aaa_level = false;
        }
    }

    private static double get_luminance_wcag (Granite.Drawing.Color color) {
        var red = sanitize_color (color.R) * 0.2126;
        var green = sanitize_color (color.G) * 0.7152;
        var blue = sanitize_color (color.B) * 0.0722;

        return (red + green + blue);
    }

    private static double sanitize_color (double color) {
        if (color <= 0.03928) {
            color = color / 12.92;
        } else {
            color = Math.pow ((color + 0.055) / 1.055, 2.4);
        }
        return color;
    }

    // TODO: Use native Granite.Drawing.Color.get_sat
    private static double get_saturation (Granite.Drawing.Color color) {
        double max = double.MIN;
        if (color.R > color.G && color.R > color.B) {
            max = color.R;
        } else if (color.G > color.R && color.G > color.B) {
            max = color.G;
        } else {
            max = color.B;
        }

        double min = double.MAX;
        if (color.R < color.G && color.R < color.B) {
            min = color.R;
        } else if (color.G < color.R && color.G < color.B) {
            min = color.G;
        } else {
            min = color.B;
        }

        double s = 0;
        double l = (max + min) / 2;
        double chroma = max - min;
        if (chroma == 0) {
            s = 0;
        } else {
            if (l <= 0.5) {
                s = chroma / (2 * l);
            } else {
                s = chroma / (2 - 2 *l);
            }
        }

        return s;
    }

    private static double get_luminance (Granite.Drawing.Color color) {
        double max = double.MIN;
        if (color.R > color.G && color.R > color.B) {
            max = color.R;
        } else if (color.G > color.R && color.G > color.B) {
            max = color.G;
        } else {
            max = color.B;
        }

        double min = double.MAX;
        if (color.R < color.G && color.R < color.B) {
            min = color.R;
        } else if (color.G < color.R && color.G < color.B) {
            min = color.G;
        } else {
            min = color.B;
        }

        return (max + min) / 2;
    }

    private static bool is_dark_color (Granite.Drawing.Color color) {
        double lum = 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B;
        return lum < 0.5;
    }

    private Swatch? find_color_variation (double target_luma,
                                        double min_luma,
                                        double max_luma,
                                        double target_saturation,
                                        double min_saturation,
                                        double max_saturation) {
        Swatch? max = null;
        double max_value = double.MIN;
        foreach (var swatch in _swatches) {
            double sat = get_saturation (swatch);
            double luma = get_luminance (swatch);
            if (sat >= min_saturation && sat <= max_saturation && luma >= min_luma && luma <= max_luma && !is_already_selected_color (swatch)) {
                double value = create_comparasion_value (sat, target_saturation, luma, target_luma, swatch.population, max_population);
                if (max == null || value > max_value) {
                    max = swatch;
                    max_value = value;
                }
            }
        }

        return max;
    }

    private static double create_comparasion_value (double saturation,
                                            double target_saturation,
                                            double luma,
                                            double target_luma, 
                                            double population,
                                            double max_population) {
        double[6] vals = new double[6];
        vals[0] = invert_diff (saturation, target_saturation);
        vals[1] = WEIGHT_SATURATION;
        vals[2] = invert_diff (luma, target_luma);
        vals[3] = WEIGHT_LUMA;
        vals[4] = population / max_population;
        vals[5] = WEIGHT_POPULATION;

        return weighted_mean (vals);
    }

    private bool is_already_selected_color (Swatch swatch) {
        return swatch == vibrant_swatch || swatch == light_vibrant_swatch ||
            swatch == dark_vibrant_swatch || swatch == muted_swatch || swatch == light_muted_swatch || swatch == dark_muted_swatch;
    }

    private static double invert_diff (double value, double target_value) {
        return 1.0f - Math.fabs (value - target_value);
    }

    private static double weighted_mean (double[] values) {
        double satscore = values[0] * values[1];
        double lumscore = values[2] * values[3];
        double popscore = values[4] * values[5];

        return satscore + lumscore + popscore;
    }
}
