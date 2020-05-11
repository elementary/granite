/*
 *  Copyright (C) 2012-2017 elementary LLC. (https://elementary.io)
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

namespace Granite.StyleClass {
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_BADGE")]
    public const string BADGE = "badge";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_CATEGORY_EXPANDER")]
    public const string CATEGORY_EXPANDER = "category-expander";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string CONTENT_VIEW = "content-view";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string CONTENT_VIEW_WINDOW = "content-view-window";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string COMPOSITED = "composited";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string DECORATED_WINDOW = "decorated-window";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_H1_LABEL")]
    public const string H1_TEXT = "h1";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_H2_LABEL")]
    public const string H2_TEXT = "h2";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_H3_LABEL")]
    public const string H3_TEXT = "h3";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string HELP_BUTTON = "help_button";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_OVERLAY_BAR")]
    public const string OVERLAY_BAR = "overlay-bar";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Gtk.STYLE_CLASS_POPOVER")]
    public const string POPOVER = "popover";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string POPOVER_BG = "popover_bg";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Granite.STYLE_CLASS_SOURCE_LIST")]
    public const string SOURCE_LIST = "source-list";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
    public const string THIN_PANE_SEPARATOR = "sidebar-pane-separator";
    [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Gtk.STYLE_CLASS_TITLE")]
    public const string TITLE_TEXT = "title";
}

namespace Granite {
    /**
     * Style class to give accent color to a {@link Gtk.Label} or symbolic icon
     */
    public const string STYLE_CLASS_ACCENT = "accent";
    public const string STYLE_CLASS_AVATAR = "avatar";
    /**
     * Style class for shaping a {@link Gtk.Button}
     */
    public const string STYLE_CLASS_BACK_BUTTON = "back-button";
    /**
     * Style class for numbered badges as in a {@link Granite.Widgets.SourceList}
     */
    public const string STYLE_CLASS_BADGE = "badge";
    /**
     * Style class for adding a small shadow to a container such as for image thumbnails
     *
     * Can be combined with the style class ".collapsed" to further reduce the size of the shadow
     */
    public const string STYLE_CLASS_CARD = "card";
    public const string STYLE_CLASS_CATEGORY_EXPANDER = "category-expander";
    /**
     * Style class for checkered backgrounds to represent transparency in images
     */
    public const string STYLE_CLASS_CHECKERBOARD = "checkerboard";
        /**
     * Style class for color chooser buttons to be applied to {@link Gtk.CheckButton} or {@link Gtk.RadioButton}
     */
    public const string STYLE_CLASS_COLOR_BUTTON = "color-button";
    /**
     * Style class for large primary text as seen in {@link Granite.Widgets.Welcome}
     */
    public const string STYLE_CLASS_H1_LABEL = "h1";
    /**
     * Style class for large seondary text as seen in {@link Granite.Widgets.Welcome}
     */
    public const string STYLE_CLASS_H2_LABEL = "h2";
    /**
     * Style class for small primary text
     */
    public const string STYLE_CLASS_H3_LABEL = "h3";
    /**
     * Style class for a {@link Granite.HeaderLabel}
     */
    public const string STYLE_CLASS_H4_LABEL = "h4";
    /**
     * Style class for a {@link Gtk.Label} to be displayed as a keyboard key cap
     */
    public const string STYLE_CLASS_KEYCAP = "keycap";
    /**
     * Style class for a {@link Gtk.Switch} used to change between two modes rather than active and inactive states
     */
    public const string STYLE_CLASS_MODE_SWITCH = "mode-switch";
    /**
     * Style class for a {@link Granite.Widgets.OverlayBar}
     */
    public const string STYLE_CLASS_OVERLAY_BAR = "overlay-bar";
    /**
     * Style class for primary label text in a {@link Granite.MessageDialog}
     */
    public const string STYLE_CLASS_PRIMARY_LABEL = "primary";
    /**
     * Style class for rounded corners, i.e. on a {@link Gtk.Window} or {@link Granite.STYLE_CLASS_CARD}
     */
    public const string STYLE_CLASS_ROUNDED = "rounded";
    /**
     * Style class for a {@link Granite.SeekBar}
     */
    public const string STYLE_CLASS_SEEKBAR = "seek-bar";
    /**
     * Style class for a {@link Granite.Widgets.SourceList}
     */
    public const string STYLE_CLASS_SOURCE_LIST = "source-list";
    /**
     * Style class for a {@link Granite.Widgets.Granite.Widgets.StorageBar}
     */
    public const string STYLE_CLASS_STORAGEBAR = "storage-bar";
    /**
     * Style class for {@link Gtk.Label} or {@link Gtk.TextView} to emulate the appearance of Terminal. This includes
     * text color, background color, selection highlighting, and selecting the system monospace font.
     *
     * When used with {@link Gtk.Label} this style includes internal padding. When used with {@link Gtk.TextView}
     * interal padding will need to be set with {@link Gtk.Container.border_width}
     */
    public const string STYLE_CLASS_TERMINAL = "terminal";
    /**
     * Style class for a {@link Granite.Widgets.Welcome}
     */
    public const string STYLE_CLASS_WELCOME = "welcome";
}
