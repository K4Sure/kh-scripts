#!/usr/bin/env python3
"""
smart-backup.py — Universal Smart Backup (DBML+CML integrated)
- Uses: ~/kh-scripts/library/dynamic_box/dbml_loader.sh (DBML loader)
- DBML in turn sources dynamic_box_master_library.sh and CML if present.
- Interactive SBM menu + CLI (--dry-run or normal).
"""
from __future__ import annotations
import os, sys, re, shutil, shlex, subprocess
from datetime import datetime
from functools import cmp_to_key

# ---------------------------
# Configuration
# ---------------------------
HOME = os.path.expanduser("~")
DBML_LOADER = os.path.join(HOME, "kh-scripts/library/dynamic_box/dbml_loader.sh")
# NOTE: dbml_loader should auto-discover and source dynamic_box_master_library.sh,
# which itself sources CML (color master library) if present.
TIMESTAMP_FMT = "%Y%m%d_%H%M%S"
VERSION_PAT = re.compile(r"""(v?\d+(?:\.\d+)*(?:-[A-Za-z0-9._-]+)?)""", re.IGNORECASE)
SCRIPT_EXTS = {'.sh', '.bash', '.zsh', '.py', '.pl', '.rb', '.js', '.php', '.ps1', '.ksh'}
ALWAYS_EXCLUDE = set(['.git', '__pycache__', ])

# ---------------------------
# DBML wrapper helpers
# ---------------------------
def dbml_available() -> bool:
    return os.path.isfile(DBML_LOADER) and os.access(DBML_LOADER, os.R_OK)

def dbml_draw_box(style: str, title: str, lines: list[str] | None = None) -> None:
    """
    Call the DBML draw_box function via a one-shot bash -lc call that sources the loader.
    Uses shlex.quote for safe quoting of arguments.
    Prints DBML stdout to our stdout (DBML prints boxes directly).
    """
    if not dbml_available():
        # fallback text-only box if DBML missing
        fallback_draw_box(title, lines or [])
        return

    lines = lines or []
    # Build the draw_box argument list: style TITLE LINE1 LINE2 ...
    args = [style, title] + lines
    # Quote each arg safely for sh
    qargs = " ".join(shlex.quote(str(a)) for a in args)
    # command: source loader (silence its messages), then call draw_box with args
    # We use -lc so that shlex quoting is preserved.
    cmd = f"source {shlex.quote(DBML_LOADER)} >/dev/null 2>&1 && draw_box {qargs}"
    try:
        # Run and stream output
        p = subprocess.run(["bash", "-lc", cmd], check=False, capture_output=True, text=True)
        # Print DBML's output directly (it already contains box drawing and colors)
        if p.stdout:
            sys.stdout.write(p.stdout)
        if p.stderr:
            # if DBML writes warnings to stderr, show them non-fatally
            sys.stderr.write(p.stderr)
    except Exception as e:
        # on any error fallback to local box
        fallback_draw_box(title, lines)

def dbml_draw_box_quiet(style: str, title: str, lines: list[str] | None = None) -> None:
    # identical to dbml_draw_box but swallow exceptions silently
    try:
        dbml_draw_box(style, title, lines)
    except Exception:
        pass

# ---------------------------
# Local fallback box (minimal, no color) if DBML missing
# ---------------------------
def fallback_draw_box(title: str, lines: list[str]):
    title = str(title)
    lines = [str(l) for l in lines]
    width = max(len(title), *(len(l) for l in lines)) + 4
    top = "┌" + "─"*width + "┐"
    mid = "├" + "─"*width + "┤"
    bot = "└" + "─"*width + "┘"
    print(top)
    left = (width - len(title))//2
    print("│" + " "*left + title + " "*(width - len(title) - left) + "│")
    print(mid)
    for l in lines:
        print("│ " + l + " "*(width - 2 - len(l)) + "│")
    print(bot)

# ---------------------------
# Utility helpers
# ---------------------------
def now_ts() -> str:
    return datetime.now().strftime(TIMESTAMP_FMT)

def clean_input_path(s: str) -> str:
    if s is None:
        return ''
    # remove ANSI, box-drawing and control characters
    s = re.sub(r'\033\[[0-9;]*m', '', s)
    s = re.sub(r'[\u2500-\u257F]', '', s)
    s = re.sub(r'[\x00-\x09\x0b\x0c\x0e-\x1f\x7f]', '', s)
    s = s.strip()
    if s.startswith('~'):
        s = os.path.expanduser(s)
    return os.path.realpath(s)

def detect_version_in_filename(name: str) -> str | None:
    m = VERSION_PAT.search(name)
    if not m: return None
    v = m.group(1)
    return v if v.lower().startswith('v') else ('v' + v)

def detect_version_in_file(path: str) -> str | None:
    try:
        with open(path, 'rb') as f:
            data = f.read(8192).decode('utf-8', 'ignore')
    except Exception:
        return None
    # look for assignment like VERSION= or SOME_VERSION=
    m = re.search(r'^[A-Za-z_]*VERSION\s*=\s*["\']?([vV]?\d+(?:\.\d+)*(?:-[\w._-]+)?)', data, flags=re.M)
    if m:
        v = m.group(1)
        return v if v.lower().startswith('v') else ('v' + v)
    m2 = VERSION_PAT.search(data)
    if m2:
        v = m2.group(1)
        return v if v.lower().startswith('v') else ('v' + v)
    return None

def normalize_version(v: str|None) -> str:
    if not v: return "v0.0.0"
    return v if v.lower().startswith('v') else 'v' + v

def parse_version(vstr: str):
    s = vstr.lstrip('vV')
    if '-' in s:
        num, suffix = s.split('-',1); has = True
    else:
        num, suffix = s, ''; has = False
    nums = tuple(int(x) if x.isdigit() else 0 for x in num.split('.'))
    return (nums, has, suffix.lower())

def compare_versions(a: str, b: str) -> int:
    an = parse_version(a); bn = parse_version(b)
    la = len(an[0]); lb = len(bn[0]); L = max(la, lb)
    a_nums = an[0] + (0,)*(L-la); b_nums = bn[0] + (0,)*(L-lb)
    if a_nums > b_nums: return 1
    if a_nums < b_nums: return -1
    if an[1] != bn[1]: return -1 if an[1] else 1
    if an[2] > bn[2]: return 1
    if an[2] < bn[2]: return -1
    return 0

def is_script_file(path: str) -> bool:
    if not os.path.isfile(path): return False
    _, ext = os.path.splitext(path)
    if ext.lower() in SCRIPT_EXTS: return True
    try:
        with open(path, 'rb') as f:
            head = f.read(128)
            if head.startswith(b'#!'): return True
    except Exception:
        pass
    return False

def logical_base_name(filename: str) -> str:
    base, _ = os.path.splitext(filename)
    new = re.sub(r'(?i)(?:[_-]?v\d+(?:\.\d+)*(?:-[\w._-]+)?)$','', base)
    return new or base

def make_backup_name(src_basename: str, version: str) -> str:
    name, ext = os.path.splitext(src_basename)
    if not ext:
        ext = '.sh'
    ts = now_ts()
    return f"{name}_{version}_{ts}{ext}"

# ---------------------------
# Backup logic (same behavior)
# ---------------------------
def ensure_backup_subdir(src_path: str, project: str, dry_run: bool=False) -> str:
    if os.path.isdir(src_path):
        source_dir = os.path.abspath(src_path)
    else:
        source_dir = os.path.abspath(os.path.dirname(src_path) or ".")
    backup_subdir = os.path.join(source_dir, f"{project}_backup")
    if dry_run:
        return backup_subdir
    os.makedirs(backup_subdir, exist_ok=True)
    return backup_subdir

def backup_single_file(src: str, backup_dir: str, dry_run: bool=False):
    base = os.path.basename(src)
    version = detect_version_in_filename(base) or detect_version_in_file(src) or "v0.0.0"
    version = normalize_version(version)
    dest_name = make_backup_name(base, version)
    dest_path = os.path.join(backup_dir, dest_name)
    if dry_run:
        dbml_draw_box_quiet("line", "COPIED (dry-run)", [f"{base} -> {dest_path}"])
        return dest_path
    try:
        shutil.copy2(src, dest_path)
        dbml_draw_box_quiet("line", "COPIED", [f"{base} -> {dest_path}"])
        return dest_path
    except Exception as e:
        dbml_draw_box_quiet("line", "ERROR", [f"Failed to copy {src}: {e}"])
        return None

def process_directory(path: str, dry_run: bool=False):
    project = os.path.basename(os.path.abspath(path.rstrip('/')))
    backup_dir = ensure_backup_subdir(path, project, dry_run=dry_run)
    dbml_draw_box_quiet("double", "SMART BACKUP", [f"DRY-RUN: {'YES' if dry_run else 'NO'}", f"PROCESSING DIRECTORY: {path}", f"BACKUPS GO TO: {backup_dir}"])
    try:
        items = sorted(os.listdir(path))
    except Exception as e:
        dbml_draw_box_quiet("line", "ERROR", [f"Cannot list directory: {e}"]); return

    script_files = [f for f in items if f not in ALWAYS_EXCLUDE and is_script_file(os.path.join(path, f))]
    if not script_files:
        dbml_draw_box_quiet("line", "INFO", [f"No script files found in {path} (immediate files only)."]); return

    groups = {}
    for fn in script_files:
        key = logical_base_name(fn).lower()
        groups.setdefault(key, []).append(fn)

    total_backed = 0
    for logical, files in sorted(groups.items()):
        entries = []
        for fn in files:
            full = os.path.join(path, fn)
            v = detect_version_in_filename(fn) or detect_version_in_file(full) or "v0.0.0"
            v = normalize_version(v)
            entries.append((fn, v))
        entries_sorted = sorted(entries, key=cmp_to_key(lambda a,b: compare_versions(a[1], b[1])), reverse=True)
        latest_fn, latest_v = entries_sorted[0]
        tied = [e for e in entries_sorted if compare_versions(e[1], latest_v) == 0]
        if len(tied) > 1:
            best = tied[0]; best_mtime = os.path.getmtime(os.path.join(path, best[0]))
            for cand in tied[1:]:
                cand_m = os.path.getmtime(os.path.join(path, cand[0]))
                if cand_m > best_mtime:
                    best = cand; best_mtime = cand_m
            latest_fn = best[0]; latest_v = best[1]
        dbml_draw_box_quiet("double", "GROUP", [f"LOGICAL: {logical}", f"FOUND: {', '.join(files)}", f"KEEP LATEST: {latest_fn} ({latest_v})"])
        created = []
        for fn, v in entries_sorted:
            full = os.path.join(path, fn)
            dest = backup_single_file(full, backup_dir, dry_run=dry_run)
            if dest:
                created.append(dest); total_backed += 1
        for fn, v in entries_sorted:
            if fn == latest_fn:
                continue
            full = os.path.join(path, fn)
            if dry_run:
                dbml_draw_box_quiet("line", "DELETABLE", [f"{full} (would be removed)"])
            else:
                try:
                    os.remove(full)
                    dbml_draw_box_quiet("line", "DELETED", [f"Removed: {full}"])
                except Exception as e:
                    dbml_draw_box_quiet("line", "ERROR", [f"Cannot remove {full}: {e}"])
        dbml_draw_box_quiet("line", "GROUP RESULT", [f"BACKED UP: {len(created)} files", f"KEPT IN SOURCE: {latest_fn}"])
    dbml_draw_box_quiet("double", "SUMMARY", [f"TOTAL BACKED UP: {total_backed}", f"BACKUP DIRECTORY: {backup_dir}"])

def process_file(path: str, dry_run: bool=False):
    project = os.path.splitext(os.path.basename(path))[0]
    backup_dir = ensure_backup_subdir(path, project, dry_run=dry_run)
    dbml_draw_box_quiet("double", "SMART BACKUP", [f"DRY-RUN: {'YES' if dry_run else 'NO'}", f"BACKING UP FILE: {path}", f"TO: {backup_dir}"])
    dest = backup_single_file(path, backup_dir, dry_run=dry_run)
    if dest and not dry_run:
        dirname = os.path.dirname(path) or "."
        base = os.path.basename(path)
        logical = logical_base_name(base)
        for other in os.listdir(dirname):
            if other == base: continue
            if logical_base_name(other).lower() == logical.lower():
                other_full = os.path.join(dirname, other)
                v_this = normalize_version(detect_version_in_filename(base) or detect_version_in_file(path))
                v_other = normalize_version(detect_version_in_filename(other) or detect_version_in_file(other_full))
                cmpv = compare_versions(v_this, v_other)
                if cmpv >= 0:
                    try:
                        os.remove(other_full)
                        dbml_draw_box_quiet("line", "DELETED", [f"Removed older: {other_full}"])
                    except Exception as e:
                        dbml_draw_box_quiet("line", "ERROR", [f"Cannot remove {other_full}: {e}"])
                else:
                    try:
                        os.remove(path)
                        dbml_draw_box_quiet("line", "DELETED", [f"Removed older: {path}"])
                    except Exception as e:
                        dbml_draw_box_quiet("line", "ERROR", [f"Cannot remove {path}: {e}"])

# ---------------------------
# Interactive menu & CLI
# ---------------------------
def read_single_key(prompt="> "):
    sys.stdout.write(prompt); sys.stdout.flush()
    try:
        import tty, termios
        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        if ch == '\x1b':
            sys.stdout.write("\n"); return None
        sys.stdout.write("\n"); return ch
    except Exception:
        s = input()
        if s == '': return None
        return s[0]

def sbm_menu():
    try:
        while True:
            dbml_draw_box_quiet("round", "SMART BACKUP MENU (SBM)", [
                "ENTER PATH (FILE OR DIRECTORY) OR PRESS ESC TO ABORT", "",
                "EXAMPLES:",
                "~/kh-scripts/library/colors",
                "~/kh-scripts/universal-backup/smart-backup.py"
            ])
            raw = input("> ")
            path = clean_input_path(raw)
            if path == '':
                dbml_draw_box_quiet("line", "ABORT", ["ESC PRESSED — ABORTING."]); return 0
            if not os.path.exists(path):
                dbml_draw_box_quiet("line", "NOT FOUND", [f"PATH NOT FOUND: {path}", "Press any key to re-enter or ESC to abort."])
                _ = input()
                continue
            dbml_draw_box_quiet("round", "SMART BACKUP MENU (SBM)", [
                "PRESS 1 FOR: DRY RUN (BACKUP TEST)",
                "PRESS 2 FOR: EXECUTE BACKUP",
                "PRESS ESC TO GO BACK TO PATH ENTRY",
                "PRESS CTRL-C TO ABORT"
            ])
            ch = read_single_key("> ")
            if ch is None: continue
            if ch not in ('1','2'):
                dbml_draw_box_quiet("line", "INVALID", ["Press 1 or 2 only."]); continue
            dry = (ch == '1')
            dbml_draw_box_quiet("line", "CONFIRM", [f"ENGINE: {os.path.abspath(sys.argv[0])}", f"TARGET: {path}", ("DRY-RUN" if dry else "EXECUTE")])
            dbml_draw_box_quiet("line", "READY", ["Press any key to proceed, or ESC to cancel and return to path entry."])
            k = read_single_key()
            if k is None: continue
            if os.path.isdir(path):
                process_directory(path, dry_run=dry)
            elif os.path.isfile(path):
                process_file(path, dry_run=dry)
            else:
                dbml_draw_box_quiet("line", "ERROR", ["Unhandled path type."])
            dbml_draw_box_quiet("line", "DONE", ["Run complete."])
            return 0
    except KeyboardInterrupt:
        dbml_draw_box_quiet("line", "ABORT", ["CTRL-C — ABORTING."]); return 130

def usage_and_exit():
    print("Usage:")
    print("  smart-backup.py [--dry-run|-n] path1 [path2 ...]")
    print("Or run without args to launch interactive SBM.")
    sys.exit(1)

def main():
    args = sys.argv[1:]
    if not args:
        return sbm_menu()
    dry = False
    paths = []
    while args:
        a = args.pop(0)
        if a in ('-h','--help'):
            usage_and_exit()
        if a in ('--dry-run','-n'):
            dry = True; continue
        paths.append(clean_input_path(a))
    if not paths: usage_and_exit()
    for p in paths:
        if not os.path.exists(p):
            dbml_draw_box_quiet("line", "ERROR", [f"NOT FOUND: {p}"]); continue
        if os.path.isdir(p):
            process_directory(p, dry_run=dry)
        elif os.path.isfile(p):
            process_file(p, dry_run=dry)
        else:
            dbml_draw_box_quiet("line", "ERROR", [f"UNHANDLED PATH TYPE: {p}"])
    dbml_draw_box_quiet("round", "SMART BACKUP", [f"RUN COMPLETE — DRY-RUN: {'YES' if dry else 'NO'}"])
    return 0

if __name__ == "__main__":
    sys.exit(main() or 0)
