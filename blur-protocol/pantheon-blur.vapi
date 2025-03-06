/*
 * Copyright 2025 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace PantheonBlur {
    [CCode (cheader_filename = "pantheon-blur-client-protocol.h", cname = "struct io_elementary_pantheon_blur_manager_v1", cprefix = "io_elementary_pantheon_blur_manager_v1_")]
    public class BlurManager : Wl.Proxy {
        [CCode (cheader_filename = "pantheon-blur-client-protocol.h", cname = "io_elementary_pantheon_blur_manager_v1_interface")]
        public static Wl.Interface iface;
        public void set_user_data (void* user_data);
        public void* get_user_data ();
        public uint32 get_version ();
        public void destroy ();
        public PantheonBlur.Blur get_blur (Wl.Surface surface);

    }

    [CCode (cheader_filename = "pantheon-blur-client-protocol.h", cname = "struct io_elementary_pantheon_blur_v1", cprefix = "io_elementary_pantheon_blur_v1_")]
    public class Blur : Wl.Proxy {
        [CCode (cheader_filename = "pantheon-blur-client-protocol.h", cname = "io_elementary_pantheon_blur_v1_interface")]
        public static Wl.Interface iface;
        public void set_user_data (void* user_data);
        public void* get_user_data ();
        public uint32 get_version ();
        public void destroy ();
        public void set_region (uint x, uint y, uint width, uint height, uint clip_radius);
    }
}
