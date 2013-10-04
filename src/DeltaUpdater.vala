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

using Gee;

class DeltaUpdater : GLib.Object {
  private ArrayList<WeakRef<TweetListEntry>> minutely = new ArrayList<WeakRef<TweetListEntry>> ();
  private ArrayList<WeakRef<TweetListEntry>> hourly   = new ArrayList<WeakRef<TweetListEntry>> ();

  public DeltaUpdater () {
    GLib.Timeout.add(60 * 1000, () => {
      for (int i = 0, size = minutely.size; i < size; i++) {
        WeakRef<TweetListEntry> item_ref = minutely.get (i);
        TweetListEntry item = minutely.get (i).get ();
        if (item == null) {
          minutely.remove (item_ref);
          size --;
          continue;
        }
        int seconds = item.update_time_delta ();
        if (seconds >= 3600) {
          minutely.remove (item_ref);
          hourly.add (item_ref);
          size --;
        }
      }
      return true;
    });

    GLib.Timeout.add(60 * 60 * 1000, () => {
      for (int i = 0, size = hourly.size; i < size; i++) {
        WeakRef<TweetListEntry> item_ref = hourly.get (i);
        if (item_ref.get () == null) {
          hourly.remove (item_ref);
          size --;
          continue;
        }
        item_ref.get ().update_time_delta ();
      }
      return true;
    });
  }



  public void add (TweetListEntry entry) {
    // TODO: This sucks
    GLib.DateTime now  = new GLib.DateTime.now_local();
    GLib.TimeSpan diff = now.difference(new GLib.DateTime.from_unix_local(
                                        entry.sort_factor));


    int seconds = (int)(diff / 1000.0 / 1000.0);

    WeakRef r = new WeakRef<TweetListEntry> (entry);
    if (seconds  < 3600)
      minutely.add (r);
    else
      hourly.add (r);
  }

}
