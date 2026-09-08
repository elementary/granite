# Contributing

These are intructions to make contributing to elementary OS simple, and to
ensure all contributions follow consistent patterns to make review as smooth as
possible.

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
