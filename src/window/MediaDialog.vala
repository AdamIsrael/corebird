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

[GtkTemplate (ui = "/org/baedert/corebird/ui/media-dialog.ui")]
class MediaDialog : Gtk.Window {
  [GtkChild]
  private Gtk.Overlay overlay;
  [GtkChild]
  private Gtk.Button next_button;
  [GtkChild]
  private Gtk.Button back_button;
  private unowned Tweet tweet;
  private int cur_index = 0;

  public MediaDialog (Tweet tweet, int start_media_index) {
    Media cur_media = tweet.medias[start_media_index];
    this.tweet = tweet;
    this.cur_index = start_media_index;
    change_media (cur_media);
  }

  private void change_media (Media media) {
    /* XXX The individual widgets could also just support changing their contents... */
    /* Remove the current child */
    var cur_child = overlay.get_child ();
    if (overlay.get_child () != null)
      overlay.remove (cur_child);

    if (media.type == MediaType.IMAGE || media.type == MediaType.GIF) {
      var widget = new MediaImageWidget (media.path);
      overlay.add (widget);
      widget.show_all ();
    } else if (media.type == MediaType.VINE ||
               media.type == MediaType.ANIMATED_GIF) {
      var widget = new MediaVideoWidget (media);
      overlay.add (widget);
      widget.show_all ();
    } else
      critical ("Unknown media type %d", media.type);

    if (cur_index >= tweet.medias.length - 1)
      next_button.hide ();
    else
      next_button.show ();

    if (cur_index <= 0)
      back_button.hide ();
    else
      back_button.show ();
  }

  [GtkCallback]
  private void next_button_clicked_cb () {
    if (cur_index < tweet.medias.length - 1) {
      cur_index ++;
      change_media (tweet.medias[cur_index]);
    }
  }

  [GtkCallback]
  private void back_button_clicked_cb () {
    if (cur_index > 0) {
      cur_index --;
      change_media (tweet.medias[cur_index]);
    }
  }



  [GtkCallback]
  private bool key_press_event_cb () {
    this.destroy ();
    return true;
  }

  [GtkCallback]
  private bool button_press_event_cb () {
    this.destroy ();
    return true;
  }
}
