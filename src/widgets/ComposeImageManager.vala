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

class ComposeImageManager : Gtk.Box {
  private uint n_images = 0;

  construct {
    this.spacing = 6;
  }

  public async void load_image (string path) {
    Cairo.ImageSurface surface = (Cairo.ImageSurface) load_surface (path);

    var button = new AddImageButton2 ();
    button.surface = surface;

    button.show ();
    this.add (button);
  }

  public string[] get_image_paths () {
    var paths = new string[n_images];

    return paths;
  }
}
