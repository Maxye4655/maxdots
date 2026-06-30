#!/usr/bin/env python3
import os, sys, subprocess, glob
from gi import require_version

require_version("Gtk", "3.0")
require_version("GdkPixbuf", "2.0")
from gi.repository import Gtk, GdkPixbuf, Gdk, GLib

GLib.set_prgname("wallpaper-picker")

WALL_DIR = os.path.expanduser("~/wallpapers/cycle")
THUMB_DIR = os.path.expanduser("~/.cache/wallpaper-thumbs")
SETTER = os.path.expanduser("~/.config/hypr/scripts/cycle-wallpaper.sh")

BG = "#110813"
FG = "#c3c1c4"
ACCENT = "#4949AF"
CARD = "rgba(73,73,175,0.12)"
CARD_HOVER = "rgba(73,73,175,0.35)"
CARD_BORDER = "rgba(73,73,175,0.15)"


class WallpaperPicker:
    def __init__(self):
        self.win = Gtk.Window(title="\U000f0e88  Wallpapers")
        self.win.set_default_size(900, 550)
        self.win.set_position(Gtk.WindowPosition.CENTER)
        self.win.set_keep_above(True)
        self.win.connect("destroy", Gtk.main_quit)
        self.win.connect("key-press-event", self.on_key)

        css = f"""
window {{ background: {BG}; }}
scrollbar {{ background: transparent; }}
scrollbar slider {{ background: rgba(73,73,175,0.3); border-radius: 4px; min-width: 8px; }}
scrollbar slider:hover {{ background: rgba(73,73,175,0.5); }}
button.card {{
    background: {CARD}; border-radius: 10px; border: 1px solid {CARD_BORDER};
    padding: 0; outline-width: 0; transition: all 0.2s ease;
}}
button.card:hover {{
    background: {CARD_HOVER}; border-color: {ACCENT};
}}
button.card:active {{
    background: {CARD_HOVER};
}}
label {{
    color: {FG}; font-family: "CodeNewRoman Nerd Font Propo"; font-size: 12px;
    padding: 6px 10px; border-top: 1px solid {CARD_BORDER};
}}
"""
        prov = Gtk.CssProvider()
        prov.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.win.add(scroll)

        flow = Gtk.FlowBox()
        flow.set_max_children_per_line(4)
        flow.set_min_children_per_line(2)
        flow.set_selection_mode(Gtk.SelectionMode.NONE)
        flow.set_homogeneous(True)
        flow.set_row_spacing(12)
        flow.set_column_spacing(12)
        flow.set_margin_start(15)
        flow.set_margin_end(15)
        flow.set_margin_top(15)
        flow.set_margin_bottom(15)
        scroll.add(flow)

        os.makedirs(THUMB_DIR, exist_ok=True)
        for img in sorted(
            glob.glob(f"{WALL_DIR}/*.jpg") + glob.glob(f"{WALL_DIR}/*.png")
        ):
            name = os.path.basename(img)
            thumb = os.path.join(THUMB_DIR, name)
            if not os.path.exists(thumb):
                subprocess.run(
                    [
                        "magick",
                        img,
                        "-resize",
                        "320x200^",
                        "-gravity",
                        "center",
                        "-extent",
                        "320x200",
                        thumb,
                    ],
                    capture_output=True,
                )

            btn = Gtk.Button(relief=Gtk.ReliefStyle.NONE)
            btn.get_style_context().add_class("card")
            vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)

            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(thumb, 200, 130, True)
            img_w = Gtk.Image.new_from_pixbuf(pixbuf)
            img_w.set_margin_bottom(0)
            vbox.pack_start(img_w, False, False, 0)

            label_text = name.rsplit(".", 1)[0]
            lbl = Gtk.Label(label=label_text)
            lbl.set_xalign(0.5)
            vbox.pack_start(lbl, False, False, 0)

            btn.add(vbox)
            btn.connect("clicked", self.on_click, img)
            flow.add(btn)

        self.win.show_all()

    def on_click(self, btn, path):
        subprocess.Popen([SETTER, path])
        Gtk.main_quit()

    def on_key(self, win, event):
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()


if __name__ == "__main__":
    WallpaperPicker()
    Gtk.main()
