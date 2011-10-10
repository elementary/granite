using Gtk;

/** Label with NORMAL wrapping. Thanks to VMWare team */
public class Granite.WrapLabel : Label {

    public int m_wrap_width = 0;
    public int m_wrap_height = 0;

    public signal void link_activated(string prot, string uri);

    public WrapLabel(string? str = null) {
        wrap = true;
        get_layout().set_wrap(Pango.WrapMode.WORD_CHAR);
        set_alignment(0, 0);

        set_text(str);
        set_wrap_width(m_wrap_width);

        activate_link.connect(link_clicked);
    }

    private bool link_clicked(string url) {
        link_activated(url.split("://")[0], url.split("://")[1]);
        return true;
    }

    private void set_wrap_width(int width) {
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

    public override void size_allocate(Gtk.Allocation alloc) {
        base.size_allocate(alloc);
        set_wrap_width(alloc.width);
    }

    public void set_markup_plus(string txt) {
        set_markup(txt);
        set_wrap_width(m_wrap_width);
    }
}
