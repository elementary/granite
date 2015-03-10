/*
 *  Copyright (C) 2010 troorl <troorl@gmail.com>
 *  Copyright (C) 2011 ammonkey <am.monkeyd@gmail.com>
 *  Copyright (C) 2012-2013 Granite Developers
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

using Gtk;

/* Label with NORMAL wrapping. Thanks to VMWare team. */

/**
 * This is a label which is automatically wrapped.
 * If a line is too long, there will be a line break for instance.
 */
[Deprecated (replacement = "Gtk.Label", since = "0.3")]
public class Granite.Widgets.WrapLabel : Label {

    public int m_wrap_width = 0;
    public int m_wrap_height = 0;

    /**
     * Create a new WrapLabel.
     *
     * @param str the content of the label
     */
    public WrapLabel(string? str = null)
    {
        wrap = true;
        wrap_mode = Pango.WrapMode.WORD_CHAR;
        set_alignment(0, 0);

        set_text(str);
        set_wrap_width(m_wrap_width);
    }

    private void set_wrap_width(int width)
    {
        if (width == 0) {
            return;
        }

        get_layout().set_width((int) (width * Pango.SCALE));

        int unused = 0;
        get_layout().get_pixel_size(out unused, out m_wrap_height);

        if (m_wrap_width != width) {
            m_wrap_width = width;
            queue_resize();
        }
    }

    public override void get_preferred_width (out int minimum_width, out int natural_width)
    {
        minimum_width = natural_width = m_wrap_width;
    }

    public override void size_allocate(Gtk.Allocation alloc)
    {
        base.size_allocate(alloc);
        set_wrap_width(alloc.width);
    }
}
