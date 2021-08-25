/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Robert Dyer
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

using Gdk;

using Granite.Services;

namespace Granite.Drawing {
    /**
     * A class containing an RGBA color and methods for more powerful color manipulation.
     */
    public class Color : GLib.Object, SettingsSerializable {
        /**
         * The value of the red channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double R; // vala-lint=naming-convention

        /**
         * The value of the green channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double G; // vala-lint=naming-convention

        /**
         * The value of the blue channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double B; // vala-lint=naming-convention

        /**
         * The value of the alpha channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double A; // vala-lint=naming-convention

        /**
         * Extracts the alpha value from the integer value
         * serialized by {@link Granite.Drawing.Color.to_int}.
         *
         * @return the alpha channel value as a uint8 ranging from 0 - 255.
         */
        public static uint8 alpha_from_int (int color) {
            return (uint8)((color >> 24) & 0xFF);
        }

        /**
         * Extracts the red value from the integer value
         * serialized by {@link Granite.Drawing.Color.to_int}.
         *
         * @return the red channel value as a uint8 ranging from 0 - 255.
         */
        public static uint8 red_from_int (int color) {
            return (uint8)((color >> 16) & 0xFF);
        }

        /**
         * Extracts the green value from the integer value
         * serialized by {@link Granite.Drawing.Color.to_int}.
         *
         * @return the green channel value as a uint8 ranging from 0 - 255.
         */
        public static uint8 green_from_int (int color) {
            return (uint8)((color >> 8) & 0xFF);
        }

        /**
         * Extracts the blue value from the integer value
         * serialized by {@link Granite.Drawing.Color.to_int}.
         *
         * @return the blue channel value as a uint8 ranging from 0 - 255.
         */
        public static uint8 blue_from_int (int color) {
            return (uint8)(color & 0xFF);
        }

        /**
         * Constructs a new {@link Granite.Drawing.Color} with the supplied values.
         *
         * @param R the value of the red channel as a double
         * @param G the value of the green channel as a double
         * @param B the value of the blue channel as a double
         * @param A the value of the alpha channel as a double
         */
        public Color (double R, double G, double B, double A) { // vala-lint=naming-convention
            this.R = R;
            this.G = G;
            this.B = B;
            this.A = A;
        }

        /**
         * Constructs a new {@link Granite.Drawing.Color} from a {@link Gdk.Color}.
         *
         * @param color the {@link Gdk.Color}
         */
        public Color.from_gdk (Gdk.Color color) {
            R = color.red / (double) uint16.MAX;
            G = color.green / (double) uint16.MAX;
            B = color.blue / (double) uint16.MAX;
            A = 1.0;
        }

        /**
         * Constructs a new {@link Granite.Drawing.Color} from a {@link Gdk.RGBA}.
         *
         * @param color the {@link Gdk.RGBA}
         */
        public Color.from_rgba (Gdk.RGBA color) {
            set_from_rgba (color);
        }

        /**
         * Constructs a new {@link Granite.Drawing.Color} from a string.
         *
         * The string can be either one of:
         *
         * * A standard name (Taken from the X11 rgb.txt file).
         * * A hexadecimal value in the form “#rgb”, “#rrggbb”, “#rrrgggbbb” or ”#rrrrggggbbbb”
         * * A RGB color in the form “rgb(r,g,b)” (In this case the color will have full opacity)
         * * A RGBA color in the form “rgba(r,g,b,a)”
         *
         * For more details on formatting and how this function works see {@link Gdk.RGBA.parse}
         *
         * @param color the string specifying the color
         */
        public Color.from_string (string color) {
            Gdk.RGBA rgba = Gdk.RGBA ();
            rgba.parse (color);
            set_from_rgba (rgba);
        }

        /**
         * Constructs a new {@link Granite.Drawing.Color} from an integer.
         *
         * This constructor should be used when deserializing the previously serialized
         * color by {@link Granite.Drawing.Color.to_int}.
         *
         * For more details on what format the color integer representation has, see {@link Granite.Drawing.Color.to_int}.
         *
         * If you would like to deserialize the A, R, G and B values from the integer without
         * creating a new instance of {@link Granite.Drawing.Color}, you can use the available
         * //*_from_int// static method collection such as {@link Granite.Drawing.Color.alpha_from_int}.
         *
         * @param color the integer specyfying the color
         */
        public Color.from_int (int color) {
            R = (double)red_from_int (color) / (double)uint8.MAX;
            G = (double)green_from_int (color) / (double)uint8.MAX;
            B = (double)blue_from_int (color) / (double)uint8.MAX;
            A = (double)alpha_from_int (color) / (double)uint8.MAX;
        }

        /**
         * Changes the hue of this color to the supplied one.
         *
         * @param hue the hue to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_hue (double hue) requires (hue >= 0 && hue <= 360) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            h = hue;
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes the saturation of this color to the supplied one.
         *
         * @param sat the saturation to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_sat (double sat) requires (sat >= 0 && sat <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            s = sat;
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes the value of this color to the supplied one.
         *
         * @param val the value to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_val (double val) requires (val >= 0 && val <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            v = val;
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes the value of the alpha channel.
         *
         * @param alpha the value of the alpha channel
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_alpha (double alpha) requires (alpha >= 0 && alpha <= 1) {
            A = alpha;
            return this;
        }

        /**
         * Get the value.
         * @return the hue of this color, as a double value
         */
        public double get_hue () {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            return h;
        }

        /**
         * Get the value.
         * @return the saturation of this color, as a double value
         */
        public double get_sat () {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            return s;
        }

        /**
         * Get the value.
         *
         * @return the value of this color, as a double value
         */
        public double get_val () {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            return v;
        }

        /**
         * Adds the supplied hue value to this color's hue value.
         *
         * @param val the hue to add to this color's hue
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color add_hue (double val) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            h = (((h + val) % 360) + 360) % 360;
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes this color's saturation to the supplied saturation, if it is greater than this color's saturation.
         *
         * @param sat the saturation to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_min_sat (double sat) requires (sat >= 0 && sat <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            s = double.max (s, sat);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes this color's value to the supplied value, if it is greater than this color's value.
         *
         * @param val the value to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_min_value (double val) requires (val >= 0 && val <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            v = double.max (v, val);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes this color's saturation to the supplied saturation, if it is smaller than this color's saturation.
         *
         * @param sat the hue to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_max_sat (double sat) requires (sat >= 0 && sat <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            s = double.min (s, sat);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Changes this color's value to the supplied value, if it is smaller than this color's value.
         *
         * @param val the value to change this color to
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color set_max_val (double val) requires (val >= 0 && val <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            v = double.min (v, val);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Multiplies this color's saturation by the supplied amount.
         *
         * @param amount the amount to multiply the saturation by
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color multiply_sat (double amount) requires (amount >= 0) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            s = double.min (1, s * amount);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Brightens this color's value by the supplied amount.
         *
         * @param amount the amount to brighten the value by
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color brighten_val (double amount) requires (amount >= 0 && amount <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            v = double.min (1, v + (1 - v) * amount);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Darkens this color's value by the supplied amount.
         *
         * @param amount the amount to darken the value by
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color darken_val (double amount) requires (amount >= 0 && amount <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            v = double.max (0, v - (1 - v) * amount);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        /**
         * Darkens this color's value by the supplied amount * color's saturation.
         *
         * @param amount the amount to darken the value by
         *
         * @return the new {@link Granite.Drawing.Color}
         */
        public Color darken_by_sat (double amount) requires (amount >= 0 && amount <= 1) {
            double h, s, v;
            rgb_to_hsv (R, G, B, out h, out s, out v);
            v = double.max (0, v - amount * s);
            hsv_to_rgb (h, s, v, out R, out G, out B);

            return this;
        }

        void rgb_to_hsv (
            double r, double g, double b, out double h, out double s, out double v
        ) requires (r >= 0 && r <= 1) requires (g >= 0 && g <= 1) requires (b >= 0 && b <= 1) {
            var min = double.min (r, double.min (g, b));
            var max = double.max (r, double.max (g, b));

            v = max;
            if (v == 0) {
                h = 0;
                s = 0;
                return;
            }

            // normalize value to 1
            r /= v;
            g /= v;
            b /= v;

            min = double.min (r, double.min (g, b));
            max = double.max (r, double.max (g, b));

            var delta = max - min;
            s = delta;
            if (s == 0) {
                h = 0;
                return;
            }

            // normalize saturation to 1
            r = (r - min) / delta;
            g = (g - min) / delta;
            b = (b - min) / delta;

            if (max == r) {
                h = 0 + 60 * (g - b);
                if (h < 0)
                    h += 360;
            } else if (max == g) {
                h = 120 + 60 * (b - r);
            } else {
                h = 240 + 60 * (r - g);
            }
        }

        void hsv_to_rgb (
            double h, double s, double v, out double r, out double g, out double b
        ) requires (h >= 0 && h <= 360) requires (s >= 0 && s <= 1) requires (v >= 0 && v <= 1) {
            r = 0;
            g = 0;
            b = 0;

            if (s == 0) {
                r = v;
                g = v;
                b = v;
            } else {
                var sec_num = (int) Math.floor (h / 60);
                var frac_sec = h / 60.0 - sec_num;

                var p = v * (1 - s);
                var q = v * (1 - s * frac_sec);
                var t = v * (1 - s * (1 - frac_sec));

                switch (sec_num) {
                case 0:
                    r = v;
                    g = t;
                    b = p;
                    break;
                case 1:
                    r = q;
                    g = v;
                    b = p;
                    break;
                case 2:
                    r = p;
                    g = v;
                    b = t;
                    break;
                case 3:
                    r = p;
                    g = q;
                    b = v;
                    break;
                case 4:
                    r = t;
                    g = p;
                    b = v;
                    break;
                case 5:
                    r = v;
                    g = p;
                    b = q;
                    break;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        public string settings_serialize () {
            return "%d;;%d;;%d;;%d".printf ((int) (R * uint8.MAX),
                (int) (G * uint8.MAX),
                (int) (B * uint8.MAX),
                (int) (A * uint8.MAX));
        }

        /**
         * {@inheritDoc}
         */
        public void settings_deserialize (string s) {
            var parts = s.split (";;");

            R = double.min (uint8.MAX, double.max (0, int.parse (parts [0]))) / uint8.MAX;
            G = double.min (uint8.MAX, double.max (0, int.parse (parts [1]))) / uint8.MAX;
            B = double.min (uint8.MAX, double.max (0, int.parse (parts [2]))) / uint8.MAX;
            A = double.min (uint8.MAX, double.max (0, int.parse (parts [3]))) / uint8.MAX;
        }

        /**
         * Returns a textual specification of this in the form `rgb (r, g, b)` or `rgba (r, g, b, a)`,
         * where “r”, “g”, “b” and “a” represent the red, green, blue and alpha values respectively.
         *
         * r, g, and b are represented as integers in the range 0 to 255, and a is represented as
         * floating point value in the range 0 to 1.
         *
         * Note: that this string representation may lose some precision, since r, g and b are represented
         * as 8-bit integers. If this is a concern, you should use a different representation.
         *
         * This returns the same string as a {@link Gdk.RGBA} would return in {@link Gdk.RGBA.to_string}
         *
         * @return the text string
         */
        public string to_string () {
            Gdk.RGBA rgba = {R, G, B, A};
            return rgba.to_string ();
        }

        /**
         * Converts this to a 32 bit integer.
         *
         * This function can be useful for serializing the color so that it can be stored
         * and retrieved easily with hash tables and lists.
         *
         * The returned integer will contain the four channels
         * that define the {@link Granite.Drawing.Color} class: alpha, red, green and blue.
         *
         * Each channel is represented by 8 bits.
         * The first 8 bits of the integer conatin the alpha channel while all other 24 bits represent
         * red, green and blue channels respectively.
         *
         * The format written as a string would look like this:
         *
         * //AAAAAAAA RRRRRRRR GGGGGGGG BBBBBBBB//
         *
         * where //A// is one bit of alpha chnnel, //R// of red channel, //G// of green channel and //B// of blue channel.
         *
         * @return a 32 bit integer representing this
         */
        public int to_int () {
            uint8 red = (uint8)(R * uint8.MAX);
            uint8 green = (uint8)(G * uint8.MAX);
            uint8 blue = (uint8)(B * uint8.MAX);
            uint8 alpha = (uint8)(A * uint8.MAX);

            return (alpha << 24) | (red << 16) | (green << 8) | blue;
        }

        private void set_from_rgba (Gdk.RGBA color) {
            R = color.red;
            G = color.green;
            B = color.blue;
            A = color.alpha;
        }
    }
}
