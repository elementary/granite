/*
* Copyright (c) 2016 elementary LLC (https://launchpad.net/granite)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
*/

namespace Granite.Widgets {
    public class SidebarExpandableRowModel : SidebarParentRowModel {
        public SidebarExpandableRowModel (string label, bool expanded) {
            Object (label: label, expanded: expanded);
        }

        public SidebarExpandableRowModel.with_icon_name (string label, string icon_name, bool expanded) {
            Object (label: label, icon_name: icon_name, expanded: expanded);
        }

        public SidebarExpandableRowModel.with_icon_pixbuf (string label, Gdk.Pixbuf icon_pixbuf, bool expanded) {
            Object (label: label, icon_pixbuf: icon_pixbuf, expanded: expanded);
        }

    }
}
