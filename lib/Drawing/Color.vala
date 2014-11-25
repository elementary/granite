/*
 *  Copyright (C) 2011-2013 Robert Dyer
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
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
        public double R;
        /**
         * The value of the green channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double G;
        /**
         * The value of the blue channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double B;
        /**
         * The value of the alpha channel, with 0 being the lowest value and 1.0 being the greatest value.
         */
        public double A;
        
        /**
         * Constructs a new {@link Granite.Drawing.Color} with the supplied values.
         *
         * @param R the value of the red channel as a double
         * @param G the value of the green channel as a double
         * @param B the value of the blue channel as a double
         * @param A the value of the alpha channel as a double
         */
        public Color (double R, double G, double B, double A) {
        
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
        
        void rgb_to_hsv (double r, double g, double b, out double h, out double s, out double v)
            requires (r >= 0 && r <= 1)
            requires (g >= 0 && g <= 1)
            requires (b >= 0 && b <= 1)
        {
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
        
        void hsv_to_rgb (double h, double s, double v, out double r, out double g, out double b)
            requires (h >= 0 && h <= 360)
            requires (s >= 0 && s <= 1)
            requires (v >= 0 && v <= 1)
        {
            r = 0; 
            g = 0; 
            b = 0;

            if (s == 0) {
                r = v;
                g = v;
                b = v;
            } else {
                var secNum = (int) Math.floor (h / 60);
                var fracSec = h / 60.0 - secNum;

                var p = v * (1 - s);
                var q = v * (1 - s * fracSec);
                var t = v * (1 - s * (1 - fracSec));
                
                switch (secNum) {
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
            
            R = double.min (uint8.MAX, double.max (0, int.parse(parts [0]))) / uint8.MAX;
            G = double.min (uint8.MAX, double.max (0, int.parse(parts [1]))) / uint8.MAX;
            B = double.min (uint8.MAX, double.max (0, int.parse(parts [2]))) / uint8.MAX;
            A = double.min (uint8.MAX, double.max (0, int.parse(parts [3]))) / uint8.MAX;
        }
        
    }
    
}

