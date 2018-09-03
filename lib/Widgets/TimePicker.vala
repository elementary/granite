/*
 *  Copyright (C) 2011-2013 Maxwell Barvian <maxwell@elementaryos.org>,
 *                          Corentin Noël <tintou@mailoo.org>
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

namespace Granite.Widgets {

	/**
	 * This widget allows users to easily pick a time.
	 */
	public class TimePicker : Gtk.Entry {

		const int OFFSET = 15;
		const int MARGIN = 6;

		private enum TimeComponent {
			HOUR,
			MINUTE,
			SECOND;
		}

		// Signals
		/**
		 * Sent when the time got changed
		 */
		public signal void time_changed ();

		/**
		 * Format used in 12h mode
		 */
		public string format_12 { get; private set; }

		/**
		 * Format used in 24h mode
		 */
		public string format_24 { get; private set; }

		private bool _show_seconds = false;
		/**
		 * Format with seconds
		 */
		public bool show_seconds { 
			get { return _show_seconds; }
			
			set {
				_show_seconds = value;
				update_formatting ();
				update_text ();
			} 
		}

		private void update_formatting () {
			format_12 = Granite.DateTime.get_default_time_format (true, show_seconds);
			format_24 = Granite.DateTime.get_default_time_format (false, show_seconds);				
			max_length = show_seconds ? 11 : 8;
		}

		private GLib.DateTime _time = null;
		/**
		 * Current time
		 */
		public GLib.DateTime time {
			get {
				if (_time == null) {
					time = new GLib.DateTime.now_local ();
				}

				return _time;
			}

			set {
				_time = value;
				changing_time = true;

				if (_time.get_hour () >= 12) {
					am_pm_modebutton.set_active (1);
				} else {
					am_pm_modebutton.set_active (0);
				}

				update_text (true);
				changing_time = false;
			}
		}

		private string old_string = "";

		private Gtk.SpinButton hours_spinbutton;
		private Gtk.SpinButton minutes_spinbutton;
		private Gtk.SpinButton seconds_spinbutton;
		private Gtk.Label separation_label_min;
		private Gtk.Label separation_label_sec;
		private ModeButton am_pm_modebutton;
		private bool changing_time = false;

		private Gtk.Popover popover;

		construct {
			update_formatting ();
			secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("appointment-symbolic");
			icon_release.connect (on_icon_press);

			// Creates the popover
			var pop_grid = new Gtk.Grid ();
			pop_grid.column_spacing = 6; 
			pop_grid.row_spacing = 6;

			am_pm_modebutton = new ModeButton ();
			am_pm_modebutton.orientation = Gtk.Orientation.VERTICAL;
			am_pm_modebutton.no_show_all = true;
			/// TRANSLATORS: this will only show up when 12-hours clock is in use
			am_pm_modebutton.append_text (_("AM"));
			/// TRANSLATORS: this will only show up when 12-hours clock is in use
			am_pm_modebutton.append_text (_("PM"));
			am_pm_modebutton.mode_changed.connect (mode => {
				if (changing_time) {
					return;
				}

				if (am_pm_modebutton.selected == 0) {
					time = _time.add_hours (-12);
				} else if (am_pm_modebutton.selected == 1) {
					time = _time.add_hours (12);
				} else {
					assert_not_reached ();
				}

				update_text (true);
			});
			am_pm_modebutton.hexpand = true;

			if (Granite.DateTime.is_clock_format_12h ()) {
				hours_spinbutton = new Gtk.SpinButton.with_range (1, 12, 1);
			} else {
				hours_spinbutton = new Gtk.SpinButton.with_range (0, 23, 1);
			}

			hours_spinbutton.orientation = Gtk.Orientation.VERTICAL;
			hours_spinbutton.wrap = true;
			hours_spinbutton.value_changed.connect (() => update_time (TimeComponent.HOUR));
			minutes_spinbutton = new Gtk.SpinButton.with_range (0, 59, 1);
			minutes_spinbutton.orientation = Gtk.Orientation.VERTICAL;
			minutes_spinbutton.wrap = true;
			minutes_spinbutton.value_changed.connect (() => update_time (TimeComponent.MINUTE));
			seconds_spinbutton = new Gtk.SpinButton.with_range (0, 59, 1);
			seconds_spinbutton.orientation = Gtk.Orientation.VERTICAL;
			seconds_spinbutton.wrap = true;
			seconds_spinbutton.value_changed.connect (() => update_time (TimeComponent.SECOND));						

			// If the spinbutton value is less than 10, append zero in front of value. '6' becomes '06'
			minutes_spinbutton.output.connect (() => {
				var val = minutes_spinbutton.get_value ();
				if (val < 10) {
					minutes_spinbutton.set_text ("0" + val.to_string ());
					return true;
				}

				return false;
			});
			
			// If the spinbutton value is less than 10, append zero in front of value. '6' becomes '06'
			seconds_spinbutton.output.connect (() => {
				var val = seconds_spinbutton.get_value ();
				if (val < 10) {
					seconds_spinbutton.set_text ("0" + val.to_string ());
					return true;
				}

				return false;
			});

			/// TRANSLATORS: separates hours from minutes and minutes from seconds
			separation_label_min = new Gtk.Label (_(":"));
			separation_label_sec = new Gtk.Label (_(":"));

			pop_grid.attach (hours_spinbutton, 0, 0, 1, 1);
			pop_grid.attach (separation_label_min, 1, 0, 1, 1);
			pop_grid.attach (minutes_spinbutton, 2, 0, 1, 1);
			pop_grid.attach (separation_label_sec, 3, 0, 1, 1);			
			pop_grid.attach (seconds_spinbutton, 4, 0, 1, 1);
			pop_grid.attach (am_pm_modebutton, 5, 0, 1, 1);
			pop_grid.margin = MARGIN;

			popover = new Gtk.Popover (this);
			popover.add (pop_grid);

			// Connecting to events allowing manual changes
			add_events (Gdk.EventMask.FOCUS_CHANGE_MASK|Gdk.EventMask.SCROLL_MASK);
			focus_out_event.connect (() => {
				is_unfocused ();
				return false;
			});

			scroll_event.connect ((event) => {
				switch (event.direction) {
					case Gdk.ScrollDirection.UP:
					case Gdk.ScrollDirection.RIGHT:
						_time = _time.add_minutes (1);
						break;
					case Gdk.ScrollDirection.DOWN:
					case Gdk.ScrollDirection.LEFT:
						_time = _time.add_minutes (-1);
						break;
					default:
						break;
				}
				update_text ();
				return false;
			});

			activate.connect (is_unfocused);

			update_text ();
		}

		/**
		 * Creates a new TimePicker.
		 *
		 * @param format_12 The desired custom 12h format. For example "%l:%M %p".
		 * @param format_24 The desired custom 24h format. For example "%H:%M".
		 */
		public TimePicker.with_format (string format_12, string format_24) {
			Object (format_12: format_12, format_24: format_24);
		}

		/**
		 * Creates a new TimePicker.
		 *
		 * @param with_seconds Should the format include seconds. For example: "%l:%M:$S %p" or "%H:%M:%S".
		 */
		public TimePicker.with_second (bool with_second) {
			//stdout.printf (" %s\n", "with_second constructor");
			Object (show_seconds: with_second);
		}

		private void update_time (TimeComponent time_component) {
			if (changing_time == true) {
				return;
			}

			switch (time_component) {
				case TimeComponent.HOUR:
					var new_hour = hours_spinbutton.get_value_as_int () - time.get_hour ();

					if (Granite.DateTime.is_clock_format_12h ()) {
						if (hours_spinbutton.get_value_as_int () == 12 && am_pm_modebutton.selected == 0) {
							_time = _time.add_hours (-_time.get_hour ());
						} else if (hours_spinbutton.get_value_as_int () < 12 && am_pm_modebutton.selected == 0) {
							_time = _time.add_hours (new_hour);
						} else if (hours_spinbutton.get_value_as_int () == 12 && am_pm_modebutton.selected == 1) {
							_time = _time.add_hours (-_time.get_hour () + 12);
						} else if (hours_spinbutton.get_value_as_int () < 12 && am_pm_modebutton.selected == 1) {
							_time = _time.add_hours (new_hour + 12);

							if (time.get_hour () <= 12)
								_time = _time.add_hours (12);
						}
					} else {
						_time = _time.add_hours (new_hour);
					}
					break;
				case TimeComponent.MINUTE:
					_time = time.add_minutes (minutes_spinbutton.get_value_as_int () - time.get_minute ());
					break;
				case TimeComponent.SECOND:
					_time = time.add_seconds (seconds_spinbutton.get_value_as_int () - time.get_second ());
					break;
			}

			update_text ();
		}

		private void on_icon_press (Gtk.EntryIconPosition position, Gdk.Event event) {
			// If the mode is changed from 12h to 24h or visa versa, the entry updates on icon press
			update_text ();
			changing_time = true;

			if (Granite.DateTime.is_clock_format_12h () && time.get_hour () > 12)
				hours_spinbutton.set_value (time.get_hour () - 12);
			else
				hours_spinbutton.set_value (time.get_hour ());

			if (Granite.DateTime.is_clock_format_12h ()) {
				am_pm_modebutton.no_show_all = false;
				am_pm_modebutton.show_all ();

				if (time.get_hour () > 12) {
					hours_spinbutton.set_value (time.get_hour () - 12);
				} else if (time.get_hour () == 0) {
					hours_spinbutton.set_value (12);
				} else {
					hours_spinbutton.set_value (time.get_hour ());
				}

				// Make sure that bounds are set correctly
				hours_spinbutton.set_range (1, 12);
			} else {
				am_pm_modebutton.no_show_all = true;
				am_pm_modebutton.hide ();
				hours_spinbutton.set_value (time.get_hour ());

				hours_spinbutton.set_range (0, 23);
			}

			minutes_spinbutton.set_value (time.get_minute ());
			seconds_spinbutton.set_value  (time.get_second ());

			if (show_seconds) {
				seconds_spinbutton.no_show_all = false;
				seconds_spinbutton.show_all ();
				separation_label_sec.no_show_all = false;
				separation_label_sec.show_all ();
			} else {
				seconds_spinbutton.no_show_all = true;
				seconds_spinbutton.hide ();
				separation_label_sec.no_show_all = true;
				separation_label_sec.hide ();
			}

			changing_time = false;

			Gdk.Rectangle rect = Gdk.Rectangle ();
			int x = 0;
			int y = 0;
			position_dropdown (out x, out y);
			rect.x = x;
			rect.y = y;
			popover.pointing_to = rect;
			popover.position = Gtk.PositionType.BOTTOM;
			popover.show_all ();
		}

		protected virtual void position_dropdown (out int x, out int y) {
			Gtk.Allocation size;
			get_allocation (out size);

			x = size.width - OFFSET;
			y = size.height;
		}

		private void is_unfocused () {
			if (popover.visible == false && old_string.collate (text) != 0) {
				old_string = text;
				parse_time (text.dup ());
			}
		}

		private void parse_time (string timestr) {
			string current = "";
			bool is_hours = true;
			bool is_minutes = false;
			bool is_seconds = false;
			bool is_suffix = false;
			bool has_suffix = false;

			int? hour = null;
			int? minute = null;
			int? second = null;
			foreach (var c in timestr.down ().to_utf8 ()) {
				if (c.isdigit ()) {
					current = "%s%c".printf (current, c);
				} else {
					if (is_hours && !is_suffix && !is_minutes && !is_seconds && (current != "")) {
						is_hours = false;
						is_minutes = true;
						hour = int.parse (current);
						current = "";
					} else if (is_minutes && !is_hours && !is_suffix && !is_seconds && (current != "")) {
						is_minutes = false;
						if (show_seconds) { is_seconds = true; }
						minute = int.parse (current);
						current = "";
					} else if (is_seconds && !is_hours && !is_suffix && !is_minutes && (current != "")) {
						is_seconds = false;
						second = int.parse (current);
						current = "";
					}
					if ((c.to_string ().contains ("a") || c.to_string ().contains ("p")) && !is_suffix) {
						is_suffix = true;
						current = "%s%c".printf (current, c);
					}

					if (c.to_string ().contains ("m") && is_suffix == true) {
						if (hour == null) {
							return;
						}
						if (minute == null) {
							minute = 0;
						}
						if (second == null) {
							second = 0;
						}

						// We can imagine that some will try to set it to "19:00 am"
						if (current.contains ("a") || hour >= 12) {
							time = time.add_hours (hour - time.get_hour ());
						} else {
							time = time.add_hours (hour + 12 - time.get_hour ());
						}

						if (current.contains ("a") && hour == 12) {
							time = time.add_hours (-12);
						}

						time = time.add_minutes (minute - time.get_minute ());
						time = time.add_seconds (second - time.get_second ());
						has_suffix = true;
					}
				}
			}

			if (!is_hours && !is_suffix && !is_seconds && (current != "")) {
				minute = int.parse (current);
			}

			if (!is_hours && !is_suffix && !is_minutes && (current != "")) {
				second = int.parse (current);
			}

			if (hour == null) {
				if (current.length < 3) {
					hour = int.parse (current);
					minute = 0;
					second = 0;
				} else if (current.length == 4) {
					hour = int.parse (current.slice (0, 2));
					minute = int.parse (current.slice (2,4));
					second = 0;
					if (hour > 23 || minute > 59) {
						hour = null;
						minute = null;
					}
				} else if (current.length == 6) {
					hour = int.parse (current.slice (0, 2));
					minute = int.parse (current.slice (2,4));
					second = int.parse (current.slice (4,6));
					if (hour > 23 || minute > 59 || second > 59) {
						hour = null;
						minute = null;
						second = null;
					}
				}
			}

			if (!show_seconds) second = 0;

			if (hour == null || minute == null || second == null)  {
				update_text ();
				return;
			}

			if (has_suffix == false) {
				time = time.add_hours (hour - time.get_hour ());
				time = time.add_minutes (minute - time.get_minute ());
				time = time.add_seconds (second - time.get_second ());
			}

			update_text ();
		}

		private void update_text (bool no_signal = false) {
			if (Granite.DateTime.is_clock_format_12h ()) 
				set_text (time.format (format_12));
			else
				set_text (time.format (format_24));

			old_string = text;

			if (no_signal == false)
				time_changed ();
		}
	}

}
