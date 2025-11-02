#!/usr/bin/env python3
"""
MEDIA CONVERT - v1.1.6
TrueColor + Smart Theme Sync Edition
Author: Kelvin (Termux Project)
"""

import os, sys, time, subprocess
from pathlib import Path
from typing import Dict, List

MCO_VERSION = "v1.1.6"

# ===============================================================
# TRUECOLOR UTILITIES
# ===============================================================
def rgb_fg(r, g, b): return f"\033[38;2;{r};{g};{b}m"
RESET = "\033[0m"

def color_text(text, rgb): return f"{rgb_fg(*rgb)}{text}{RESET}"

def title_line(width=64): return "=" * width

# ===============================================================
# SMART THEME DETECTION
# ===============================================================
def detect_theme() -> tuple[str, str]:
    """Return (theme_name, source_path) by comparing timestamps."""
    user_theme = Path.home() / "kh-scripts" / ".cml_theme"
    lib_theme = Path.home() / "kh-scripts" / "library" / "colors" / ".cml_theme"

    theme_files = [f for f in [user_theme, lib_theme] if f.exists()]
    if not theme_files:
        return "CLASSIC", "DEFAULT"

    if len(theme_files) == 1:
        active = theme_files[0]
    else:
        # Compare last modification times
        t_user = user_theme.stat().st_mtime if user_theme.exists() else 0
        t_lib = lib_theme.stat().st_mtime if lib_theme.exists() else 0
        active = user_theme if t_user >= t_lib else lib_theme

    name = active.read_text(encoding="utf-8").strip().upper().replace("\r", "")
    if not name:
        name = "CLASSIC"
    return name, str(active)

# ===============================================================
# THEME PALETTES
# ===============================================================
PALETTES = {
    "CLASSIC": {
        "title": (0, 200, 230),
        "accent": (255, 200, 0),
        "accent2": (255, 105, 180),
        "muted": (100, 100, 100),
        "good": (0, 200, 120),
        "warn": (255, 255, 0)
    },
    "NEON": {
        "title": (0, 255, 255),
        "accent": (0, 255, 120),
        "accent2": (255, 20, 147),
        "muted": (60, 60, 60),
        "good": (0, 255, 0),
        "warn": (255, 255, 0)
    },
    "NEON:PURPLE": {
        "title": (255, 0, 255),
        "accent": (0, 255, 255),
        "accent2": (255, 100, 255),
        "muted": (80, 60, 100),
        "good": (120, 255, 160),
        "warn": (255, 255, 100)
    },
    "NEON:GREEN": {
        "title": (0, 255, 128),
        "accent": (255, 255, 0),
        "accent2": (0, 255, 0),
        "muted": (40, 80, 40),
        "good": (0, 255, 120),
        "warn": (255, 255, 0)
    },
    "NEON:BLUE": {
        "title": (0, 180, 255),
        "accent": (255, 255, 100),
        "accent2": (0, 255, 255),
        "muted": (40, 60, 80),
        "good": (0, 255, 200),
        "warn": (255, 255, 100)
    },
    "SUMMER": {
        "title": (255, 190, 90),
        "accent": (255, 255, 90),
        "accent2": (230, 120, 255),
        "muted": (120, 100, 80),
        "good": (90, 255, 160),
        "warn": (255, 240, 90)
    }
}

def palette_for_theme(theme: str):
    theme = theme.strip().upper()
    return PALETTES.get(theme, PALETTES.get(theme.split(":")[0], PALETTES["CLASSIC"]))

# ===============================================================
# UI HELPERS
# ===============================================================
def print_title_box(text, palette):
    try: width = os.get_terminal_size().columns
    except: width = 68
    line = title_line(width)
    print(color_text(line, palette["accent"]))
    print(color_text(text.center(width), palette["title"]))
    print(color_text(line, palette["accent"]))
    print()

def read_single_key():
    import termios, tty
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch

def single_key_choice(prompt, options, default, palette):
    print(color_text(prompt, palette["accent2"]))
    for i, opt in enumerate(options, 1):
        mark = "   "
        if opt == default:
            mark = "  ←   🌟"
        num = color_text(f"< {i} >", palette["accent"])
        fmt = color_text(opt.upper(), palette["accent2"])
        print(f"  {num}   {fmt}{mark}")
    print()
    print(color_text(f"CHOICE [1-{len(options)}]  |  ENTER SELECTS 🌟 : ", palette["accent2"]), end='', flush=True)
    ch = read_single_key()
    print()
    if ch in ("\r", "\n"): return default
    if ch.isdigit():
        n = int(ch)
        if 1 <= n <= len(options): return options[n-1]
    return default

# ===============================================================
# PROGRESS BAR
# ===============================================================
class ProgressBar:
    def __init__(self, total, palette):
        self.total = max(total, 1)
        self.current = 0
        self.start = time.time()
        self.palette = palette

    def update(self):
        self.current += 1
        self.render()

    def render(self):
        elapsed = max(time.time() - self.start, 0.001)
        pct = self.current / self.total
        try:
            width = os.get_terminal_size().columns - 50
        except: width = 40
        width = max(30, width - 10)
        fill_len = int(width * pct)
        empty_len = width - fill_len

        filled = color_text("━" * fill_len, self.palette["accent2"])
        empty = color_text("─" * empty_len, self.palette["muted"])
        divider = color_text("╸", self.palette["accent"]) if fill_len < width else ""
        bar = filled + divider + empty

        eta = int(((self.total - self.current) * elapsed / max(self.current, 1)))
        eta_min, eta_sec = divmod(eta, 60)
        eta_str = f"{eta_min:02d}:{eta_sec:02d}"

        sys.stdout.write(
            f"\r{color_text(f'{self.current:>3}', self.palette['accent'])}/"
            f"{color_text(str(self.total), self.palette['muted'])} "
            f"[{bar}] "
            f"{color_text(f'{pct*100:5.1f}%', self.palette['accent'])} ETA "
            f"{color_text(eta_str, self.palette['muted'])}"
        )
        sys.stdout.flush()

    def finish(self): print()

# ===============================================================
# CONVERSION
# ===============================================================
IMAGE_EXTS = {".png",".jpg",".jpeg",".gif",".bmp",".webp",".tiff"}
VIDEO_EXTS = {".mp4",".mkv",".mov",".avi",".flv",".webm"}
AUDIO_EXTS = {".mp3",".wav",".m4a",".aac",".flac",".ogg"}

def detect_media_type(path):
    if path.is_file():
        ext = path.suffix.lower()
        if ext in IMAGE_EXTS: return "image"
        if ext in VIDEO_EXTS: return "video"
        if ext in AUDIO_EXTS: return "audio"
        return "unknown"
    counts = {"image":0,"video":0,"audio":0}
    for e in IMAGE_EXTS: counts["image"] += len(list(path.glob(f"*{e}")))
    for e in VIDEO_EXTS: counts["video"] += len(list(path.glob(f"*{e}")))
    for e in AUDIO_EXTS: counts["audio"] += len(list(path.glob(f"*{e}")))
    best = max(counts, key=counts.get)
    return best if counts[best]>0 else "unknown"

def gather_files(path, mtype):
    if path.is_file(): return [path]
    exts = IMAGE_EXTS if mtype=="image" else VIDEO_EXTS if mtype=="video" else AUDIO_EXTS
    return sorted([f for f in path.iterdir() if f.suffix.lower() in exts])

def ffmpeg_cmd(src, dst, mtype, fmt, q):
    cmd = ["ffmpeg","-y","-hide_banner","-loglevel","error","-i",str(src)]
    if mtype=="image" and fmt in ("jpg","jpeg"):
        cmd += ["-vf","format=rgb24","-q:v",q,str(dst)]
    else:
        cmd += [str(dst)]
    return cmd

# ===============================================================
# MAIN
# ===============================================================
def convert_media(path_str):
    path = Path(path_str).expanduser().resolve()
    theme, src_path = detect_theme()
    palette = palette_for_theme(theme)

    print()
    print_title_box(f"MEDIA CONVERT {MCO_VERSION} — THEME: {theme}", palette)
    print(color_text(f"ACTIVE THEME SOURCE: {src_path}", palette["muted"]))
    print()

    if not path.exists():
        print(color_text("❌ INPUT PATH NOT FOUND", palette["warn"]))
        sys.exit(1)

    mtype = detect_media_type(path)
    if mtype == "unknown": mtype = "image"

    fmt_opts = {"image":["jpg","png","gif"],"video":["mp4","mkv","avi"],"audio":["mp3","wav","ogg"]}
    opts = fmt_opts.get(mtype,["jpg"])
    out_fmt = single_key_choice("SELECT OUTPUT FORMAT", opts, opts[0], palette)
    print()

    quality="5"
    if mtype=="image" and out_fmt in ("jpg","jpeg"):
        print(color_text("JPEG QUALITY RANGE :", palette["good"]))
        print(color_text("≤ #2 (BEST) – #31 (WORST) ≥", palette["accent"]))
        print(color_text("ENTER SELECTS 🌟 Quality #5 : ", palette["good"]), end='', flush=True)
        q = input().strip()
        if q.isdigit() and 2<=int(q)<=31: quality=q
        print()

    out_dir = (path.parent if path.is_file() else path)/f"Output_{out_fmt.upper()}"
    out_dir.mkdir(parents=True, exist_ok=True)
    print(color_text(f"OUTPUT FOLDER: {out_dir}", palette["accent"]))
    print()

    files = gather_files(path, mtype)
    if not files:
        print(color_text("NO FILES FOUND", palette["warn"]))
        return

    start_time = time.time()
    prog = ProgressBar(len(files), palette)
    for f in files:
        dest = out_dir / f"{f.stem}.{out_fmt}"
        cmd = ffmpeg_cmd(f, dest, mtype, out_fmt, quality)
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        prog.update()
    prog.finish()
    total_time = time.time() - start_time

    print()
    print(color_text(f"TOTAL {len(files)} FILES CONVERTED TO [{out_fmt.upper()}]", palette["warn"]))
    print()
    print(color_text(f"⏱️ COMPLETED IN {total_time:.1f} SECONDS", palette["accent"]))
    print()
    print(color_text("✔ CONVERSION COMPLETED", palette["good"]))
    print()

# ===============================================================
# CLI
# ===============================================================
if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--version":
        print(f"MEDIA CONVERT {MCO_VERSION}")
        sys.exit(0)
    if len(sys.argv) < 2:
        print("Usage: mco <input_path>")
        sys.exit(0)
    convert_media(sys.argv[1])
