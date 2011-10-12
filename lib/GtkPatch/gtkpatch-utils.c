/* GTK - The GIMP Toolkit
 * Copyright (C) 2001 CodeFactory AB
 * Copyright (C) 2001, 2002 Anders Carlsson
 * Copyright (C) 2003, 2004 Matthias Clasen <mclasen@redhat.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/*
 * Author: Anders Carlsson <andersca@gnome.org>
 *
 * Modified by the GTK+ Team and others 1997-2004.  See the AUTHORS
 * file for a list of people on the GTK+ Team.  See the ChangeLog
 * files for a list of changes.  These files are distributed with
 * GTK+ at ftp://ftp.gtk.org/pub/gtk/.
 */

#include "gtkpatch-utils.h"

gchar *
add_credits_section (gchar *title, gchar **people)
{
    gchar **p;
    gchar *q0, *q1, *q2, *r1, *r2;

    if (people == NULL)
        return;

    GString *str;
    str = g_string_new ("<span size=\"small\">");
    for (p = people; *p; p++)
    {
        q0 = *p;
        while (*q0)
        {
            q1 = strchr (q0, '<');
            q2 = q1 ? strchr (q1, '>') : NULL;
            r1 = strstr (q0, "http://");
            if (r1)
            {
                r2 = strpbrk (r1, " \n\t");
                if (!r2)
                    r2 = strchr (r1, '\0');
            }
            else
                r2 = NULL;

            if (r1 && r2 && (!q1 || !q2 || (r1 < q1)))
            {
                q1 = r1;
                q2 = r2;
            }
            else if (q1 && (q1[1] == 'a' || q1[1] == 'A') && q1[2] == ' ')
            {
                /* if it is a <a> link leave it for the label to parse */
                q1 = NULL;
            }

            if (q1 && q2)
            {
                gchar *link;
                gchar *text;
                gchar *name;

                if (*q1 == '<')
                {
                    /* email */
                    gchar *escaped;

                    text = g_strstrip (g_strndup (q0, q1 - q0));
                    name = g_markup_escape_text (text, -1);
                    q1++;
                    link = g_strndup (q1, q2 - q1);
                    q2++;
                    escaped = g_uri_escape_string (link, NULL, FALSE);
                    g_string_append_printf (str,
                                            "<a href=\"mailto:%s\">%s</a>",
                                            escaped,
                                            name[0] ? name : link);
                    g_free (escaped);
                    g_free (link);
                    g_free (text);
                    g_free (name);
                }
                else
                {
                    /* uri */
                    text = g_strstrip (g_strndup (q0, q1 - q0));
                    name = g_markup_escape_text (text, -1);
                    link = g_strndup (q1, q2 - q1);
                    g_string_append_printf (str,
                                            "<a href=\"%s\">%s</a>",
                                            link,
                                            name[0] ? name : link);
                    g_free (link);
                    g_free (text);
                    g_free (name);
                }

                q0 = q2;
            }
            else
            {
                g_string_append (str, q0);
                break;
            }
        }
        g_string_append (str, "\n");
    }
    g_string_append (str, "</span>");
    gchar *result = strdup (str->str);
    g_string_free (str, TRUE);

    return result;
}

