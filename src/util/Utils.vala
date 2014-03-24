/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Utils {
  const string CONSUMER_KEY = "MHJ2SExkYnpSVUxaZDVkejZYMVRVQQ==";
  const string CONSUMER_SECRET = "b0dydmQ2NjU0bldMaHpMY0p5d1NXM3BsdFVma2hQNEJucmFQUFZOaEh0WQ==";


  /**
  * Parses a date given by Twitter in the form 'Wed Jun 20 19:01:28 +0000 2012'
  * and creates a GLib.DateTime in the local time zone to work with.
  *
  * @return The given date as GLib.DateTime in the current time zone.
  */
  GLib.DateTime parse_date (string input) {
    if (input == "") {
      return new GLib.DateTime.now_local ();
    }
    string month_str = input.substring (4, 3);
    int day          = int.parse (input.substring (8, 2));
    int year         = int.parse (input.substring (input.length-4));
    string timezone  = input.substring (20, 5);

    int month = -1;
    switch (month_str) {
      case "Jan": month = 1;  break;
      case "Feb": month = 2;  break;
      case "Mar": month = 3;  break;
      case "Apr": month = 4;  break;
      case "May": month = 5;  break;
      case "Jun": month = 6;  break;
      case "Jul": month = 7;  break;
      case "Aug": month = 8;  break;
      case "Sep": month = 9;  break;
      case "Oct": month = 10; break;
      case "Nov": month = 11; break;
      case "Dec": month = 12; break;
    }

    int hour   = int.parse (input.substring (11, 2));
    int minute = int.parse (input.substring (14, 2));
    int second = int.parse (input.substring (17, 2));
    GLib.DateTime dt = new GLib.DateTime (new GLib.TimeZone(timezone),
                                          year, month, day, hour, minute, second);
    return dt.to_timezone (new TimeZone.local ());
  }

  /**
   * Calculates an easily human-readable version of the time difference between
   * time and now.
   * Example: "5m" or "3h" or "26m" or "16 Nov"
   */
  public string get_time_delta (GLib.DateTime time, GLib.DateTime now) {
    //diff is the time difference in microseconds
    GLib.TimeSpan diff = now.difference (time);

    int minutes = (int)(diff / 1000.0 / 1000.0 / 60.0);
    if (minutes == 0)
      return _("Now");
    else if (minutes < 60)
      return _("%dm").printf (minutes);

    int hours = (int)(minutes / 60.0);
    if (hours < 24)
      return _("%dh").printf (hours);

    string month = time.format ("%b");
    //If 'time' was over 24 hours ago, we just return that
    return "%d %s".printf (time.get_day_of_month (), month);
  }


  /**
   * Extracts the actual filename out of a given path.
   * E.g. for /home/foo/bar.png, it will return "bar.png"
   *
   * @return The filename of the given path, and nothing else.
   */
  string get_file_name (string path) {
    return path.substring (path.last_index_of_char ('/') + 1);
  }

  /**
   * Extracts the file type from the given path.
   * E.g. for http://foo.org/bar/bla.png, this will just return "png"
   */
  public string get_file_type (string path) {
    string filename = get_file_name (path);
    if (filename.index_of_char ('.') == -1)
      return "";
    string type = filename.substring (filename.last_index_of_char ('.') + 1);
    type = type.down ();
    if (type == "jpg")
      return "jpeg";
    return type;
  }

  /**
   * Returns the avatar name for the given path
   *
   * @return the 'calculated' avatar name
   */
  string get_avatar_name (string path) {
    string[] parts = path.split ("/");
    return parts[parts.length - 2]+"_"+parts[parts.length - 1];
  }


  /**
   * Shows an error dialog with the given error message
   *
   * @param message The error message to show
   */
  void show_error_dialog (string message) {
    var dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.DESTROY_WITH_PARENT,
                                        Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
                                        message);

    dialog.response.connect((id) => {
      if(id == Gtk.ResponseType.OK)
        dialog.destroy();
    });

    dialog.show();
  }

  /**
   * Shows the given json error object in an error dialog.
   * Example object data:
   * {"errors":[{"message":"Could not authenticate you","code":32}]
   *
   * @param json_data The json data to show
   * @param alternative If the given json data is not valid,
   *                    show this alternative error message.
   */
  void show_error_object (string? json_data, string alternative) {
    string error_message = "Exception: " + alternative;
    if (json_data == null) {
      show_error_dialog (error_message);
      return;
    }

    var parser = new Json.Parser ();
    StringBuilder sb = new StringBuilder ();
    try {
      parser.load_from_data (json_data);
    } catch (GLib.Error e) {
      show_error_dialog (error_message);
      return;
    }

    if (parser.get_root ().get_node_type () != Json.NodeType.OBJECT) {
      show_error_dialog (error_message);
      return;
    }

    var root = parser.get_root ().get_object ();
    if (root.get_member ("errors").get_node_type () == Json.NodeType.VALUE) {
      message (json_data);
      show_error_dialog (root.get_member ("errors").get_string ());
      return;
    }

    var errors = root.get_array_member ("errors");
    if (errors.get_length () == 1) {
      var err = errors.get_object_element (0);
      sb.append (err.get_int_member ("code").to_string ()).append (": ")
        .append (err.get_string_member ("message"));
    } else {
      sb.append ("<ul>");
      errors.foreach_element ((arr, index, node) => {
        var obj = node.get_object ();
        sb.append ("<li>").append (obj.get_int_member ("code").to_string ())
          .append (": ")
          .append (obj.get_string_member ("message")).append ("</li>");
      });
      sb.append ("</ul>");
    }
    error_message = sb.str;

    critical (json_data);
    show_error_dialog (error_message);
  }



  /**
   * download_file_async:
   * Downloads the given file asynchronously to the given location.
   *
   * @param url The URL of the file to download
   * @param path The filesystem path to save the file to
   *
   */
  async void download_file_async(string url, string path, GLib.Cancellable? cancellable = null) {
    var session = new Soup.Session();
    var msg = new Soup.Message("GET", url);
    GLib.SourceFunc cb = download_file_async.callback;
    session.queue_message(msg, (_s, _msg) => {
      if (cancellable.is_cancelled ()) {
        return;
      }
      try {
        File out_file = File.new_for_path(path);
        var out_stream = out_file.replace(null, false,
                                          FileCreateFlags.REPLACE_DESTINATION, null);
        out_stream.write_all(_msg.response_body.data, null);
        cb();
      } catch (GLib.Error e) {
        critical (e.message);
      }
    });
    yield;
  }

  public async void write_pixbuf_async (Gdk.Pixbuf pixbuf, GLib.OutputStream out_stream, string type) {
    new Thread<void*> ("write_pixbuf", () => {
      try {
        pixbuf.save_to_stream (out_stream, type);
      } catch (GLib.Error e) {
        warning (e.message);
      }
      GLib.Idle.add (() => {
        write_pixbuf_async.callback ();
        return false;
      });
      return null;
    });
    yield;
  }

  string decode (string source) {
    return (string)GLib.Base64.decode (source);
  }

  string unescape_html (string input) {
    string back = input.replace ("&lt;", "<");
    back = back.replace ("&gt;", ">");
    back = back.replace ("&amp;", "&");
    return back;
  }


  void load_custom_icons () {
    var icon_theme  = Gtk.IconTheme.get_default ();
    icon_theme.append_search_path (DATADIR+"/scalable/");
  }

  string capitalize (string s) {
    string back = s;
    if (s.get_char (0).islower ()) {
      back = s.get_char (0).toupper ().to_string () + s.substring (1);
    }
    return back;
  }

  uint int64_hash_func (int64? k) {
    return (uint)k;
  }

  bool int64_equal_func (int64? a, int64? b) {
    return a == b;
  }
}
