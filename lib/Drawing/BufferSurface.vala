/*
 *  Copyright (C) 2011-2013 Robert Dyer,
 *                          Rico Tzschichholz <ricotz@ubuntu.com>
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

using Cairo;
using Posix;

namespace Granite.Drawing {

    /**
     * A buffer containing an internal Cairo-usable surface and context, designed
     * for usage with large, rarely updated draw operations.
     */
    public class BufferSurface : GLib.Object {
    
        private Surface _surface;
        /**
         * The {@link Cairo.Surface} which will store the results of all drawing operations
         * made with {@link Granite.Drawing.BufferSurface.context}.
         */
        public Surface surface {
            get {
                if (_surface == null)
                    _surface = new ImageSurface (Format.ARGB32, width, height);
                return _surface;
            }
            private set { _surface = value; }
        }
        
        /**
         * The width of the {@link Granite.Drawing.BufferSurface}, in pixels.
         */
        public int width { get; private set; }
        /**
         * The height of the BufferSurface, in pixels.
         */
        public int height { get; private set; }
        
        private Context _context;
        /**
         * The {@link Cairo.Context} for the internal surface. All drawing operations done on this
         * {@link Granite.Drawing.BufferSurface} should use this context.
         */
        public Cairo.Context context {
            get {
                if (_context == null)
                    _context = new Cairo.Context (surface);
                return _context;
            }
        }
        
        /**
         * Constructs a new, empty {@link Granite.Drawing.BufferSurface} with the supplied dimensions.
         *
         * @param width the width of {@link Granite.Drawing.BufferSurface}, in pixels
         * @param height the height of the {@link Granite.Drawing.BufferSurface}, in pixels
         */
        public BufferSurface (int width, int height) requires (width >= 0 && height >= 0) {
        
            this.width = width;
            this.height = height;
        }

        /**
         * Constructs a new, empty {@link Granite.Drawing.BufferSurface} with the supplied dimensions, using
         * the supplied {@link Cairo.Surface} as a model.
         *
         * @param width the width of the new {@link Granite.Drawing.BufferSurface}, in pixels
         * @param height the height of the new {@link Granite.Drawing.BufferSurface}, in pixels
         * @param model the {@link Cairo.Surface} to use as a model for the internal {@link Cairo.Surface}
         */
        public BufferSurface.with_surface (int width, int height, Surface model) requires (model != null) {
        
            this (width, height);
            surface = new Surface.similar (model, Content.COLOR_ALPHA, width, height);
        }

        /**
         * Constructs a new, empty {@link Granite.Drawing.BufferSurface} with the supplied dimensions, using
         * the supplied {@link Granite.Drawing.BufferSurface} as a model.
         *
         * @param width the width of the new {@link Granite.Drawing.BufferSurface}, in pixels
         * @param height the height of the new {@link Granite.Drawing.BufferSurface}, in pixels
         * @param model the {@link Granite.Drawing.BufferSurface} to use as a model for the internal {@link Cairo.Surface}
         */
        public BufferSurface.with_buffer_surface (int width, int height, BufferSurface model) requires (model != null) {
        
            this (width, height);
            surface = new Surface.similar (model.surface, Content.COLOR_ALPHA, width, height);
        }
        
        /**
         * Clears the internal {@link Cairo.Surface}, making all pixels fully transparent.
         */
        public void clear () {
        
            context.save ();
            
            _context.set_source_rgba (0, 0, 0, 0);
            _context.set_operator (Operator.SOURCE);
            _context.paint ();
            
            _context.restore ();
        }
        
        /**
         * Creates a {@link Gdk.Pixbuf} from internal {@link Cairo.Surface}.
         *
         * @return the {@link Gdk.Pixbuf}
         */
        public Gdk.Pixbuf load_to_pixbuf () {
        
            var image_surface = new ImageSurface (Format.ARGB32, width, height);
            var cr = new Cairo.Context (image_surface);
            
            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();
            
            var width = image_surface.get_width ();
            var height = image_surface.get_height ();

            var pb = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, width, height);
            pb.fill (0x00000000);
            
            uint8 *data = image_surface.get_data ();
            uint8 *pixels = pb.get_pixels ();
            var length = width * height;
            
            if (image_surface.get_format () == Format.ARGB32) {
                for (var i = 0; i < length; i++) {
                    // if alpha is 0 set nothing
                    if (data[3] > 0) {
                        pixels[0] = (uint8) (data[2] * 255 / data[3]);
                        pixels[1] = (uint8) (data[1] * 255 / data[3]);
                        pixels[2] = (uint8) (data[0] * 255 / data[3]);
                        pixels[3] = data[3];
                    }
        
                    pixels += 4;
                    data += 4;
                }
            } else if (image_surface.get_format () == Format.RGB24) {
                for (var i = 0; i < length; i++) {
                    pixels[0] = data[2];
                    pixels[1] = data[1];
                    pixels[2] = data[0];
                    pixels[3] = data[3];
        
                    pixels += 4;
                    data += 4;
                }
            }
            
            return pb;
        }
        
        /**
         * Averages all the colors in the internal {@link Cairo.Surface}.
         *
         * @return the {@link Granite.Drawing.Color} with the averaged color
         */
        public Drawing.Color average_color () {
        
            var bTotal = 0.0;
            var gTotal = 0.0;
            var rTotal = 0.0;
            
            var w = width;
            var h = height;
            
            var original = new ImageSurface (Format.ARGB32, w, h);
            var cr = new Cairo.Context (original);
            
            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();
            
            uint8 *data = original.get_data ();
            var length = w * h;
            
            for (var i = 0; i < length; i++) {
                uint8 b = data [0];
                uint8 g = data [1];
                uint8 r = data [2];
                
                uint8 max = (uint8) double.max (r, double.max (g, b));
                uint8 min = (uint8) double.min (r, double.min (g, b));
                double delta = max - min;
                
                var sat = delta == 0 ? 0.0 : delta / max;
                var score = 0.2 + 0.8 * sat;
                
                bTotal += b * score;
                gTotal += g * score;
                rTotal += r * score;
                
                data += 4;
            }
            
            return new Drawing.Color (rTotal / uint8.MAX / length,
                             gTotal / uint8.MAX / length,
                             bTotal / uint8.MAX / length,
                             1).set_val (0.8).multiply_sat (1.15);
        }

        /**
         * Performs a blur operation on the internal {@link Cairo.Surface}, using the
         * fast-blur algorithm found here [[http://incubator.quasimondo.com/processing/superfastblur.pde]].
         *
         * @param radius the blur radius
         * @param process_count the number of times to perform the operation
         */
        public void fast_blur (int radius, int process_count = 1) {
        
            if (radius < 1 || process_count < 1)
                return;
            
            var w = width;
            var h = height;
            var channels = 4;
            
            if (radius > w - 1 || radius > h - 1)
                return;
            
            var original = new ImageSurface (Format.ARGB32, w, h);
            var cr = new Cairo.Context (original);
            
            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();
            
            uint8 *pixels = original.get_data ();
            var buffer = new uint8[w * h * channels];
            
            var vmin = new int[int.max (w, h)];
            var vmax = new int[int.max (w, h)];
            
            var div = 2 * radius + 1;
            var dv = new uint8[256 * div];
            for (var i = 0; i < dv.length; i++)
                dv[i] = (uint8) (i / div);
            
            while (process_count-- > 0) {
                for (var x = 0; x < w; x++) {
                    vmin[x] = int.min (x + radius + 1, w - 1);
                    vmax[x] = int.max (x - radius, 0);
                }
                
                for (var y = 0; y < h; y++) {
                    var asum = 0, rsum = 0, gsum = 0, bsum = 0;
                    
                    uint32 cur_pixel = y * w * channels;
                                        
                    asum += radius * pixels[cur_pixel + 0];
                    rsum += radius * pixels[cur_pixel + 1];
                    gsum += radius * pixels[cur_pixel + 2];
                    bsum += radius * pixels[cur_pixel + 3];
                    
                    for (var i = 0; i <= radius; i++) {
                        asum += pixels[cur_pixel + 0];
                        rsum += pixels[cur_pixel + 1];
                        gsum += pixels[cur_pixel + 2];
                        bsum += pixels[cur_pixel + 3];
                        
                        cur_pixel += channels;
                    }
                    
                    cur_pixel = y * w * channels;
                                        
                    for (var x = 0; x < w; x++) {
                        uint32 p1 = (y * w + vmin[x]) * channels;
                        uint32 p2 = (y * w + vmax[x]) * channels;
                        
                        buffer[cur_pixel + 0] = dv[asum];
                        buffer[cur_pixel + 1] = dv[rsum];
                        buffer[cur_pixel + 2] = dv[gsum];
                        buffer[cur_pixel + 3] = dv[bsum];
                        
                        asum += pixels[p1 + 0] - pixels[p2 + 0];
                        rsum += pixels[p1 + 1] - pixels[p2 + 1];
                        gsum += pixels[p1 + 2] - pixels[p2 + 2];
                        bsum += pixels[p1 + 3] - pixels[p2 + 3];
                        
                        cur_pixel += channels;
                    }
                }
                
                for (var y = 0; y < h; y++) {
                    vmin[y] = int.min (y + radius + 1, h - 1) * w;
                    vmax[y] = int.max (y - radius, 0) * w;
                }
                
                for (var x = 0; x < w; x++) {
                    var asum = 0, rsum = 0, gsum = 0, bsum = 0;
                    
                    uint32 cur_pixel = x * channels;
                    
                    asum += radius * buffer[cur_pixel + 0];
                    rsum += radius * buffer[cur_pixel + 1];
                    gsum += radius * buffer[cur_pixel + 2];
                    bsum += radius * buffer[cur_pixel + 3];
                    
                    for (var i = 0; i <= radius; i++) {
                        asum += buffer[cur_pixel + 0];
                        rsum += buffer[cur_pixel + 1];
                        gsum += buffer[cur_pixel + 2];
                        bsum += buffer[cur_pixel + 3];
                        
                        cur_pixel += w * channels;
                    }
                    
                    cur_pixel = x * channels;
                    
                    for (var y = 0; y < h; y++) {
                        uint32 p1 = (x + vmin[y]) * channels;
                        uint32 p2 = (x + vmax[y]) * channels;
                        
                        pixels[cur_pixel + 0] = dv[asum];
                        pixels[cur_pixel + 1] = dv[rsum];
                        pixels[cur_pixel + 2] = dv[gsum];
                        pixels[cur_pixel + 3] = dv[bsum];
                        
                        asum += buffer[p1 + 0] - buffer[p2 + 0];
                        rsum += buffer[p1 + 1] - buffer[p2 + 1];
                        gsum += buffer[p1 + 2] - buffer[p2 + 2];
                        bsum += buffer[p1 + 3] - buffer[p2 + 3];
                        
                        cur_pixel += w * channels;
                    }
                }
            }
            
            original.mark_dirty ();
            
            context.set_operator (Operator.SOURCE);
            context.set_source_surface (original, 0, 0);
            context.paint ();
            context.set_operator (Operator.OVER);
        }
        
        const int AlphaPrecision = 16;
        const int ParamPrecision = 7;
        
        /**
         * Performs a blur operation on the internal {@link Cairo.Surface}, using an
         * exponential blurring algorithm. This method is usually the fastest
         * and produces good-looking results (though not quite as good as gaussian's).
         *
         * @param radius the blur radius
         */
        public void exponential_blur (int radius) {
        
            if (radius < 1)
                return;
            
            var alpha = (int) ((1 << AlphaPrecision) * (1.0 - Math.exp (-2.3 / (radius + 1.0))));
            var height = this.height;
            var width = this.width;
            
            var original = new ImageSurface (Format.ARGB32, width, height);
            var cr = new Cairo.Context (original);
            
            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();
            
            uint8 *pixels = original.get_data ();
            
            try {
                // Process Rows
                var th = new Thread<void*>.try (null, () => {
                    exponential_blur_rows (pixels, width, height, 0, height / 2, 0, width, alpha);
                    return null;
                });

                exponential_blur_rows (pixels, width, height, height / 2, height, 0, width, alpha);
                th.join ();
                
                // Process Columns
                var th2 = new Thread<void*>.try (null, () => {
                    exponential_blur_columns (pixels, width, height, 0, width / 2, 0, height, alpha);
                    return null;
                });

                exponential_blur_columns (pixels, width, height, width / 2, width, 0, height, alpha);
                th2.join ();
            } catch (Error err) {
                warning (err.message);
            }
            
            original.mark_dirty ();
            
            context.set_operator (Operator.SOURCE);
            context.set_source_surface (original, 0, 0);
            context.paint ();
            context.set_operator (Operator.OVER);
        }
        
        void exponential_blur_columns (uint8* pixels, int width, int height, int startCol, int endCol, int startY, int endY, int alpha) {
        
            for (var columnIndex = startCol; columnIndex < endCol; columnIndex++) {
                // blur columns
                uint8 *column = pixels + columnIndex * 4;
                
                var zA = column[0] << ParamPrecision;
                var zR = column[1] << ParamPrecision;
                var zG = column[2] << ParamPrecision;
                var zB = column[3] << ParamPrecision;
                
                // Top to Bottom
                for (var index = width * (startY + 1); index < (endY - 1) * width; index += width)
                    exponential_blur_inner (&column[index * 4], ref zA, ref zR, ref zG, ref zB, alpha);
                
                // Bottom to Top
                for (var index = (endY - 2) * width; index >= startY; index -= width)
                    exponential_blur_inner (&column[index * 4], ref zA, ref zR, ref zG, ref zB, alpha);
            }
        }
        
        void exponential_blur_rows (uint8* pixels, int width, int height, int startRow, int endRow, int startX, int endX, int alpha) {
        
            for (var rowIndex = startRow; rowIndex < endRow; rowIndex++) {
                // Get a pointer to our current row
                uint8* row = pixels + rowIndex * width * 4;
                
                var zA = row[startX + 0] << ParamPrecision;
                var zR = row[startX + 1] << ParamPrecision;
                var zG = row[startX + 2] << ParamPrecision;
                var zB = row[startX + 3] << ParamPrecision;
                
                // Left to Right
                for (var index = startX + 1; index < endX; index++)
                    exponential_blur_inner (&row[index * 4], ref zA, ref zR, ref zG, ref zB, alpha);
                
                // Right to Left
                for (var index = endX - 2; index >= startX; index--)
                    exponential_blur_inner (&row[index * 4], ref zA, ref zR, ref zG, ref zB, alpha);
            }
        }
        
        private static inline void exponential_blur_inner (uint8* pixel, ref int zA, ref int zR, ref int zG, ref int zB, int alpha) {
        
            zA += (alpha * ((pixel[0] << ParamPrecision) - zA)) >> AlphaPrecision;
            zR += (alpha * ((pixel[1] << ParamPrecision) - zR)) >> AlphaPrecision;
            zG += (alpha * ((pixel[2] << ParamPrecision) - zG)) >> AlphaPrecision;
            zB += (alpha * ((pixel[3] << ParamPrecision) - zB)) >> AlphaPrecision;
            
            pixel[0] = (uint8) (zA >> ParamPrecision);
            pixel[1] = (uint8) (zR >> ParamPrecision);
            pixel[2] = (uint8) (zG >> ParamPrecision);
            pixel[3] = (uint8) (zB >> ParamPrecision);
        }
        
        /**
         * Performs a blur operation on the internal {@link Cairo.Surface}, using a
         * gaussian blurring algorithm. This method is very slow, albeit producing
         * debatably the best-looking results, and in most cases developers should
         * use the exponential blurring algorithm instead.
         *
         * @param radius the blur radius
         */
        public void gaussian_blur (int radius) {
        
            var gausswidth = radius * 2 + 1;
            var kernel = build_gaussian_kernel (gausswidth);
            
            var width = this.width;
            var height = this.height;
            
            var original = new ImageSurface (Format.ARGB32, width, height);
            var cr = new Cairo.Context (original);
            
            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();
            
            uint8 *src = original.get_data ();
            
            var size = height * original.get_stride ();
            
            var abuffer = new double[size];
            var bbuffer = new double[size];
            
            // Copy image to double[] for faster horizontal pass
            for (var i = 0; i < size; i++)
                abuffer[i] = (double) src[i];
            
            // Precompute horizontal shifts
            var shiftar = new int[int.max (width, height), gausswidth];
            for (var x = 0; x < width; x++)
                for (var k = 0; k < gausswidth; k++) {
                    var shift = k - radius;
                    if (x + shift <= 0 || x + shift >= width)
                        shiftar[x, k] = 0;
                    else
                        shiftar[x, k] = shift * 4;
                }
            
            try {
                // Horizontal Pass
                var th = new Thread<void*>.try (null, () => {
                    gaussian_blur_horizontal (abuffer, bbuffer, kernel, gausswidth, width, height, 0, height / 2, shiftar);
                    return null;
                });

                gaussian_blur_horizontal (abuffer, bbuffer, kernel, gausswidth, width, height, height / 2, height, shiftar);
                th.join ();
                
                // Clear buffer
                memset (abuffer, 0, sizeof(double) * size);
                
                // Precompute vertical shifts
                shiftar = new int[int.max (width, height), gausswidth];
                for (var y = 0; y < height; y++)
                    for (var k = 0; k < gausswidth; k++) {
                        var shift = k - radius;
                        if (y + shift <= 0 || y + shift >= height)
                            shiftar[y, k] = 0;
                        else
                            shiftar[y, k] = shift * width * 4;
                    }
                
                // Vertical Pass
                var th2 = new Thread<void*>.try (null, () => {
                    gaussian_blur_vertical (bbuffer, abuffer, kernel, gausswidth, width, height, 0, width / 2, shiftar);
                    return null;
                });

                gaussian_blur_vertical (bbuffer, abuffer, kernel, gausswidth, width, height, width / 2, width, shiftar);
                th2.join ();
            } catch (Error err) {
                message (err.message);
            }
            
            // Save blurred image to original uint8[]
            for (var i = 0; i < size; i++)
                src[i] = (uint8) abuffer[i];
            
            original.mark_dirty ();
            
            context.set_operator (Operator.SOURCE);
            context.set_source_surface (original, 0, 0);
            context.paint ();
            context.set_operator (Operator.OVER);
        }

        void gaussian_blur_horizontal (double* src, double* dest, double* kernel, int gausswidth, int width, int height, int startRow, int endRow, int[,] shift) {
        
            uint32 cur_pixel = startRow * width * 4;
            
            for (var y = startRow; y < endRow; y++) {
                for (var x = 0; x < width; x++) {
                    for (var k = 0; k < gausswidth; k++) {
                        var source = cur_pixel + shift[x, k];
                        
                        dest[cur_pixel + 0] += src[source + 0] * kernel[k];
                        dest[cur_pixel + 1] += src[source + 1] * kernel[k];
                        dest[cur_pixel + 2] += src[source + 2] * kernel[k];
                        dest[cur_pixel + 3] += src[source + 3] * kernel[k];
                    }
                    
                    cur_pixel += 4;
                }
            }
        }
        
        void gaussian_blur_vertical (double* src, double* dest, double* kernel, int gausswidth, int width, int height, int startCol, int endCol, int[,] shift) {
        
            uint32 cur_pixel = startCol * 4;
            
            for (var y = 0; y < height; y++) {
                for (var x = startCol; x < endCol; x++) {
                    for (var k = 0; k < gausswidth; k++) {
                        var source = cur_pixel + shift[y, k];
                        
                        dest[cur_pixel + 0] += src[source + 0] * kernel[k];
                        dest[cur_pixel + 1] += src[source + 1] * kernel[k];
                        dest[cur_pixel + 2] += src[source + 2] * kernel[k];
                        dest[cur_pixel + 3] += src[source + 3] * kernel[k];
                    }
                    
                    cur_pixel += 4;
                }
                cur_pixel += (width - endCol + startCol) * 4;
            }
        }
        
        static double[] build_gaussian_kernel (int gausswidth) requires (gausswidth % 2 == 1) {
            
            var kernel = new double[gausswidth];
            
            // Maximum value of curve
            var sd = 255.0;
            
            // width of curve
            var range = gausswidth;
            
            // Average value of curve
            var mean = range / sd;
            
            for (var i = 0; i < gausswidth / 2 + 1; i++)
                kernel[gausswidth - i - 1] = kernel[i] = Math.pow (Math.sin (((i + 1) * (Math.PI / 2) - mean) / range), 2) * sd;
            
            // normalize the values
            var gaussSum = 0.0;
            foreach (var d in kernel)            
                gaussSum += d;
            
            for (var i = 0; i < kernel.length; i++)
                kernel[i] = kernel[i] / gaussSum;
            
            return kernel;
        }
        
    }
    
}

