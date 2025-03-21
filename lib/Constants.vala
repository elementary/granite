/*
 * Copyright 2012-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    /**
     * Style class to give accent color to a {@link Gtk.Label} or symbolic icon
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.ACCENT")]
    public const string STYLE_CLASS_ACCENT = "accent";
    /**
     * Style class for shaping a {@link Gtk.Button}
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.BACK")]
    public const string STYLE_CLASS_BACK_BUTTON = "back-button";
    /**
     * Style class to match the window background
     */
    [Version (since = "7.1.0")]
    public const string STYLE_CLASS_BACKGROUND = "background";
    /**
     * Style class for numbered badges
     */
    public const string STYLE_CLASS_BADGE = "badge";
    /**
     * Style class for adding a small shadow to a container such as for image thumbnails
     *
     * Can be combined with the style class ".collapsed" to further reduce the size of the shadow
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.CARD")]
    public const string STYLE_CLASS_CARD = "card";
    /**
     * Style class for checkered backgrounds to represent transparency in images
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.CHECKERBOARD")]
    public const string STYLE_CLASS_CHECKERBOARD = "checkerboard";
    /**
     * Style class for a circular {@link Gtk.Button}
     */
    public const string STYLE_CLASS_CIRCULAR = "circular";
    /**
     * Style class for color chooser buttons to be applied to {@link Gtk.CheckButton} or {@link Gtk.RadioButton}
     */
    public const string STYLE_CLASS_COLOR_BUTTON = "color-button";
    /**
     * Style class for slim headerbars, like in Terminal
     */
    public const string STYLE_CLASS_DEFAULT_DECORATION = "default-decoration";
    /**
     * Style class for {@link Gtk.Button} with a destructive action
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.DESTRUCTIVE")]
    public const string STYLE_CLASS_DESTRUCTIVE_ACTION = "destructive-action";
    /**
     * Style class for the content area in dialogs.
     */
    public const string STYLE_CLASS_DIALOG_CONTENT_AREA = "dialog-content-area";
    /**
     * Style class for adding a border to {@link Gtk.ListBox}, {@link Gtk.InfoBar}, and others
     */
    [Version (since = "7.1.0")]
    public const string STYLE_CLASS_FRAME = "frame";
    /**
     * Style class for large primary text as seen in {@link Granite.Widgets.Welcome}
     */
    public const string STYLE_CLASS_H1_LABEL = "title-1";
    /**
     * Style class for large seondary text as seen in {@link Granite.Widgets.Welcome}
     */
    public const string STYLE_CLASS_H2_LABEL = "title-2";
    /**
     * Style class for small primary text
     */
    public const string STYLE_CLASS_H3_LABEL = "title-3";
    /**
     * Style class for a {@link Granite.HeaderLabel}
     */
    public const string STYLE_CLASS_H4_LABEL = "title-4";
    /**
     * Style class for a {@link Gtk.Label} to be displayed as a keyboard key cap
     */
    public const string STYLE_CLASS_KEYCAP = "keycap";
    /**
     * Style class for a {@link Gtk.Image} used to set a context-aware large icon size. By default this is 32px,
     * but in certain contexts it could be larger or smaller depending on the default assumed icon size.
     */
    public const string STYLE_CLASS_LARGE_ICONS = "large-icons";
    /**
     * Style class for a {@link Gtk.Switch} used to change between two modes rather than active and inactive states
     */
    public const string STYLE_CLASS_MODE_SWITCH = "mode-switch";
    /**
     * Style class for "on-screen display" widgets such as {@link Granite.Toast} and {@link Granite.OverlayBar}
     */
    public const string STYLE_CLASS_OSD = "osd";
    /**
     * Style class for rounded corners, i.e. on a {@link Gtk.Window} or {@link Granite.STYLE_CLASS_CARD}
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.CARD")]
    public const string STYLE_CLASS_ROUNDED = "rounded";
    /**
     * Style class defining a sidebar, such as the left side in a file chooser
     */
    [Version (since = "7.1.0")]
    public const string STYLE_CLASS_SIDEBAR = "sidebar";
    /**
     * Style class for a {@link Gtk.Label} to emulate Pango's "<small>" and "size='smaller'"
     */
    public const string STYLE_CLASS_SMALL_LABEL= "small-label";

    /**
     * Style class for widgets in success state.
     */
    [Version (since = "7.5.0", deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.SUCCESS")]
    public const string STYLE_CLASS_SUCCESS = "success";

    /**
     * Style class for {@link Gtk.Label} or {@link Gtk.TextView} to emulate the appearance of Terminal. This includes
     * text color, background color, selection highlighting, and selecting the system monospace font.
     *
     * When used with {@link Gtk.Label} this style includes internal padding. When used with {@link Gtk.TextView}
     * interal padding will need to be set with {@link Gtk.Container.border_width}
     */
    public const string STYLE_CLASS_TERMINAL = "terminal";
    /**
     * Style class for title label text in a {@link Granite.MessageDialog}
     */
    public const string STYLE_CLASS_TITLE_LABEL = "title";
    /**
     * Style class for a warmth scale, a {@link Gtk.Scale} with a "less warm" to "more warm" color gradient
     */
    public const string STYLE_CLASS_WARMTH = "warmth";
    /**
     * Style class for a temperature scale, a {@link Gtk.Scale} with a "cold" to "hot" color gradient
     */
    public const string STYLE_CLASS_TEMPERATURE = "temperature";
    /**
     * Style class for linked widgets, such as a box containing buttons belonging to the same control.
     */
    public const string STYLE_CLASS_LINKED = "linked";
    /**
     * Style class for {@link Gtk.Popover} which is used as a menu.
     */
    public const string STYLE_CLASS_MENU = "menu";
    /**
     * Style class for {@link Gtk.Popover} children which are used as menu items.
     */
    public const string STYLE_CLASS_MENUITEM = "menuitem";
    /**
     * Style class for dimmed labels.
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.DIM")]
    public const string STYLE_CLASS_DIM_LABEL = "dim-label";
    /**
     * Style class for widgets in error state.
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.ERROR")]
    public const string STYLE_CLASS_ERROR = "error";
    /**
     * Style class for flattened widgets, such as buttons,
     */
    public const string STYLE_CLASS_FLAT = "flat";
    /**
     * Style class for message dialogs.
     */
    public const string STYLE_CLASS_MESSAGE_DIALOG = "message";
    /**
     * Style class for setting standard row padding and row height in a {@link Gtk.ListBox}
     */
    [Version (since = "7.1.0")]
    public const string STYLE_CLASS_RICH_LIST = "rich-list";
    /**
     * Style class for when an action (usually a button) is the primary suggested action in a specific context.
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.SUGGESTED")]
    public const string STYLE_CLASS_SUGGESTED_ACTION = "suggested-action";
    /**
     * Style class for widgets which should use base color as their background
     */
    public const string STYLE_CLASS_VIEW = "view";
    /**
     * Style class for widgets in warning state.
     */
    [Version (deprecated = true, deprecated_since = "7.7.0", replacement = "Granite.CssClass.WARNING")]
    public const string STYLE_CLASS_WARNING = "warning";

    /**
     * Transition duration when a widget closes, hides a portion of its content, or exits the screen
     */
    public const int TRANSITION_DURATION_CLOSE = 200;

    /**
     * Transition duration when a widget transforms in-place, like when filtering content with a view switcher
     */
    public const int TRANSITION_DURATION_IN_PLACE = 100;

    /**
     * Transition duration when a widget opens, reveals more content, or enters the screen
     */
    public const int TRANSITION_DURATION_OPEN = 250;

    /**
     * CSS style classes to be used with {@link Gtk.Widget.add_css_class}
     */
    [Version (since = "7.7.0")]
    namespace CssClass {
        /**
         * Style class to give accent color to a {@link Gtk.Label} or symbolic icon
         */
        public const string ACCENT = "accent";

        /**
         * Style class for a {@link Gtk.Button} which is used to navigate backwards
         */
        public const string BACK = "back-button";

        /**
         * Style class for adding a small shadow to a container such as for image thumbnails
         */
        public const string CARD = "card";

        /**
         * Style class for checkered backgrounds to represent transparency in images
         */
        public const string CHECKERBOARD = "checkerboard";

        /**
         * Style class for {@link Gtk.Button} with a destructive action
         */
        public const string DESTRUCTIVE = "destructive";

        /**
         * Style class for dimmed labels and icons
         */
        public const string DIM = "dim-label";

        /**
         * Style class for widgets in error state.
         */
        public const string ERROR = "error";

        /**
         * sets font features to use tabular numbers. Equivalent of Pango's tnum property
         */
        public const string NUMERIC = "numeric";

        /**
         * Style class for when a {@link Gtk.Button} is the primary suggested action in a specific context.
         */
        public const string SUGGESTED = "suggested";

        /**
         * Style class for widgets in success state.
         */
        public const string SUCCESS = "success";

        /**
         * Style class for widgets in warning state.
         */
        public const string WARNING = "warning";
    }

    /**
     * Deep links to specific Settings pages.
     */
    namespace SettingsUri {

        /**
         * Link to open Security & Privacy → Location Services settings page
         */
        [Version (since = "7.3.0")]
        public const string LOCATION = "settings://privacy/location";

        /**
         * Link to open Online Accounts settings page
         */
        [Version (since = "7.3.0")]
        public const string ONLINE_ACCOUNTS = "settings://accounts/online";

        /**
         * Link to Network settings page
         */
        [Version (since = "7.3.0")]
        public const string NETWORK = "settings://network";

        /**
         * Link to open Applications → Permissions settings page
         */
        [Version (since = "7.3.0")]
        public const string PERMISSIONS = "settings://applications/permissions";

        /**
         * Link to open Notifications settings page
         */
        [Version (since = "7.3.0")]
        public const string NOTIFICATIONS = "settings://notifications";

        /**
         * Link to open Sound → Input settings page
         */
        [Version (since = "7.3.0")]
        public const string SOUND_INPUT = "settings://sound/input";

        /**
         * Link to open Keyboard → Shortcuts → Custom settings page
         */
        [Version (since = "7.3.0")]
        public const string SHORTCUTS = "settings://input/keyboard/shortcuts/custom";

    }
}
