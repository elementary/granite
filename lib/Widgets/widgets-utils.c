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

#include "widgets-utils.h"

static void
close_cb (GtkWidget *about)
{
    GtkAboutDialogPrivate *priv = about->priv;

    gtk_widget_hide (about);
}

/**
 * gtk_show_about_dialog:
 * @parent: (allow-none): transient parent, or %NULL for none
 * @first_property_name: the name of the first property
 * @Varargs: value of first property, followed by more properties, %NULL-terminated
 *
 * This is a convenience function for showing an application's about box.
 * The constructed dialog is associated with the parent window and
 * reused for future invocations of this function.
 *
 * Since: 2.6
 */
void
    granite_widgets_show_about_dialog (GtkWindow   *parent,
                                       const gchar *first_property_name,
                                       ...)
{
    static GtkWidget *global_about_dialog = NULL;
    GtkWidget *dialog = NULL;
    va_list var_args;

    if (parent)
        dialog = g_object_get_data (G_OBJECT (parent), "gtk-about-dialog");
    else
        dialog = global_about_dialog;

    if (!dialog)
    {
        //dialog = gtk_about_dialog_new ();
        dialog = GTK_WIDGET (granite_widgets_about_dialog_new ());
        g_object_ref_sink (dialog);

        g_signal_connect (dialog, "delete-event",
                          G_CALLBACK (gtk_widget_hide_on_delete), NULL);

        /* Close dialog on user response */
        g_signal_connect (dialog, "response",
                          G_CALLBACK (close_cb), NULL);

        va_start (var_args, first_property_name);
        g_object_set_valist (G_OBJECT (dialog), first_property_name, var_args);
        va_end (var_args);

        if (parent)
        {
            gtk_window_set_modal (GTK_WINDOW (dialog), TRUE);
            gtk_window_set_transient_for (GTK_WINDOW (dialog), parent);
            gtk_window_set_destroy_with_parent (GTK_WINDOW (dialog), TRUE);
            g_object_set_data_full (G_OBJECT (parent),
                                    "gtk-about-dialog",
                                    dialog, g_object_unref);
        }
        else
            global_about_dialog = dialog;

    }

    gtk_window_present (GTK_WINDOW (dialog));
}


