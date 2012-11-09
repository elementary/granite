/*
 * Copyright (c) 2011 Lucas Baudin <xapantu@gmail.com>
 *
 * This is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

/**
 * This class is a wrapper to run an async command. It provides useful signals.
 */
public class Granite.Services.SimpleCommand : GLib.Object
{
    /**
     * Emitted when the command is finished.
     */
    public signal void done(int exit);

    /**
     * When the output changed (std.out and std.err).
     *
     * @param text the new text
     */
    public signal void output_changed(string text);

    /**
     * When the standard output is changed.
     *
     * @param text the new text from std.out
     */
    public signal void standard_changed(string text);

    /**
     * When the error output is changed.
     *
     * @param text the new text from std.err
     */
    public signal void error_changed(string text);

	/**
	 * The whole current standard output
     */
    public string standard_output_str = "";
    /**
     * The whole current error output
     */
    public string error_output_str = "";
    /**
     * The whole current output
     */
    public string output_str = "";
    
    GLib.IOChannel out_make;
    GLib.IOChannel error_out;
    string dir;
    string command;
    Pid pid;

    /**
     * Create a new object. You will have to call run() when you want to run the command.
     *
     * @param dir The working dir
     * @param command The command to execute (using absolute paths like /usr/bin/make causes less
     * strange bugs).
     *
     */
    public SimpleCommand(string dir, string command)
    {
        this.dir = dir;
        this.command = command;
    }

    /**
     * Launch the command. It is async.
     */
    public void run()
    {
        int standard_output = 0;
        int standard_error = 0;
        try
        {
        Process.spawn_async_with_pipes(dir,
                                       command.split(" "),
                                       null,
                                       SpawnFlags.DO_NOT_REAP_CHILD,
                                       null,
                                       out pid,
                                       null,
                                       out standard_output,
                                       out standard_error);
        }
        catch(Error e)
        {
            critical("Couldn't launch command %s in the directory %s: %s", command, dir, e.message);
        }
        
        ChildWatch.add(pid, (pid, exit) => { done(exit); });

        out_make = new GLib.IOChannel.unix_new(standard_output);
        out_make.add_watch(IOCondition.IN | IOCondition.HUP, (source, condition) => {
            if(condition == IOCondition.HUP)
            {
                return false;
            }
            string output = null;
            
            try
            {
                out_make.read_line(out output, null, null);
            }
            catch(Error e)
            {
                critical("Error in the output retrieving of %s: %s", command, e.message);
            }
        
            
            standard_output_str += output;
            output_str += output;
            standard_changed(output);
            output_changed(output);
            
            return true;
        });

        error_out = new GLib.IOChannel.unix_new(standard_error);
        error_out.add_watch(IOCondition.IN | IOCondition.HUP, (source, condition) => {
            if(condition == IOCondition.HUP)
            {
                return false;
            }
            string output = null;
            try
            {
                error_out.read_line(out output, null, null);
            }
            catch(Error e)
            {
                critical("Error in the output retrieving of %s: %s", command, e.message);
            }
            
            error_output_str += output;
            output_str += output;
            error_changed(output);
            output_changed(output);
            
            return true;
        });
    }
}
