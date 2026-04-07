# Granite Design System Standards

The following is a summary of the design targets and goals for Granite. 
When adding new styles, they should meet these goals to form a cohesive and predictable whole.

- Form reflects function: Widgets that behave similarly should look similar, while widgets that behave differently should look different.
- If something can be done in stock Gtk.CSS, it should be. SCSS should be used only where necessary.
- All supported Gtk and Granite widgets should be included in Granite.Demo; Gtk.Demo should not be needed to test styles.
- As Granite is a separate platform from Adwaita and should not have a dependency on Adw, we would ideally have equivalent widgets in Granite for any Adw widgets we use in our apps. 
  - In cases where a Granite widget is not available and an Adw widget needs to be used, styling of those Adw widgets should be done primarily at the application level. Adw widgets can be considered for styling within Granite on a case-by-case basis.
  - Adw widgets should not be added to Granite.Demo.

## Levels Theory

Ideally, widget backgrounds should be styled according to their "level" or "elevation".
The further away a widget is in the interaction hierarchy, the darker it's background color should be.
In the dark style, widgets should follow this same light-to-dark progression and not simply be inverted.

For example, interactive widgets like buttons and entries should be the lightest, while containers like sidebars should be some of the darkest widgets.
Additionally, `backdrop` and `disabled` states should be considered "further away" in the interaction hierarchy, and should thus be on the darker end of the scale.

## Color

Colors should all be derived from one of the colors in the Granite palette &mdash; an extended version of the [elementary brand palette](https://elementary.io/brand), pure white, or pure black.
Any other necessary shades or highlights should be achieved using `color` functions, and overlaying translucent black or white elements.

## Blur & Transparency

Blur and transparency should be used primarily to communicate that an element is "transient", or overlays another element. Good examples of elements that display these traits are system notifications, OSDs, and the system dock.

## Padding, Margins, and Border Radii

Granite uses a base grid unit of 2px.
To align visually with this grid, some widgets with borders will be "off-by-one".

Where reasonable, border radii should increase as they nest. For instance, button radii are 4px so they nest neatly into 8px radii windows, popovers, and OSDs.
To facilitate this, `$window_radius` has been defined as a variable, and all other radii should be derived from it (e.g. `$button_radius = $window_radius / 2`).

## States & Pseudo Classes

### Active

Interactive widgets must respond to activation.
For example:

- Clicked widgets, like buttons and list items, should press in and spring back out along the Z-axis.

https://github.com/user-attachments/assets/cb63d1f3-0eaf-4bf3-8612-2b6e87db5403

- Anything non-flat that is dragged should lift off the surface and be dropped back onto it (e.g. slider handles, tabs, etc.)

https://github.com/user-attachments/assets/6eb185b3-e883-492e-937e-18ab285ccf9c

### Checked

Widgets representing a binary on/off state should use the user's accent color when they "on" and have the `:checked` pseudo-class.
The exception to this are non-flat `ToggleButtons`, which are considered as regular buttons and thus don't have a checked state.

### Focus

Focus should be indicated by a ring using the system accent color.
Focus states should use `:focus-visible` &mdash; when possible &mdash; instead of `:focus` to avoid erroneous keyboard navigation indicators.

- For linked widgets and widgets that have adjacent siblings, the focus ring should be contained inside the widget.

### Hover

Hover is considered a progressive enhancement.
As it is not available in all contexts &mdash; it is not available when using touch, for example &mdash; widgets and important information should never be hidden behind hover states.

- Any interactive widgets that are completely flat (e.g. menu items or image buttons) should have a hover state, to show they are interact-able. This should be a filled background shape if the widget does not already have one in their normal state.

### Backdrop

Backdrop windows should use neutral colors &mdash; removing any accent color that is present &mdash; and have reduced depth.
This is achieved by using less contrast between levels and shrinking shadows.
However, backdrop windows must still be legible: text contrast must still pass WCAG A, and backdrop window contents should not be blurred or otherwise obscured.

- Non-stateful/aesthetic animation should stop in when in `:backdrop`. Stateful animations (like progress pulses) should continue animating, to ensure we're communicating that progress is continuing.

## Accessibility

### Contrast

- Colors must pass WCAG AA contrast by default
- If a `high-contrast` style class exists, it must pass WCAG AAA
- When transparency is used, an opaque `high-contrast` style class must also be added
- Excepting app icons, symbolic icons should be forced when `high-contrast` is used.

### Reduced Motion

- Interactive components should still be stateful, but translation should not occur between states. Buttons should press in, but they shouldn't bounce.
- Widgets should still react to multitouch as normal since they behave more like drag handles, but don't animate when interacted in other ways like keyboard shortcuts

### Text Scaling

Define padding and margins in `rem()` pixels so that they scale with text size adjustments. Icons should also scale with text size.

## Icons

- There must be an app icon style class that includes shadows
- Drop 24px app icons
- Drop 16px and 24px color action icons
- Sidebars should use symbolic icons
- Symbolic tool icons should have colors. See if we can expand `-gtk-icon-palette` to use the full palette for symbolics. Possible Granite.Symbol that has mono/accent/colored styles
- Symbolic icon stroke width should match text stroke width?

---

## Quirks

- Scrollbars that are always visible should maybe be non-flat?

### Flat interactive widgets

- If an interactive widget is in a clear action bar (like a sidebar, toolbar, or popover), they may be flat. Otherwise, they must have an affordance for interaction.
- Containers for flat items like list items, menu items, etc. should have padding and be rounded.

### Buttons

- For image buttons, toggles are square and regular buttons are circular
