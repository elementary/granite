/*
 * Copyright 2012–2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {

/**
 * Converts a {@link Gtk.accelerator_parse} style accel string to a human-readable string.
 *
 * @param accel an accelerator label like “<Control>a” or “<Super>Right”
 *
 * @return a human-readable string like "Ctrl + A" or "⌘ + →"
 */
public static string accel_to_string (string? accel) {
    if (accel == null) {
        return "";
    }

    // We need to make sure that the translation domain is correctly setup
    Granite.init ();

    uint accel_key;
    Gdk.ModifierType accel_mods;
    Gtk.accelerator_parse (accel, out accel_key, out accel_mods);

    string[] arr = {};
    if (Gdk.ModifierType.SUPER_MASK in accel_mods) {
        arr += "⌘";
    }

    if (Gdk.ModifierType.SHIFT_MASK in accel_mods) {
        arr += _("Shift");
    }

    if (Gdk.ModifierType.CONTROL_MASK in accel_mods) {
        arr += _("Ctrl");
    }

    if (Gdk.ModifierType.ALT_MASK in accel_mods) {
        arr += _("Alt");
    }

    switch (accel_key) {
        case Gdk.Key.Up:
            arr += "↑";
            break;
        case Gdk.Key.Down:
            arr += "↓";
            break;
        case Gdk.Key.Left:
            arr += "←";
            break;
        case Gdk.Key.Right:
            arr += "→";
            break;
        case Gdk.Key.Alt_L:
            ///TRANSLATORS: The Alt key on the left side of the keyboard
            arr += _("Left Alt");
            break;
        case Gdk.Key.Alt_R:
            ///TRANSLATORS: The Alt key on the right side of the keyboard
            arr += _("Right Alt");
            break;
        case Gdk.Key.backslash:
            arr += "\\";
            break;
        case Gdk.Key.Control_R:
            ///TRANSLATORS: The Ctrl key on the right side of the keyboard
            arr += _("Right Ctrl");
            break;
        case Gdk.Key.Control_L:
            ///TRANSLATORS: The Ctrl key on the left side of the keyboard
            arr += _("Left Ctrl");
            break;
        case Gdk.Key.minus:
        case Gdk.Key.KP_Subtract:
            ///TRANSLATORS: This is a non-symbol representation of the "-" key
            arr += _("Minus");
            break;
        case Gdk.Key.KP_Add:
        case Gdk.Key.plus:
            ///TRANSLATORS: This is a non-symbol representation of the "+" key
            arr += _("Plus");
            break;
        case Gdk.Key.KP_Equal:
        case Gdk.Key.equal:
            ///TRANSLATORS: This is a non-symbol representation of the "=" key
            arr += _("Equals");
            break;
        case Gdk.Key.Return:
            arr += _("Enter");
            break;
        case Gdk.Key.Shift_L:
            ///TRANSLATORS: The Shift key on the left side of the keyboard
            arr += _("Left Shift");
            break;
        case Gdk.Key.Shift_R:
            ///TRANSLATORS: The Shift key on the right side of the keyboard
            arr += _("Right Shift");
            break;
        default:
            // If a specified accelarator contains only modifiers e.g. "<Control><Shift>",
            // we don't get anything from accelerator_get_label method, so skip that case
            string accel_label = Gtk.accelerator_get_label (accel_key, 0);
            if (accel_label != "") {
                arr += accel_label;
            }
            break;
    }

    if (accel_mods != 0) {
        return string.joinv (" + ", arr);
    }

    return arr[0];
}

/**
 * Pango markup to use for secondary text in a {@link Gtk.Tooltip}, such as for accelerators, extended descriptions, etc.
 */
public const string TOOLTIP_SECONDARY_TEXT_MARKUP = """<span weight="600" size="smaller" alpha="75%">%s</span>""";

/**
 * Takes a description and an array of accels and returns {@link Pango} markup for use in a {@link Gtk.Tooltip}. This method uses {@link Granite.accel_to_string}.
 *
 * Example:
 *
 * Description
 * Shortcut 1, Shortcut 2
 *
 * @param a string array of accelerator labels like {"<Control>a", "<Super>Right"}
 *
 * @param description a standard tooltip text string
 *
 * @return {@link Pango} markup with the description label on one line and a list of human-readable accels on a new line
 */
public static string markup_accel_tooltip (string[]? accels, string? description = null) {
    string[] parts = {};
    if (description != null && description != "") {
        parts += description;
    }

    if (accels != null && accels.length > 0) {
        string[] unique_accels = {};

        // We need to make sure that the translation domain is correctly setup
        Granite.init ();

        for (int i = 0; i < accels.length; i++) {
            if (accels[i] == "") {
                continue;
            }

            var accel_string = accel_to_string (accels[i]);
            if (!(accel_string in unique_accels)) {
                unique_accels += accel_string;
            }
        }

        if (unique_accels.length > 0) {
            ///TRANSLATORS: This is a delimiter that separates two keyboard shortcut labels like "⌘ + →, Control + A"
            var accel_label = string.joinv (_(", "), unique_accels);

            var accel_markup = TOOLTIP_SECONDARY_TEXT_MARKUP.printf (accel_label);

            parts += accel_markup;
        }
    }

    return string.joinv ("\n", parts);
}

private static double contrast_ratio (Gdk.RGBA bg_color, Gdk.RGBA fg_color) {
    // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#contrast-ratiodef
    var bg_luminance = get_luminance (bg_color);
    var fg_luminance = get_luminance (fg_color);

    if (bg_luminance > fg_luminance) {
        return (bg_luminance + 0.05) / (fg_luminance + 0.05);
    }

    return (fg_luminance + 0.05) / (bg_luminance + 0.05);
}

private static double get_luminance (Gdk.RGBA color) {
    // Values from WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
    var red = sanitize_color (color.red) * 0.2126;
    var green = sanitize_color (color.green) * 0.7152;
    var blue = sanitize_color (color.blue) * 0.0722;

    return red + green + blue;
}

private static double sanitize_color (double color) {
    // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
    if (color <= 0.03928) {
        return color / 12.92;
    }

    return Math.pow ((color + 0.055) / 1.055, 2.4);
}

/**
 * Takes a {@link Gdk.RGBA} background color and returns a suitably-contrasting foreground color, i.e. for determining text color on a colored background. There is a slight bias toward returning white, as white generally looks better on a wider range of colored backgrounds than black.
 *
 * @param bg_color any {@link Gdk.RGBA} background color
 *
 * @return a contrasting {@link Gdk.RGBA} foreground color, i.e. white ({ 1.0, 1.0, 1.0, 1.0}) or black ({ 0.0, 0.0, 0.0, 1.0}).
 */
public static Gdk.RGBA contrasting_foreground_color (Gdk.RGBA bg_color) {
    Gdk.RGBA gdk_white = { 1.0f, 1.0f, 1.0f, 1.0f };
    Gdk.RGBA gdk_black = { 0.0f, 0.0f, 0.0f, 1.0f };

    var contrast_with_white = contrast_ratio (
        bg_color,
        gdk_white
    );
    var contrast_with_black = contrast_ratio (
        bg_color,
        gdk_black
    );

    // Default to white
    var fg_color = gdk_white;

    // NOTE: We cheat and add 3 to contrast when checking against black,
    // because white generally looks better on a colored background
    if ( contrast_with_black > (contrast_with_white + 3) ) {
        fg_color = gdk_black;
    }

    return fg_color;
}

}

/**
 * This namespace contains functions to apply CSS stylesheets to widgets.
 */
namespace Granite.Widgets.Utils {
    /**
     * Applies colorPrimary property to the window. The colorPrimary property currently changes
     * the color of the {@link Gtk.HeaderBar} and it's children so that the application window
     * can have a so-called "brand color".
     *
     * Note that this currently only works with the default stylesheet that elementary OS uses.
     *
     * @param window the widget to apply the color, for most cases the widget will be actually the {@link Gtk.Window} itself
     * @param color the color to apply
     * @param priority priorty of change, by default {@link Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION}
     *
     * @return the added {@link Gtk.CssProvider}, or null in case the parsing of
     *         stylesheet failed.
     */
    public Gtk.CssProvider? set_color_primary (
        Gtk.Widget window,
        Gdk.RGBA color,
        int priority = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    ) {
        assert (window != null);

        var css = "@define-color color_primary %s;".printf (color.to_string ());

        var css_provider = new Gtk.CssProvider ();
#if HAS_VALA_0_56_11
        css_provider.load_from_data (css, -1);
#else
        css_provider.load_from_data (css.data);
#endif

        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, priority);

        return css_provider;
    }
}
