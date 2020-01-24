/*
 *  Copyright (C) 2012–2019 elementary, Inc. (https://elementary.io)
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

/**
 * An expander renderer.
 *
 * For it to draw an expander, the the {@link Gtk.CellRenderer.is_expander} property must
 * be set to true; otherwise nothing is drawn. The state of the expander (i.e. expanded or
 * collapsed) is controlled by the {@link Gtk.CellRenderer.is_expanded} property.
 *
 * @since 0.2
 */
public class Granite.Widgets.CellRendererExpander : Gtk.CellRenderer {
    public bool is_category_expander { get; set; default = false; }

    public CellRendererExpander () {
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void get_preferred_width (
        Gtk.Widget widget,
        out int minimum_size,
        out int natural_size
    ) {
        apply_style_changes (widget);
        minimum_size = natural_size = get_arrow_size (widget) + 2 * (int) xpad;
        revert_style_changes (widget);
    }

    public override void get_preferred_height_for_width (
        Gtk.Widget widget, int width,
        out int minimum_height,
        out int natural_height
    ) {
        apply_style_changes (widget);
        minimum_height = natural_height = get_arrow_size (widget) + 2 * (int) ypad;
        revert_style_changes (widget);
    }

    /**
     * Gets the size of the expander arrow.
     *
     * The default implementation tries to retrieve the "expander-size" style property from
     * //widget//, as it is primarily meant to be used along with a {@link Gtk.TreeView}.
     * For those with special needs, it is recommended to override this method.
     *
     * @param widget Widget used to query the "expander-size" style property (should be a Gtk.TreeView.)
     * @return Size of the expander arrow.
     * @since 0.2
     */
    public virtual int get_arrow_size (Gtk.Widget widget) {
        int arrow_size;
        widget.style_get ("expander-size", out arrow_size);
        return arrow_size;
    }

    public override void render (
        Cairo.Context context,
        Gtk.Widget widget,
        Gdk.Rectangle bg_area,
        Gdk.Rectangle cell_area,
        Gtk.CellRendererState flags
    ) {
        if (!is_expander) {
            return;
        }

        unowned Gtk.StyleContext ctx = apply_style_changes (widget);

        Gdk.Rectangle aligned_area = get_aligned_area (widget, flags, cell_area);

        int arrow_size = int.min (get_arrow_size (widget), aligned_area.width);

        int offset = arrow_size / 2;
        int x = aligned_area.x + aligned_area.width / 2 - offset;
        int y = aligned_area.y + aligned_area.height / 2 - offset;

        var state = ctx.get_state ();
        const Gtk.StateFlags EXPANDED_FLAG = Gtk.StateFlags.CHECKED;
        ctx.set_state (is_expanded ? state | EXPANDED_FLAG : state & ~EXPANDED_FLAG);

        ctx.render_expander (context, x, y, arrow_size, arrow_size);

        revert_style_changes (widget);
    }

    [Version (deprecated = true, deprecated_since = "", replacement = "Gtk.CellRenderer.get_preferred_size")]
    public override void get_size (
        Gtk.Widget widget,
        Gdk.Rectangle? cell_area,
        out int x_offset,
        out int y_offset,
        out int width,
        out int height
    ) {
        assert_not_reached ();
    }

    private unowned Gtk.StyleContext apply_style_changes (Gtk.Widget widget) {
        unowned Gtk.StyleContext ctx = widget.get_style_context ();
        ctx.save ();

        if (is_category_expander)
            ctx.add_class (StyleClass.CATEGORY_EXPANDER);
        else
            ctx.add_class (Gtk.STYLE_CLASS_EXPANDER);

        return ctx;
    }

    private void revert_style_changes (Gtk.Widget widget) {
        widget.get_style_context ().restore ();
    }
}
