//  
//  Copyright (C) 2011 Maxwell Barvian.
//  Ported from https://github.com/chergert/simply-chat/blob/master/ppg-animation.c, with some tweaks.
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Gtk;

namespace Granite {

	public enum EasingMode {
		LINEAR,
		EASE_IN_QUAD,
		EASE_OUT_QUAD,
		EASE_IN_OUT_QUAD,
		EASE_IN_CUBIC;
		
		/**
		 * An alpha function to transform the offset within the animation into the given acceleration.
		 *
		 * @param the offset within the animation
		 * 
		 * @return the transformed offset within the animation
		 */
		public double transform (double offset) {
			
			switch (this) {
			
				case EasingMode.EASE_IN_QUAD:
					return offset * offset;
				case EasingMode.EASE_OUT_QUAD:
					return -1.0 * offset * (offset - 2.0);
				case EASE_IN_OUT_QUAD:
					offset *= 2.0;
					if (offset < 1.0)
						return 0.5 * offset * offset;
					offset -= 1.0;
					return -0.5 * (offset * (offset - 2.0) - 1.0);
				case EasingMode.EASE_IN_CUBIC:
					return offset * offset * offset;
				default:
					return offset;
			}
		}
	}
	
	[CCode (has_target = false)]
	public delegate void TweenFunc (Value begin, Value end, double offset, ref Value value);

	public class Animation : GLib.Object {
	
		protected struct Tween {
			public bool is_child; // does pspec belong to a parent widget
			public ParamSpec pspec; // ParamSpec of target property
			public Value begin; // beginning value in animaton
			public Value end; // end value in animation
			
			public Tween (Object target, ParamSpec pspec, Value value) {
				
				is_child = !target.get_type ().is_a (pspec.owner_type);
				this.pspec = pspec.ref ();
				begin = Value (pspec.value_type);
				end = Value (pspec.value_type);
				value.copy (ref end);
			}
		}
		
		/**
		 * Maps a {@link GLib.Type} with a {@link Granite.TweenFunc}.  {@link Granite.Animation.get_value_at_offset} uses this
		 * to calculate new values for specific offsets.  However, the types {@link int}, {@link uint}, {@link .long},
		 * {@link ulong}, {@link float}, and {@link double} have been added by default for convenience, so it is rare
		 * that you would have to add a {@link GLib.Type} here yourself.
		 */
		public static HashTable<Type, TweenFunc> tween_funcs { get; protected set; }
		
		static construct {
			
			tween_funcs = new HashTable<Type, TweenFunc> (null, null);
			
			// Add sensible default TweenFunc's. I really wish I had a macro for this.
			tween_funcs.insert (typeof (int), (b, e, o, v) => { var x = b.get_int (), y = e.get_int (); v.set_int ((int) (x + (y - x) * o)); });
			tween_funcs.insert (typeof (uint), (b, e, o, v) => { var x = b.get_uint (), y = e.get_uint (); v.set_uint ((uint) (x + (y - x) * o)); });
			tween_funcs.insert (typeof (long), (b, e, o, v) => { var x = b.get_long (), y = e.get_long (); v.set_long ((long) (x + (y - x) * o)); });
			tween_funcs.insert (typeof (ulong), (b, e, o, v) => { var x = b.get_ulong (), y = e.get_ulong (); v.set_ulong ((ulong) (x + (y - x) * o)); });
			tween_funcs.insert (typeof (float), (b, e, o, v) => { var x = b.get_float (), y = e.get_float (); v.set_float ((float) (x + (y - x) * o)); });
			tween_funcs.insert (typeof (double), (b, e, o, v) => { var x = b.get_double (), y = e.get_double (); v.set_double (x + (y - x) * o); });
		}
		
		/**
		 * This signal is emitted when the animation has completed without interruption.
		 */
		public signal void completed ();
				
		/**
		 * The target of the animation.
		 */
		public Object target { get; construct set; }
		
		/** 
		 * The duration of the animation in milliseconds.
		 */
		public uint duration { get; construct set; default = 250; }
		
		/**
		 * The easing mode of the animation.
		 */
		public EasingMode easing_mode { get; construct set; default = EasingMode.LINEAR; }

		/**
		 * The frame rate of the animation.
		 */
		public uint frame_rate { get; construct set; default = 60; }
		
		protected uint64 begin_msec; // time which animation started
		protected uint tween_handler = 0; // Timeout performing tweens
		protected List<Tween?> tweens; // array of tweens to perform
		protected uint frame_count; // counter for debugging #frames rendered
		
		/**
		 * The percentage of the animation that has been completed, expressed in decimal form.
		 */
		protected double offset {
			get {
				return ((double) (timeval_to_msec (TimeVal ()) - begin_msec) / duration).clamp (0.0, 1.0);
			}
		}
		
		/**
		 * Whether or not the animation is currently running.
		 */
		public bool is_running {
			get {
				return (tween_handler != 0);
			}
		}
		
		protected Animation () {
			// blank. only reason we're not using this is because of a Vala bug with
			// varargs in the constructor. :-/
		}
		
		protected static Animation create (Object target, va_list args) {
		
			var anim = new Animation ();
			anim.target = target;
			anim.tweens = new List<Tween?> ();
			
			string name;
			Value value;
			ParamSpec pspec;
			Gtk.Widget parent;
			Type type = target.get_type ();
			
			while ((name = args.arg ()) != null) {
			
				if ((pspec = target.get_class ().find_property (name)) == null) {
					if (!type.is_a (typeof (Gtk.Widget)))
						critical ("Failed to find property %s in %s", name, type.name ());
					if ((parent = (target as Gtk.Widget).get_parent ()) == null)
						critical ("Failed to find property %s in %s", name, type.name ());
					if ((pspec = Container.class_find_child_property (parent.get_class (), name)) == null)
						critical ("Failed to find property %s in %s or parent %s", name, type.name (), parent.get_type ().name ());
				}
				
				// Parse the value for the pspec
				value = Value (pspec.value_type);
				type = value.type ();
				if (type == typeof (bool))
					value.set_boolean (args.arg<bool> ());
				else if (type == typeof (string))
					value.set_string (args.arg<string> ());
				else if (type == typeof (int))
					value.set_int (args.arg<int> ());
				else if (type == typeof (uint))
					value.set_uint (args.arg<uint> ());
				else if (type == typeof (long))
					value.set_long (args.arg<long> ());
				else if (type == typeof (ulong))
					value.set_ulong (args.arg<ulong> ());
				else if (type == typeof (int64))
					value.set_int64 (args.arg<int64> ());
				else if (type == typeof (double))
					value.set_double (args.arg<double> ());
				else
					value.set_object (args.arg<Object> ());
				
				anim.tweens.append (Tween (target, pspec, value));
			}
			
			return anim;
		}
		
		/**
		 * Creates a new {@link Granite.Animation} for the specified target using the default options.
		 *
		 * @param target the object that is to be animated
		 * 
		 * @return the {@link Granite.Animation}
		 */
		public static Animation create_simple (Object target, ...) {
						
			va_list args = va_list (); // have to define variable for some vala bug
			return create (target, args);
		}
		
		/**
		 * Constructs a new {@link Granite.Animation} for the specified target using the specified options.
		 *
		 * @param target the object that is to be animated
		 * @param duration the duration of the animation
		 * @param easing_mode the easing mode of the animation
		 *
		 * @return the {@link Granite.Animation}
		 */
		public static Animation create_advanced (Object target, uint duration, EasingMode easing_mode, ...) {
		
			va_list args = va_list ();
			var anim = create (target, args);
			anim.duration = duration;
			anim.easing_mode = easing_mode;
			
			return anim;
		}
		
		~Animation () {
			debug ("Rendered %u frames in %u milliseconds for target %s", frame_count, duration, target.get_class ().get_type ().name ());
		}
		
		protected inline uint64 timeval_to_msec (TimeVal t) {
			return (t.tv_sec * 1000 + t.tv_usec / 1000);
		}
		
		/**
		 * Load the begin values for all the properties that are about to be animated.
		 */
		protected void load_begin_values () {
			
			// Vala's foreach loop isn't working here for some reason. No biggie.
			tweens.foreach ((tween) => {
				
				tween.begin.reset ();
				if (tween.is_child)
					((Container) ((Gtk.Widget) target).get_parent ()).child_get_property ((Gtk.Widget) target, tween.pspec.name, tween.begin);
				else
					target.get_property (tween.pspec.name, ref tween.begin);				
			});
		}
		
		protected void unload_begin_values () {
		
			tweens.foreach ((tween) => tween.begin.reset ());
		}
		
		/**
		 * Updates the value of a property on an object using value.
		 *
		 * @param target the {@link GLib.Object} with the property which will be updated
		 * @param tween a {@link Granite.Animation.Tween} containing the property
		 * @param value the new {@link GLib.Value} for the property
		 */
		protected virtual void update_property (Object target, Tween tween, Value value) {
			target.set_property (tween.pspec.name, value);
		}
		
		/**
		 * Updates the value of the parent widget of the target using value.
		 *
		 * @param target the {@link GLib.Object} with the property which will be updated
		 * @param tween a {@link Granite.Animation.Tween} containing the property
		 * @param value the new {@link GLib.Value} for the property
		 */
		protected virtual void update_child_property (Object target, Tween tween, Value value) {
			((Container) ((Gtk.Widget) target).get_parent ()).child_set_property ((Gtk.Widget) target, tween.pspec.name, value);
		}
		
		/**
		 * Retrieves a value for a particular position within the animation.
		 *
		 * @param offset the offset in the animation from 0.0 to 1.0
		 * @param tween a {@link Granite.Animation.Tween} containing the property
		 * @param value a {@link GLib.Value} in which to store the property
		 */
		protected void get_value_at_offset (double offset, Tween tween, ref Value value) {
			
			return_if_fail (offset >= 0.0 && offset <= 1.0);
			return_if_fail (value.holds (tween.pspec.value_type));
			
			var tween_func = tween_funcs.lookup (value.type ());
			if (tween_func != null) {
				tween_func (tween.begin, tween.end, offset, ref value);
			} else {
				warning ("No tween function found for type '%s'", value.type ().name ());
				
				if (offset >= 1.0)
					tween.end.copy (ref value);
			}
		}
		
		/**
		 * Move the object properties to the next position in the animation.
		 *
		 * @return true if the animation has not completed, false otherwise
		 */
		public virtual signal bool tick () {
		
			frame_count++;
			
			// Update property values
			tweens.foreach ((tween) => {
			
				var value = Value (tween.pspec.value_type);
				get_value_at_offset (easing_mode.transform (offset), tween, ref value);
				if (tween.is_child)
					update_child_property (target, tween, value);
				else
					update_property (target, tween, value);
			});
			
			// Flush any outstanding events to the graphics server (in the case of X)
			if (target is Gtk.Widget) {
				
				var window = ((Gtk.Widget) target).get_parent_window ();
				if (window != null)
					window.flush ();
			}
				
			return (offset < 1.0);
		}
		
		/**
		 * The actual callback for the tween_handler {@link GLib.Timeout}. This method first invokes {@link Granite.Animation.tick}
		 * and, if necessary, will invoke {@link Granite.Animation.stop}.
		 */
		protected bool timeout () {
			
			bool ret = tick ();
			if (!ret) {
				stop ();
				completed ();
			}
			
			return ret;
		}
		
		/**
		 * Start the animation.
		 */
		public void start () {
			
			return_if_fail (!is_running);
			
			load_begin_values ();
			begin_msec = timeval_to_msec (TimeVal ());
			tween_handler = Timeout.add (1000 / frame_rate, timeout);
		}
		
		/**
		 * Stop the animation.
		 */
		public void stop () {
			
			Source.remove (tween_handler);
			tween_handler = 0;
			unload_begin_values ();
		}
		
	}
	
}

