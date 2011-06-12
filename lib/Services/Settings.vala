//  
//  Copyright (C) 2011 Robert Dyer, Rico Tzschichholz
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

namespace Granite.Services {

	public interface PrefsSerializable : GLib.Object {
	
		public abstract string prefs_serialize ();
		public abstract void prefs_deserialize (string s);
	}
	
	public abstract class Settings : GLib.Object {
	
		// Signals
		[Signal (no_recurse = true, run = "first", action = true, no_hooks = true, detailed = true)]
		public signal void changed ();
	
		private GLib.Settings schema;
		
		public Settings (string schema) {
			this.schema = new GLib.Settings (schema);
			init ();
		}
		
		public Settings.with_backend (string schema, SettingsBackend backend) {
			this.schema = new GLib.Settings.with_backend (schema, backend);
			init ();
		}
		
		public Settings.with_backend_and_path (string schema, SettingsBackend backend, string path) {
			this.schema = new GLib.Settings.with_backend_and_path (schema, backend, path);
			init ();
		}
		
		public Settings.with_path (string schema, string path) {
			this.schema = new GLib.Settings.with_path (schema, path);
			init ();
		}
		
		private void init () {
		
			debug ("Loading settings from schema '%s'", schema.schema);
			
			var obj_class = (ObjectClass) get_type ().class_ref ();
			var properties = obj_class.list_properties ();
			foreach (var prop in properties)
				load_key (prop.name);
			
			start_monitor ();
		}
		
		~Settings () {
			stop_monitor ();
		}
		
		private void stop_monitor () {
			
			schema.changed.disconnect (load_key);
		}
		
		private void start_monitor () {
			
			schema.changed.connect (load_key);
		}
		
		void handle_notify (Object sender, ParamSpec property) {
		
			notify.disconnect (handle_notify);
			call_verify (property.name);
			notify.connect (handle_notify);
			
			save_prefs ();
		}
		
		void handle_verify_notify (Object sender, ParamSpec property) {
		
			warning ("Key '%s' failed verification in schema '%s', changing value", property.name, schema.schema);
			
			save_prefs ();
		}
		
		private void call_verify (string key) {
		
			notify.connect (handle_verify_notify);
			verify (key);
			changed[key] ();
			notify.disconnect (handle_verify_notify);
		}
		
		protected virtual void verify (string key)	{
			// do nothing, this isnt abstract because we dont
			// want to force subclasses to implement this
		}
		
		void load_key (string key) {
		
			notify.disconnect (handle_notify);
		
			var obj_class = (ObjectClass) get_type ().class_ref ();
			var prop = obj_class.find_property (key);
			
			var type = prop.value_type;
			var val = Value (type);
			
			if (type == typeof (int))
				val.set_int (schema.get_int (key));
			else if (type == typeof (double))
				val.set_double (schema.get_double (key));
			else if (type == typeof (string))
				val.set_string (schema.get_string (key));
			else if (type == typeof (bool))
				val.set_boolean (schema.get_boolean (key));
			else if (type.is_enum ())
				val.set_enum (schema.get_enum (key));
			else {
				debug ("Unsupported settings type '%s' for key '%' in schema '%s'", type.name (), key, schema.schema);
				return;
			}
			
			set_property (prop.name, val);
			call_verify (prop.name);
			
			notify.connect (handle_notify);
		}
		
		void save_prefs () {
		
			stop_monitor ();
			
			var obj_class = (ObjectClass) get_type ().class_ref ();
			var properties = obj_class.list_properties ();
			foreach (var prop in properties) {
				
				var type = prop.value_type;
				var val = Value (type);
				get_property (prop.name, ref val);
				
				if (type == typeof (int))
					schema.set_int (prop.name, val.get_int ());
				else if (type == typeof (double))
					schema.set_double (prop.name, val.get_double ());
				else if (type == typeof (string))
					schema.set_string (prop.name, val.get_string ());
				else if (type == typeof (bool))
					schema.set_boolean (prop.name, val.get_boolean ());
				else if (type.is_enum ())
					schema.set_enum (prop.name, val.get_enum ());
				else {
					debug ("Unsupported settings type '%s' for key '%' in schema '%s'", type.name (), prop.name, schema);
					continue;
				}
			}
			
			start_monitor ();
		}
		
	}
	
}

