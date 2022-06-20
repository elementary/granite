/*
 * Copyright 2012-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    /**
     * Style class to give accent color to a {@link Gtk.Label} or symbolic icon
     */
    public const string STYLE_CLASS_ACCENT = "accent";
    /**
     * Style class for shaping a {@link Gtk.Button}
     */
    public const string STYLE_CLASS_BACK_BUTTON = "back-button";
    /**
     * Style class to match the window background
     */
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
    public const string STYLE_CLASS_CARD = "card";
    /**
     * Style class for checkered backgrounds to represent transparency in images
     */
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
    public const string STYLE_CLASS_DESTRUCTIVE_ACTION = "destructive-action";
    /**
     * Style class for the content area in dialogs.
     */
    public const string STYLE_CLASS_DIALOG_CONTENT_AREA = "dialog-content-area";
    /**
     * Style class for adding a border to {@link Gtk.ListBox}, {@link Gtk.InfoBar}, and others
     */
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
    public const string STYLE_CLASS_ROUNDED = "rounded";
    /**
     * Style class defining a sidebar, such as the left side in a file chooser
     */
    public const string STYLE_CLASS_SIDEBAR = "sidebar";
    /**
     * Style class for a {@link Gtk.Label} to emulate Pango's "<small>" and "size='smaller'"
     */
    public const string STYLE_CLASS_SMALL_LABEL= "small-label";
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
    public const string STYLE_CLASS_DIM_LABEL = "dim-label";
    /**
     * Style class for widgets in error state.
     */
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
    public const string STYLE_CLASS_RICH_LIST = "rich-list";
    /**
     * Style class for when an action (usually a button) is the primary suggested action in a specific context.
     */
    public const string STYLE_CLASS_SUGGESTED_ACTION = "suggested-action";
    /**
     * Style class for widgets which should use base color as their background
     */
    public const string STYLE_CLASS_VIEW = "view";
    /**
     * Style class for widgets in warning state.
     */
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
}
