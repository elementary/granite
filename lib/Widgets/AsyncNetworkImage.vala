/*
* Copyright (c) 2017 Haris Sulaiman, Nathan  <harisvsulaiman@gmail.com>
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

namespace App.Widgets {

    public errordomain CacheError {
        CANNOT_LOAD
    }

    public class AsyncNetworkImage : Granite.AsyncImage {
        public string url { get ; construct; }
        public int width { get; construct; }     
        public int height { get; construct; }
        public bool preserve_aspect_ratio { get; construct; }

        private int scale;

        public AsyncNetworkImage (string url, int width, int height, bool preserve_aspect_ratio = true){
            Object (url: url ,
                    width: width, 
                    height: height, 
                    preserve_aspect_ratio: preserve_aspect_ratio,
                    halign: Gtk.Align.CENTER,
                    valign: Gtk.Align.CENTER
                );
        }

        construct {
            scale = get_style_context ().get_scale ();
            height_request = height;
            width_request = width;

            get_style_context ().set_scale (1);
            load_from_url(url);
        }

        public async void load_from_url(string url){
            var cache = ImageCache.instance;
            yield set_from_icon_name_async ("image-loading", Gtk.IconSize.DIALOG);    /// add some placeholder image
            try {
                var file = yield cache.get_image (url, width, height);
                yield set_from_file_async (file, height * scale, width * scale, preserve_aspect_ratio);       
            } catch (Error error) {
                yield set_from_icon_name_async ("image-missing", Gtk.IconSize.DIALOG);   /// add some error image
            }
        }

        public class ImageCache : GLib.Object {
            private const string CACHE_DIR = "~/.cache/splosh";
            private const string USER_AGENT = "splosh 1.0.0";
            private static ImageCache imageCache = null;

            private class CacheState {
                public signal void load_complete();
                public bool is_loaded;
            }

            public static ImageCache instance {
                get {
                    if (imageCache == null) {
                        imageCache = new ImageCache();
                    }
                    return imageCache;
                }
            }
        
            private static DiskCacher cacher;
            private static Gee.HashMap<string, File> cache;
            private static Soup.Session soup_session;
            private static CacheState state;
        
            static construct {
                // till the cache get initialized
                state = new CacheState();
                state.is_loaded = false;
                cache = new Gee.HashMap<string, File>();
        
                var home_dir = GLib.Environment.get_home_dir();
                var cache_directory = CACHE_DIR.replace("~", home_dir);
        
                soup_session = new Soup.Session();
                soup_session.user_agent = USER_AGENT;
                cacher = new DiskCacher(cache_directory);
                cacher.get_cached_files.begin((obj, res) => {
                    cache = cacher.get_cached_files.end(res);
                    state.is_loaded = true;
                    state.load_complete();
                });
            }
        
            private ImageCache() { 
            }
        
            // Get image and cache it
            public async GLib.File get_image(string url, int width, int height) throws CacheError, Error  {
                string url_hash = url.hash().to_string () + "-" + width.to_string () + "*" + height.to_string ();
                GLib.File file;
        
                if (!state.is_loaded) {
                    state.load_complete.connect(() => { get_image.callback(); });
                    yield;
                }
        
                if (cache.has_key(url_hash) && cache.@get(url_hash) != null) {
                    file = cache.@get(url_hash);
                    if (file == null) {
                        throw new CacheError.CANNOT_LOAD ("Could not load cached file");
                        warning("Could not load cached file");
                    }
                } else {
                    var pixbuf = yield load_image_async(url);
                    if (pixbuf != null) {
                        file = yield cacher.cache_file(url_hash, pixbuf);
                        cache.@set(url_hash, file);
                    }else {
                        return null;
                    }
                }
        
                return file;
            }
        
            private async Gdk.Pixbuf load_image_async(string url) throws Error {
                Gdk.Pixbuf pixbuf = null;
                Soup.Request req = soup_session.request(url);
                InputStream image_stream = req.send(null);
                pixbuf = yield new Gdk.Pixbuf.from_stream_async(image_stream, null);
                return pixbuf;
            }
        
            private class DiskCacher {
                private File cache_location;
                private string location;
        
                public DiskCacher(string location) {
                    this.location = location;
                    this.cache_location = File.new_for_path(location);
                }
        
                public async Gee.HashMap<string, File> get_cached_files() {
                    Gee.HashMap<string, File> files = new Gee.HashMap<string, File>();
        
                    if (!cache_location.query_exists()) {
                        cache_location.make_directory_with_parents();
                    }
        
                    try {
                        FileEnumerator enumerator = yield
                            cache_location.enumerate_children_async("standard::*",
                                                                    FileQueryInfoFlags.NONE,
                                                                    Priority.DEFAULT, null);
                        List<FileInfo> infos;
                        while((infos = yield enumerator.next_files_async(10)) != null) {
                            foreach(var info in infos) {
                                var name = info.get_name();
                                var file = File.new_for_path("%s/%s".printf (location, name));
                                var hashed_name = (uint) uint64.parse (name);
                                files.@set(hashed_name.to_string (), file);
                            }
                        }
                    } catch (Error e) {
                        warning("Could not load cached images " + e.message);
                    }
                    return files;
                }
        
                public async File cache_file(string hashed_name, Gdk.Pixbuf pixbuf) {
                    var file_loc = "%s/%s.png".printf(this.location, hashed_name);
                    var cfile = File.new_for_path(file_loc);
        
                    FileIOStream fiostream;
                    if (cfile.query_exists()) {
                        fiostream = yield cfile.replace_readwrite_async(null, false, FileCreateFlags.NONE);
                    } else {
                        fiostream = yield cfile.create_readwrite_async(FileCreateFlags.NONE);
                    }
                    // switch to async version later, currently the bindings have a bug
                    pixbuf.save_to_stream(fiostream.get_output_stream(), "png");
        
                    return cfile;
                }
        
                public async Gdk.Pixbuf get_cached_file(File file) {
                    Gdk.Pixbuf pixbuf = null;
                    try {
                        var fiostream = yield file.open_readwrite_async();
                        pixbuf = yield new Gdk.Pixbuf.from_stream_async(fiostream.get_input_stream(), null);
                    } catch(Error e) {
                        warning ("Couldn't write to file. " + e.message);
                    }
                    return pixbuf;
                }
            }
        }  
    }
}
