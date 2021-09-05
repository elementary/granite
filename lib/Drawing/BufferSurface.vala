/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 * Copyright 2011-2013 Robert Dyer
 * Copyright 2011-2013 Rico Tzschichholz <ricotz@ubuntu.com>
 * SPDX-License-Identifier: LGPL-3.0-or-later
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
                if (_surface == null) {
                    _surface = new ImageSurface (Format.ARGB32, width, height);
                }

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
                if (_context == null) {
                    _context = new Cairo.Context (surface);
                }

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
            var b_total = 0.0;
            var g_total = 0.0;
            var r_total = 0.0;

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

                b_total += b * score;
                g_total += g * score;
                r_total += r * score;

                data += 4;
            }

            return new Drawing.Color (
                r_total / uint8.MAX / length,
                g_total / uint8.MAX / length,
                b_total / uint8.MAX / length,
                1
            ).set_val (0.8).multiply_sat (1.15);
        }

        /**
         * Performs a blur operation on the internal {@link Cairo.Surface}, using the
         * fast-blur algorithm found here [[http://incubator.quasimondo.com/processing/superfastblur.pde]].
         *
         * @param radius the blur radius
         * @param process_count the number of times to perform the operation
         */
        public void fast_blur (int radius, int process_count = 1) {
            if (radius < 1 || process_count < 1) {
                return;
            }

            var w = width;
            var h = height;
            var channels = 4;

            if (radius > w - 1 || radius > h - 1) {
                return;
            }

            var original = new ImageSurface (Format.ARGB32, w, h);
            var cr = new Cairo.Context (original);

            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();

            uint8 *pixels = original.get_data ();
            var buffer = new uint8[w * h * channels];

            var v_min = new int[int.max (w, h)];
            var v_max = new int[int.max (w, h)];

            var div = 2 * radius + 1;
            var dv = new uint8[256 * div];

            for (var i = 0; i < dv.length; i++) {
                dv[i] = (uint8) (i / div);
            }

            while (process_count-- > 0) {
                for (var x = 0; x < w; x++) {
                    v_min[x] = int.min (x + radius + 1, w - 1);
                    v_max[x] = int.max (x - radius, 0);
                }

                for (var y = 0; y < h; y++) {
                    var a_sum = 0, r_sum = 0, g_sum = 0, b_sum = 0;

                    uint32 cur_pixel = y * w * channels;

                    a_sum += radius * pixels[cur_pixel + 0];
                    r_sum += radius * pixels[cur_pixel + 1];
                    g_sum += radius * pixels[cur_pixel + 2];
                    b_sum += radius * pixels[cur_pixel + 3];

                    for (var i = 0; i <= radius; i++) {
                        a_sum += pixels[cur_pixel + 0];
                        r_sum += pixels[cur_pixel + 1];
                        g_sum += pixels[cur_pixel + 2];
                        b_sum += pixels[cur_pixel + 3];

                        cur_pixel += channels;
                    }

                    cur_pixel = y * w * channels;

                    for (var x = 0; x < w; x++) {
                        uint32 p1 = (y * w + v_min[x]) * channels;
                        uint32 p2 = (y * w + v_max[x]) * channels;

                        buffer[cur_pixel + 0] = dv[a_sum];
                        buffer[cur_pixel + 1] = dv[r_sum];
                        buffer[cur_pixel + 2] = dv[g_sum];
                        buffer[cur_pixel + 3] = dv[b_sum];

                        a_sum += pixels[p1 + 0] - pixels[p2 + 0];
                        r_sum += pixels[p1 + 1] - pixels[p2 + 1];
                        g_sum += pixels[p1 + 2] - pixels[p2 + 2];
                        b_sum += pixels[p1 + 3] - pixels[p2 + 3];

                        cur_pixel += channels;
                    }
                }

                for (var y = 0; y < h; y++) {
                    v_min[y] = int.min (y + radius + 1, h - 1) * w;
                    v_max[y] = int.max (y - radius, 0) * w;
                }

                for (var x = 0; x < w; x++) {
                    var a_sum = 0, r_sum = 0, g_sum = 0, b_sum = 0;

                    uint32 cur_pixel = x * channels;

                    a_sum += radius * buffer[cur_pixel + 0];
                    r_sum += radius * buffer[cur_pixel + 1];
                    g_sum += radius * buffer[cur_pixel + 2];
                    b_sum += radius * buffer[cur_pixel + 3];

                    for (var i = 0; i <= radius; i++) {
                        a_sum += buffer[cur_pixel + 0];
                        r_sum += buffer[cur_pixel + 1];
                        g_sum += buffer[cur_pixel + 2];
                        b_sum += buffer[cur_pixel + 3];

                        cur_pixel += w * channels;
                    }

                    cur_pixel = x * channels;

                    for (var y = 0; y < h; y++) {
                        uint32 p1 = (x + v_min[y]) * channels;
                        uint32 p2 = (x + v_max[y]) * channels;

                        pixels[cur_pixel + 0] = dv[a_sum];
                        pixels[cur_pixel + 1] = dv[r_sum];
                        pixels[cur_pixel + 2] = dv[g_sum];
                        pixels[cur_pixel + 3] = dv[b_sum];

                        a_sum += buffer[p1 + 0] - buffer[p2 + 0];
                        r_sum += buffer[p1 + 1] - buffer[p2 + 1];
                        g_sum += buffer[p1 + 2] - buffer[p2 + 2];
                        b_sum += buffer[p1 + 3] - buffer[p2 + 3];

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

        const int ALPHA_PRECISION = 16;
        const int PARAM_PRECISION = 7;

        /**
         * Performs a blur operation on the internal {@link Cairo.Surface}, using an
         * exponential blurring algorithm. This method is usually the fastest
         * and produces good-looking results (though not quite as good as gaussian's).
         *
         * @param radius the blur radius
         */
        public void exponential_blur (int radius) {
            if (radius < 1) {
                return;
            }

            var alpha = (int) ((1 << ALPHA_PRECISION) * (1.0 - Math.exp (-2.3 / (radius + 1.0))));
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

        void exponential_blur_columns (
            uint8* pixels,
            int width,
            int height,
            int start_col,
            int end_col,
            int start_y,
            int end_y,
            int alpha
        ) {
            for (var column_index = start_col; column_index < end_col; column_index++) {
                // blur columns
                uint8 *column = pixels + column_index * 4;

                var z_alpha = column[0] << PARAM_PRECISION;
                var z_red = column[1] << PARAM_PRECISION;
                var z_green = column[2] << PARAM_PRECISION;
                var z_blue = column[3] << PARAM_PRECISION;

                // Top to Bottom
                for (var index = width * (start_y + 1); index < (end_y - 1) * width; index += width) {
                    exponential_blur_inner (&column[index * 4], ref z_alpha, ref z_red, ref z_green, ref z_blue, alpha);
                }

                // Bottom to Top
                for (var index = (end_y - 2) * width; index >= start_y; index -= width) {
                    exponential_blur_inner (&column[index * 4], ref z_alpha, ref z_red, ref z_green, ref z_blue, alpha);
                }
            }
        }

        void exponential_blur_rows (
            uint8* pixels,
            int width,
            int height,
            int start_row,
            int end_row,
            int start_x,
            int end_x,
            int alpha
        ) {
            for (var row_index = start_row; row_index < end_row; row_index++) {
                // Get a pointer to our current row
                uint8* row = pixels + row_index * width * 4;

                var z_alpha = row[start_x + 0] << PARAM_PRECISION;
                var z_red = row[start_x + 1] << PARAM_PRECISION;
                var z_green = row[start_x + 2] << PARAM_PRECISION;
                var z_blue = row[start_x + 3] << PARAM_PRECISION;

                // Left to Right
                for (var index = start_x + 1; index < end_x; index++)
                    exponential_blur_inner (&row[index * 4], ref z_alpha, ref z_red, ref z_green, ref z_blue, alpha);

                // Right to Left
                for (var index = end_x - 2; index >= start_x; index--)
                    exponential_blur_inner (&row[index * 4], ref z_alpha, ref z_red, ref z_green, ref z_blue, alpha);
            }
        }

        private static inline void exponential_blur_inner (
            uint8* pixel,
            ref int z_alpha,
            ref int z_red,
            ref int z_green,
            ref int z_blue,
            int alpha
        ) {
            z_alpha += (alpha * ((pixel[0] << PARAM_PRECISION) - z_alpha)) >> ALPHA_PRECISION;
            z_red += (alpha * ((pixel[1] << PARAM_PRECISION) - z_red)) >> ALPHA_PRECISION;
            z_green += (alpha * ((pixel[2] << PARAM_PRECISION) - z_green)) >> ALPHA_PRECISION;
            z_blue += (alpha * ((pixel[3] << PARAM_PRECISION) - z_blue)) >> ALPHA_PRECISION;

            pixel[0] = (uint8) (z_alpha >> PARAM_PRECISION);
            pixel[1] = (uint8) (z_red >> PARAM_PRECISION);
            pixel[2] = (uint8) (z_green >> PARAM_PRECISION);
            pixel[3] = (uint8) (z_blue >> PARAM_PRECISION);
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
            var gauss_width = radius * 2 + 1;
            var kernel = build_gaussian_kernel (gauss_width);

            var width = this.width;
            var height = this.height;

            var original = new ImageSurface (Format.ARGB32, width, height);
            var cr = new Cairo.Context (original);

            cr.set_operator (Operator.SOURCE);
            cr.set_source_surface (surface, 0, 0);
            cr.paint ();

            uint8 *src = original.get_data ();

            var size = height * original.get_stride ();

            var buffer_a = new double[size];
            var buffer_b = new double[size];

            // Copy image to double[] for faster horizontal pass
            for (var i = 0; i < size; i++) {
                buffer_a[i] = (double) src[i];
            }

            // Precompute horizontal shifts
            var shiftar = new int[int.max (width, height), gauss_width];
            for (var x = 0; x < width; x++)
                for (var k = 0; k < gauss_width; k++) {
                    var shift = k - radius;
                    if (x + shift <= 0 || x + shift >= width)
                        shiftar[x, k] = 0;
                    else
                        shiftar[x, k] = shift * 4;
                }

            try {
                // Horizontal Pass
                var th = new Thread<void*>.try (null, () => {
                    gaussian_blur_horizontal (
                        buffer_a,
                        buffer_b,
                        kernel,
                        gauss_width,
                        width,
                        height,
                        0,
                        height / 2,
                        shiftar
                    );
                    return null;
                });

                gaussian_blur_horizontal (
                    buffer_a,
                    buffer_b,
                    kernel,
                    gauss_width,
                    width,
                    height,
                    height / 2,
                    height,
                    shiftar
                );
                th.join ();

                // Clear buffer
                memset (buffer_a, 0, sizeof (double) * size);

                // Precompute vertical shifts
                shiftar = new int[int.max (width, height), gauss_width];
                for (var y = 0; y < height; y++)
                    for (var k = 0; k < gauss_width; k++) {
                        var shift = k - radius;
                        if (y + shift <= 0 || y + shift >= height)
                            shiftar[y, k] = 0;
                        else
                            shiftar[y, k] = shift * width * 4;
                    }

                // Vertical Pass
                var th2 = new Thread<void*>.try (null, () => {
                    gaussian_blur_vertical (
                        buffer_b,
                        buffer_a,
                        kernel,
                        gauss_width,
                        width,
                        height,
                        0,
                        width / 2,
                        shiftar
                    );
                    return null;
                });

                gaussian_blur_vertical (
                    buffer_b,
                    buffer_a,
                    kernel,
                    gauss_width,
                    width,
                    height,
                    width / 2,
                    width,
                    shiftar
                );
                th2.join ();
            } catch (Error err) {
                message (err.message);
            }

            // Save blurred image to original uint8[]
            for (var i = 0; i < size; i++) {
                src[i] = (uint8) buffer_a[i];
            }

            original.mark_dirty ();

            context.set_operator (Operator.SOURCE);
            context.set_source_surface (original, 0, 0);
            context.paint ();
            context.set_operator (Operator.OVER);
        }

        void gaussian_blur_horizontal (
            double* src,
            double* dest,
            double* kernel,
            int gauss_width,
            int width,
            int height,
            int start_row,
            int end_row,
            int[,] shift
        ) {
            uint32 cur_pixel = start_row * width * 4;

            for (var y = start_row; y < end_row; y++) {
                for (var x = 0; x < width; x++) {
                    for (var k = 0; k < gauss_width; k++) {
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

        void gaussian_blur_vertical (
            double* src,
            double* dest,
            double* kernel,
            int gauss_width,
            int width,
            int height,
            int start_col,
            int end_col,
            int[,] shift
        ) {
            uint32 cur_pixel = start_col * 4;

            for (var y = 0; y < height; y++) {
                for (var x = start_col; x < end_col; x++) {
                    for (var k = 0; k < gauss_width; k++) {
                        var source = cur_pixel + shift[y, k];

                        dest[cur_pixel + 0] += src[source + 0] * kernel[k];
                        dest[cur_pixel + 1] += src[source + 1] * kernel[k];
                        dest[cur_pixel + 2] += src[source + 2] * kernel[k];
                        dest[cur_pixel + 3] += src[source + 3] * kernel[k];
                    }

                    cur_pixel += 4;
                }
                cur_pixel += (width - end_col + start_col) * 4;
            }
        }

        static double[] build_gaussian_kernel (int gauss_width) requires (gauss_width % 2 == 1) {
            var kernel = new double[gauss_width];

            // Maximum value of curve
            var sd = 255.0;

            // width of curve
            var range = gauss_width;

            // Average value of curve
            var mean = range / sd;

            for (var i = 0; i < gauss_width / 2 + 1; i++) {
                kernel[gauss_width - i - 1] = kernel[i] = Math.pow (
                    Math.sin (((i + 1) * (Math.PI / 2) - mean) / range), 2
                ) * sd;
            }

            // normalize the values
            var gauss_sum = 0.0;

            foreach (var d in kernel) {
                gauss_sum += d;
            }

            for (var i = 0; i < kernel.length; i++) {
                kernel[i] = kernel[i] / gauss_sum;
            }

            return kernel;
        }
    }
}
