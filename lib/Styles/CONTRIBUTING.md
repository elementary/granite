# Contributing

## Padding, Margins, and Border Radii

The base grid unit should be 3px. Sometimes widgets with borders will be "off by one" to align visually.

Border radii should increase as they nest where reasonable. The largest border radii is 9px, used by windows. Popovers and On Screen Displays use a border radius half that.

## Levels and Dark Style Theory

Widget backgrounds are styled according to "level" or "elevation". Elements gets darker the further away they are in interaction hierarchy. For example, buttons are lightest and containers like sidebars are darkest. Widgets in dark style should follow this same progression from lightest in front to darkest in back, and not simply be inverted.

## A11y

* Colors should pass WCAG AA contrast requirements
* Where possible, use the `rem()` function so that padding, margins, etc scale when users' adjust text size in system settings

## Focus, Hover, Backdrop, etc

Accent should be used to indicate the current area of focus. When selected, but not focused, use nuetral highlights.

Focused widgets should be highlighted with a ring where possible.

Backdrop states should use nuetral color and reduced depth. Contrast can be reduced in some cases, but be mindful of WCAG requirements even for backdrop elements.

## File Name Conventions

A file should be named after the CSS node it addresses. For instance,
the file addressing `GtkButton` and its descendants would use the file name
`Button.scss`. As a `GtkCheckButton` has a different CSS node (`checkbutton`),
it would be placed into it's own file, named `CheckButton.scss`. If you are
unsure of what node something uses, it's node can be found under the "Name"
column of the "CSS Nodes" tab of the "Objects" page in Gtk Inspector.

For nodes that are rarely used outside of the context of a parent node (i.e.
`check` is rarely used outside of the context of `checkbutton`), they can be
placed in the parent node file.

CSS style classes, such as `Granite.CssClass.CARD`, should be placed in a
`_classes.scss` file under the relevant library directory (e.g. Granite, Gtk,
Adw).

Mixins &amp; Variables should be grouped into relevant categories, and placed into a file with
said category name (e.g. Palette, Typography, Animation).

## Repository Structure

```
./
Gtk/
├─ Index.scss
├─ _classes.scss
├─ <1 file per CSS node>
Granite/
├─ Index.scss
├─ _classes.scss
├─ <1 file per CSS node>
Adw/
├─ Index.scss
├─ _classes.scss
├─ <1 file per CSS node>
Common/
├─ Index.scss
├─ <1 file per Mixin &amp; Variable category>
├─ <e.g. Typography, Animation, Shadows, Borders, Palette, etc.>
Index.scss
Index-dark.scss
Gtk.scss
Gtk-dark.scss
Granite.scss
Granite-dark.scss
```

## Testing Changes

Apps may need to be restarted or the system stylesheet may need to be changed before installed changes take effect.

You can also test changes live with Gtk Inspector. Make sure you have Gtk development libraries installed, then enable the inspector shortcut:

```bash
    apt install libgtk-4-dev
    gsettings set org.gtk.gtk4.Settings.Debug enable-inspector-keybinding true
```

Open an app you wish to test your changes on. Open Gtk Inspector with the keyboard shortcut Shift + Ctrl + D, then navigate to the tab "CSS" in Gtk4. Your changes here will take immediate effect on the focused app. You may have to toggle the "pause" button in the top left before changes take effect.

## Proposing Changes

Changes should be tested against the following apps to avoid breakage:
* Gtk Demo
* Gtk Widget Factory
* Granite Demo

Avoid hardcoding palette colors where possible. `accent_color` should be used for any hightlights or selection states that should adapt to users' color preferences. Use semantic variables like `warning_color` where possible since these are contrast checked for dark and light styles.

Please provide before and after screenshots of your change where applicable
