/*
 * Copyright 2012-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
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
     * Style class for color chooser buttons to be applied to {@link Gtk.CheckButton} or {@link Gtk.RadioButton}
     */
    public const string STYLE_CLASS_COLOR_BUTTON = "color-button";
    /**
     * Style class for slim headerbars, like in Terminal
     */
    public const string STYLE_CLASS_DEFAULT_DECORATION = "default-decoration";
    /**
     * Style class for a {@link Gtk.Image} used to set a context-aware large icon size. By default this is 32px,
     * but in certain contexts it could be larger or smaller depending on the default assumed icon size.
     */
    public const string STYLE_CLASS_LARGE_ICONS = "large-icons";
    /**
     * Style class for "on-screen display" widgets such as {@link Granite.Toast} and {@link Granite.OverlayBar}
     */
    public const string STYLE_CLASS_OSD = "osd";
    /**
     * Style class defining a sidebar, such as the left side in a file chooser
     */
    [Version (since = "7.1.0")]
    public const string STYLE_CLASS_SIDEBAR = "sidebar";

    /**
     * Style class for {@link Gtk.Label} or {@link Gtk.TextView} to emulate the appearance of Terminal. This includes
     * text color, background color, selection highlighting, and selecting the system monospace font.
     *
     * When used with {@link Gtk.Label} this style includes internal padding. When used with {@link Gtk.TextView}
     * interal padding will need to be set with {@link Gtk.Container.border_width}
     */
    public const string STYLE_CLASS_TERMINAL = "terminal";
    /**
     * Style class for flattened widgets, such as buttons,
     */
    public const string STYLE_CLASS_FLAT = "flat";
    /**
     * Style class for widgets which should use base color as their background
     */
    public const string STYLE_CLASS_VIEW = "view";

    /**
     * Transition duration when a widget closes, hides a portion of its content, or exits the screen
     */
    [Version (deprecated = true, deprecated_since = "9.0.0", replacement = "Granite.AnimationDuration.CLOSE")]
    public const int TRANSITION_DURATION_CLOSE = 200;

    /**
     * Transition duration when a widget transforms in-place, like when filtering content with a view switcher
     */
    [Version (deprecated = true, deprecated_since = "9.0.0", replacement = "Granite.AnimationDuration.IN_PLACE")]
    public const int TRANSITION_DURATION_IN_PLACE = 100;

    /**
     * Transition duration when a widget opens, reveals more content, or enters the screen
     */
    [Version (deprecated = true, deprecated_since = "9.0.0", replacement = "Granite.AnimationDuration.OPEN")]
    public const int TRANSITION_DURATION_OPEN = 250;

    /**
     * CSS style classes to be used with {@link Gtk.Widget.add_css_class}
     */
    namespace CssClass {
        /**
         * Style class to give accent color to a {@link Gtk.Label} or symbolic icon
         */
        [Version (since = "7.7.0")]
        public const string ACCENT = "accent";

        /**
         * Style class for adding a small shadow to a container such as for image thumbnails
         */
        [Version (since = "7.7.0")]
        public const string CARD = "card";

        /**
         * Style class for checkered backgrounds to represent transparency in images
         */
        [Version (since = "7.7.0")]
        public const string CHECKERBOARD = "checkerboard";

        /**
         * Style class for a circular {@link Gtk.Button}
         */
        [Version (since = "7.7.0")]
        public const string CIRCULAR = "circular";

        /**
         * Style class for {@link Gtk.Button} with a destructive action
         */
        [Version (since = "7.7.0")]
        public const string DESTRUCTIVE = "destructive";

        /**
         * Style class for dimmed labels and icons
         */
        [Version (since = "7.7.0")]
        public const string DIM = "dim-label";

        /**
         * Style class for widgets in error state.
         */
        [Version (since = "7.7.0")]
        public const string ERROR = "error";

        /**
         * sets font features to use tabular numbers. Equivalent of Pango's tnum property
         */
        [Version (since = "7.7.0")]
        public const string NUMERIC = "numeric";

        /**
         * Style class for a {@link Gtk.Label} to emulate Pango's "<small>" and "size='smaller'"
         */
        [Version (since = "7.7.0")]
        public const string SMALL = "small-label";

        /**
         * Style class for when a {@link Gtk.Button} is the primary suggested action in a specific context.
         */
        [Version (since = "7.7.0")]
        public const string SUGGESTED = "suggested";

        /**
         * Style class for widgets in success state.
         */
        [Version (since = "7.7.0")]
        public const string SUCCESS = "success";

        /**
         * Style class for widgets in warning state.
         */
        [Version (since = "7.7.0")]
        public const string WARNING = "warning";

        /**
         * Style class for non-terminal text that uses a monospace font.
         */
        [Version (since = "7.7.0")]
        public const string MONOSPACE = "monospace";

        /**
         * Style class for windows from development builds to visually separate them from stable releases.
         */
        [Version (since = "9.0.0")]
        public const string DEVEL = "devel";
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
