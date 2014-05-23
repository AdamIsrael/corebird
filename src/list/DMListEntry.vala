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

using Gtk;

[GtkTemplate (ui = "/org/baedert/corebird/ui/dm-list-entry.ui")]
class DMListEntry : Gtk.ListBoxRow, ITwitterItem {
  [GtkChild]
  private Gtk.Image avatar_image;
  [GtkChild]
  private Gtk.Label text_label;
  [GtkChild]
  private Gtk.Label screen_name_label;
  [GtkChild]
  private TextButton name_button;
  [GtkChild]
  private Gtk.Label time_delta_label;

  public string text {
    set { text_label.label = value; }
  }
  public string screen_name {
    set { screen_name_label.label = "@" + value; }
  }
  public new string name {
    set { name_button.label = value; }
  }

  public Gdk.Pixbuf avatar {
    set { avatar_image.pixbuf = value; }
  }

  public bool seen {
    get { return true; }
    set {}
  }

  public int64 sort_factor {
    get { return timestamp; }
  }

  public string avatar_url;
  public int64 timestamp;
  public int64 id;
  public int64 user_id;
  public unowned MainWindow main_window;

  public DMListEntry () {
    name_button.clicked.connect (() => {
      main_window.main_widget.switch_page (Page.PROFILE, user_id);
    });
  }

  public void load_avatar () {
    avatar_image.pixbuf = Twitter.get ().get_avatar (avatar_url, (a) => {
      avatar_image.pixbuf = a;
    });
  }

  public int update_time_delta (GLib.DateTime? now = null) {
    GLib.DateTime cur_time;
    if (now == null)
      cur_time = new GLib.DateTime.now_local ();
    else
      cur_time = now;

    GLib.DateTime then = new GLib.DateTime.from_unix_local (timestamp);
    time_delta_label.label = "<small>" + Utils.get_time_delta (then, cur_time) + "</small>";
    return (int)(cur_time.difference (then) / 1000.0 / 1000.0);
  }


}


