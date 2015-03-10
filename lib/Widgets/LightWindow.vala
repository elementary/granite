/*
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
 *
 *  Authored by: Tom Beckmann <tom@elementaryos.org>
 */

namespace Granite.Widgets {

    /**
     * This is always-on-top, non-modal window with a large close button.
     *
     * {{../../doc/images/LightWindow.png}}
     */
    [Deprecated (replacement="Gtk.Dialog", since = "0.3")]
    public class LightWindow : DecoratedWindow {

        /**
         * Makes a new Window with the Light Theme
         *
         * @param title title of new window
         */
        public LightWindow (string title = "") {
            base (title, StyleClass.CONTENT_VIEW_WINDOW, StyleClass.CONTENT_VIEW);
        }
        
    }

}

