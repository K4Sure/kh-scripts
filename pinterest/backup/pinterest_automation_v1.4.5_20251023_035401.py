#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pinterest Downloader Automation Script v1.4.5
Gallery-dl backend, embedded config, full backup manager, ANSI colors and emojis preserved.
Place this file at:
 /data/data/com.termux/files/home/kh-scripts/pinterest/pinterest_automation_v1.4.5.py
"""

import os
import sys
import time
import json
import shutil
import subprocess
import argparse
import requests
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

# -------------------------
# Script metadata
# -------------------------
__version__ = "1.4.5"
__author__ = "Pinterest Automation Script"
__created__ = "2025-10-21"

# -------------------------
# Directories & paths
# -------------------------
BASE_DIR = Path("/data/data/com.termux/files/home/kh-scripts/pinterest")
BACKUP_DIR = BASE_DIR / "backup"

DOWNLOAD_BASE = Path("/storage/emulated/0/Download/Social Media/Pinterest/pinterest-dl")
PHOTOS_DIR = DOWNLOAD_BASE / "ptdl Photos"
VIDEOS_DIR = DOWNLOAD_BASE / "ptdl Videos"
RAW_DIR = DOWNLOAD_BASE / "ptdl raw"
SEARCHES_DIR = DOWNLOAD_BASE / "ptdl searches"
COOKIES_DIR = DOWNLOAD_BASE / "ptdl cookies"
URLS_DIR = DOWNLOAD_BASE / "ptdl urls"
LOGS_DIR = DOWNLOAD_BASE / "ptdl logs"
COOKIES_FILE = COOKIES_DIR / "pinterest_cookies.json"
PINTEREST_URLS_FILE = Path("/storage/emulated/0/Download/Social Media/Pinterest/pinterest-dl/ptdl urls/pinterest_urls.txt")

# gallery-dl config path (script-related, not under downloads)
CONFIG_FILE = BASE_DIR / "config.json"

# -------------------------
# Embedded gallery-dl config (will use RAW_DIR as base-directory)
# -------------------------
EMBEDDED_CONFIG = {
    "extractor": {
        "pinterest": {
            "username": "",
            "password": "",
            "download": True
        }
    },
    "output": {
        "base-directory": str(RAW_DIR),
        "filename": "{id}_{title}.{extension}"
    },
    "log": {
        "level": "INFO"
    }
}

# -------------------------
# ANSI colors and formatting
# -------------------------
RED = '\033[38;5;196m'
NEON_YELLOW = '\033[38;5;226m'
NEON_GREEN = '\033[38;5;46m'
NEON_RED = '\033[38;5;196m'
NEON_BLUE = '\033[38;5;33m'
NEON_CYAN = '\033[38;5;51m'
NEON_PINK = '\033[38;5;205m'
PINK = '\033[38;5;205m'
WHITE = '\033[38;5;255m'
NEON_WHITE = '\033[38;5;255m'
GRAY = '\033[38;5;248m'
BOLD = '\033[1m'
RESET = '\033[0m'

# -------------------------
# URL Expansion Function
# -------------------------
def expand_pinterest_url(short_url: str) -> str:
    """
    Expand short pin.it URLs to full Pinterest URLs for compatibility with gallery-dl.
    Returns the expanded URL if successful, original URL if expansion fails.
    """
    if not short_url.startswith('https://pin.it/') and not short_url.startswith('http://pin.it/'):
        return short_url  # Not a short URL, return as-is
    
    try:
        print(f"{BOLD}{NEON_WHITE}🔗 Short URL: {RESET}{NEON_YELLOW}{short_url}{RESET}")
        print(f"{NEON_YELLOW}🔄 Expanding Short URLs.....{RESET}")
        response = requests.get(short_url, allow_redirects=True, timeout=10)
        final_url = response.url
        
        if "pinterest.com" in final_url:
            print(f"{BOLD}{NEON_WHITE}🪄 Expanded to: {RESET}{NEON_YELLOW}{final_url}{RESET}")
            return final_url
        else:
            print(f"{RED}❌ Expansion failed - redirected to non-Pinterest URL{RESET}")
            return short_url  # Return original if redirect is not Pinterest
    except requests.exceptions.RequestException as e:
        print(f"{RED}❌ Expansion error: {e}{RESET}")
        return short_url  # Return original on error

def expand_urls_if_needed(urls: List[str]) -> List[str]:
    """Expand all short Pinterest URLs in a list"""
    expanded_urls = []
    for url in urls:
        if url.startswith('https://pin.it/') or url.startswith('http://pin.it/'):
            expanded_url = expand_pinterest_url(url)
            expanded_urls.append(expanded_url)
        else:
            expanded_urls.append(url)
    return expanded_urls

# -------------------------
# Utilities
# -------------------------
def shorten_path(path: Path) -> str:
    """Shorten path by replacing HOME base with ~~ and Download/Social Media with ~~~"""
    path_str = str(path)
    
    # Replace home directory with ~~
    home_path = "/data/data/com.termux/files/home"
    if path_str.startswith(home_path):
        return f"~~{path_str[len(home_path):]}"
    
    # Replace Download/Social Media with ~~~
    download_base = "/storage/emulated/0/Download/Social Media"
    if path_str.startswith(download_base):
        return f"~~~{path_str[len(download_base):]}"
    
    return path_str

def ensure_directories():
    """Ensure all required directories exist"""
    dirs = [
        BASE_DIR, BACKUP_DIR, DOWNLOAD_BASE, RAW_DIR,
        PHOTOS_DIR, VIDEOS_DIR, SEARCHES_DIR,
        COOKIES_DIR, URLS_DIR, LOGS_DIR
    ]
    for d in dirs:
        try:
            d.mkdir(parents=True, exist_ok=True)
        except Exception:
            pass
    
    # Ensure the hardcoded URLs file directory exists
    try:
        PINTEREST_URLS_FILE.parent.mkdir(parents=True, exist_ok=True)
    except Exception:
        pass
        
    return True

def get_script_info() -> Dict[str, Any]:
    script_path = Path(__file__)
    return {
        'name': script_path.name,
        'version': __version__,
        'path': str(script_path),
        'base_dir': shorten_path(BASE_DIR),
        'backup_dir': shorten_path(BACKUP_DIR),
        'download_base': str(DOWNLOAD_BASE),
        'created': __created__,
        'author': __author__
    }

# -------------------------
# Backup / version management (canonical)
# -------------------------
def extract_version_from_filename(filename: str) -> tuple:
    """Extract version number from filename as tuple for comparison"""
    try:
        if 'pinterest_automation_v' in filename:
            part = filename.split('pinterest_automation_v', 1)[1]
            part = part.split('.py', 1)[0]
            parts = [p for p in part.split('.') if p.isdigit()]
            return tuple(map(int, parts))
    except Exception:
        pass
    return (0, 0, 0)

def list_script_versions():
    """List all script versions in both directories and mark current version"""
    print()
    print("=" * 60)
    print(f"{BOLD}📚 Pinterest Downloader Script Versions{RESET}")
    print("=" * 60)

    print()

    # Backed up scripts
    print(f"{BOLD}💾 Backed Up Scripts:{RESET}")
    print(f"📍 Path: {NEON_YELLOW}{shorten_path(BACKUP_DIR)}{RESET}")
    try:
        backup_scripts = sorted(BACKUP_DIR.glob("pinterest_automation_v*.py"), key=lambda x: extract_version_from_filename(x.name), reverse=True)
    except Exception:
        backup_scripts = []
    if backup_scripts:
        for script in backup_scripts:
            print(f"   📄 {script.name}")
    else:
        print("   ❌ No Backed Up Scripts Found")

    print()

    # Current scripts
    print(f"{BOLD}📂 Current Scripts:{RESET}")
    print(f"📍 Path: {NEON_YELLOW}{shorten_path(BASE_DIR)}{RESET}")
    try:
        main_scripts = sorted(BASE_DIR.glob("pinterest_automation_v*.py"), key=lambda x: extract_version_from_filename(x.name), reverse=True)
    except Exception:
        main_scripts = []
    current_script = Path(__file__).name
    if main_scripts:
        for script in main_scripts:
            if script.name == current_script:
                print(f"{RED}   📄 {script.name} ✔ (Current){RESET}")
            else:
                print(f"   📄 {script.name}")
    else:
        print("   ❌ No Scripts Found")

    print()

def backup_all_scripts():
    """Backup all scripts to backup directory and remove old versions, keeping only latest"""
    print()
    print("=" * 60)
    print(f"{BOLD}💾 Script Backup Manager{RESET}")
    print("=" * 60)
    print()

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    try:
        script_files = sorted([f for f in BASE_DIR.iterdir() if f.is_file() and f.name.startswith('pinterest_automation_v') and f.suffix == '.py'],
                              key=lambda x: extract_version_from_filename(x.name), reverse=True)
    except Exception:
        script_files = []

    if not script_files:
        print("❌ No Pinterest automation scripts found to backup")
        return False

    latest_script = script_files[0]

    print(f"{BOLD}🔍 Found {len(script_files)} Script(s){RESET}")
    print(f"{BOLD}⭐ Latest Version: {RED}{latest_script.name}{RESET}")

    print()

    backup_success = []
    backup_failed = []

    # Backup all scripts with timestamps
    print(f"{BOLD}📤 Backing Up Scripts...{RESET}")
    print(f"📍 Backup Path: {NEON_YELLOW}{shorten_path(BACKUP_DIR)}{RESET}")
    for script_file in script_files:
        try:
            name_without_ext = script_file.stem
            backup_filename = f"{name_without_ext}_{timestamp}.py"
            dest = BACKUP_DIR / backup_filename
            shutil.copy2(script_file, dest)
            backup_success.append(script_file.name)
            print(f"   {NEON_GREEN}📄 {script_file.name}{RESET}")
            print(f"      {NEON_YELLOW}➜ {backup_filename}{RESET}")
        except Exception as e:
            backup_failed.append(f"{script_file.name} - {e}")
            print(f"   {RED}❌ Failed: {script_file.name} - {e}{RESET}")

    print()

    # Clean up old versions (remove older copies from BASE_DIR, keep latest)
    print(f"{GRAY}🧹 Cleaning Up Old Versions...{RESET}")
    removed_count = 0
    for script_file in script_files[1:]:
        try:
            script_file.unlink()
            removed_count += 1
            print(f"   {NEON_GREEN}✅ Removed: {script_file.name}{RESET}")
        except Exception as e:
            print(f"   {RED}❌ Failed to remove {script_file.name}: {e}{RESET}")

    print()

    # Summary
    print(f"{BOLD}📊 Backup Summary:{RESET}")
    print(f"   ✅ Successfully Backed Up: {NEON_GREEN}{len(backup_success)} Script(s){RESET}")
    print(f"   ❌ Failed to Backup: {RED}{len(backup_failed)} Script(s){RESET}")
    print(f"   🧹 Removed Old Versions: {GRAY}{removed_count} Script(S){RESET}")
    print(f"   {BOLD}⭐ Kept Latest: {RED}{latest_script.name}{RESET}")
    print()

    if backup_failed:
        print(f"{RED}⚠️  Some backups failed:{RESET}")
        for failed in backup_failed:
            print(f"   - {failed}")

    return len(backup_failed) == 0

# -------------------------
# Config management (embedded config)
# -------------------------
def ensure_gallery_dl_config():
    """Ensure the embedded gallery-dl config exists in BASE_DIR"""
    try:
        BASE_DIR.mkdir(parents=True, exist_ok=True)
    except Exception:
        pass
    try:
        if not CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
                json.dump(EMBEDDED_CONFIG, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        return False

# -------------------------
# Installation check
# -------------------------
def check_installation():
    """Check if gallery-dl is properly installed"""
    try:
        if shutil.which("gallery-dl") is None:
            print(f"{RED}❌ gallery-dl not found. Install with: pkg install python && pip install gallery-dl{RESET}")
            return False
        result = subprocess.run(["gallery-dl", "--version"], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            version_text = result.stdout.strip()
            print(f"{BOLD}{WHITE}#️⃣ gallery-dl version: {RESET} {BOLD}{NEON_GREEN}{version_text}{RESET}")
            return True
        else:
            print(f"{RED}❌ gallery-dl appears installed but returned non-zero on --version{RESET}")
            return False
    except Exception:
        print(f"{RED}❌ gallery-dl not found or not runnable{RESET}")
        return False

# -------------------------
# Progress indicator
# -------------------------
class ProgressIndicator:
    def __init__(self, total_files: int):
        self.total_files = total_files
        self.current = 0
        self.start_time = time.time()
        
    def update(self, count: int = 1):
        self.current += count
        self._display()
        
    def _display(self):
        elapsed = time.time() - self.start_time
        percent = self.current / self.total_files if self.total_files > 0 else 0
        
        # Calculate bar width based on terminal size (reduced by 8 spaces total)
        try:
            # Reserve space for: "XXX/XXX files [](space)PPP.P% ETA mm:ss"
            # File count: up to 7 chars, percentage: 7 chars, ETA: 8 chars, brackets: 2 chars, spaces: 3
            # Total fixed: 7 + 7 + 8 + 2 + 3 = 27 + 8 (reduction) = 35
            terminal_width = os.get_terminal_size().columns
            bar_width = max(20, terminal_width - 35)  # Reduced by 8 spaces total
        except:
            bar_width = 29  # Default reduced width
            
        filled_length = int(bar_width * percent)
        bar = '━' * filled_length + '╸' + '─' * (bar_width - filled_length - 1)
        
        # Calculate ETA in mm:ss format
        if self.current > 0 and elapsed > 0:
            speed = self.current / elapsed
            remaining = (self.total_files - self.current) / speed if speed > 0 else 0
            eta_min = int(remaining // 60)
            eta_sec = int(remaining % 60)
            eta_str = f"{eta_min:02d}:{eta_sec:02d}"
        else:
            eta_str = "00:00"
            
        # Colorful progress bar - changed "files" to "Files" and color to neon cyan
        file_count_str = f"{NEON_CYAN}{self.current}{WHITE}/{NEON_CYAN}{self.total_files}{WHITE} {NEON_CYAN}Files{RESET}"
        bar_str = f"{NEON_GREEN}{bar[:filled_length]}{NEON_PINK}╸{NEON_YELLOW}{bar[filled_length+1:]}{WHITE}"
        percent_str = f"{NEON_GREEN}{percent:.1%}{WHITE}"
        eta_str_colored = f"{NEON_YELLOW}{eta_str}{WHITE}"
        
        print(f"\r{file_count_str} [{bar_str}] {percent_str} ETA {eta_str_colored}", end="", flush=True)
    
    def finish(self):
        print()

# -------------------------
# Helpers for files & organizing
# -------------------------
def extract_username_from_url(url: str) -> str:
    """Extract username from Pinterest URL"""
    try:
        clean_url = url.replace('https://', '').replace('http://', '').replace('www.', '')
        if 'pinterest.com/' in clean_url:
            parts = clean_url.split('pinterest.com/')[1].split('/')
            if parts and parts[0] and not parts[0].startswith('pin') and not parts[0].startswith('search'):
                username = parts[0].replace('-', '_').replace('.', '_')
                username = username.split('?')[0]
                return username
    except Exception:
        pass
    return "pinterest"

def get_next_file_number(directory: Path, username: str, extension: str) -> int:
    """Get the next file number for the username and extension"""
    pattern = f"{username}_*.{extension}"
    try:
        existing_files = list(directory.glob(pattern))
    except Exception:
        existing_files = []
    if not existing_files:
        return 1
    numbers = []
    for file in existing_files:
        try:
            stem = file.stem
            if stem.startswith(username + "_"):
                num_part = stem[len(username) + 1:]
                digits = ''
                for ch in num_part:
                    if ch.isdigit():
                        digits += ch
                    else:
                        break
                if digits:
                    numbers.append(int(digits))
        except Exception:
            continue
    return max(numbers) + 1 if numbers else 1

def organize_downloaded_files(download_dir: Path, username: str):
    """Organize downloaded files into Photos and Videos with proper naming"""
    print(f"{BOLD}📁 Organizing Files for User: {RESET}{NEON_PINK}{username}{RESET}")
    
    image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'}
    video_extensions = {'.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv'}
    moved_files = []

    # First count total files
    total_files = 0
    try:
        for file_path in download_dir.rglob('*'):
            if file_path.is_file():
                extension = file_path.suffix.lower()
                if extension in image_extensions or extension in video_extensions:
                    total_files += 1
    except Exception:
        pass

    if total_files == 0:
        return moved_files

    # Initialize progress indicator
    progress = ProgressIndicator(total_files)
    
    try:
        for file_path in download_dir.rglob('*'):
            if file_path.is_file():
                extension = file_path.suffix.lower()
                if extension in image_extensions:
                    target_dir = PHOTOS_DIR
                    file_type = 'photo'
                elif extension in video_extensions:
                    target_dir = VIDEOS_DIR
                    file_type = 'video'
                else:
                    continue

                target_dir.mkdir(parents=True, exist_ok=True)
                next_num = get_next_file_number(target_dir, username, extension[1:])
                new_filename = f"{username}_{next_num:03d}{extension}"
                new_path = target_dir / new_filename
                try:
                    shutil.move(str(file_path), str(new_path))
                    moved_files.append({
                        'original': file_path.name,
                        'new': new_filename,
                        'type': file_type,
                        'path': str(new_path)
                    })
                    # Update progress instead of printing each file
                    progress.update(1)
                except Exception:
                    # Still update progress even if move fails
                    progress.update(1)
    except Exception as e:
        pass

    progress.finish()
    return moved_files

# -------------------------
# Running gallery-dl quietly
# -------------------------
def run_gallery_dl(url: str, cookies: bool = False, timeout: int = 600) -> Dict[str, Any]:
    """
    Run gallery-dl with config set to CONFIG_FILE and temporary destination under RAW_DIR.
    Suppress gallery-dl stdout/stderr unless an error occurs. Return result dict.
    """
    timestamp = int(time.time())
    temp_dir = RAW_DIR / f"temp_{timestamp}"
    temp_dir.mkdir(parents=True, exist_ok=True)

    cmd = ["gallery-dl", "--config", str(CFIG_FILE), "--destination", str(temp_dir), url]
    if cookies and COOKIES_FILE.exists():
        cmd = ["gallery-dl", "--config", str(CONFIG_FILE), "--cookies", str(COOKIES_FILE), "--destination", str(temp_dir), url]

    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'returncode': -1,
            'stdout': '',
            'stderr': f'Command timed out after {timeout} seconds',
            'command': ' '.join(cmd),
            'temp_dir': str(temp_dir)
        }
    except Exception as e:
        return {
            'success': False,
            'returncode': -1,
            'stdout': '',
            'stderr': str(e),
            'command': ' '.join(cmd),
            'temp_dir': str(temp_dir)
        }

    success = proc.returncode == 0
    return {
        'success': success,
        'returncode': proc.returncode,
        'stdout': proc.stdout,
        'stderr': proc.stderr,
        'command': ' '.join(cmd),
        'temp_dir': str(temp_dir)
    }

# -------------------------
# Cookie helper
# -------------------------
def check_cookies_available() -> bool:
    """Check if cookies file exists and is valid JSON"""
    if COOKIES_FILE.exists():
        try:
            with open(COOKIES_FILE, 'r', encoding='utf-8') as f:
                cookies_data = json.load(f)
            if cookies_data:
                return True
            else:
                return False
        except json.JSONDecodeError:
            return False
        except Exception:
            return False
    else:
        return False

def update_cookies_interactive():
    """Interactive cookie setup for private boards"""
    print("\n🔐 Cookie Setup")
    print("=" * 40)
    print("Cookies are needed for:")
    print("• Private boards")
    print("• User profiles you follow")
    print("• Saved pins")
    print("• Higher rate limits")
    print("\n📖 How to get cookies:")
    print("1. Login to Pinterest in your browser")
    print("2. Open Developer Tools (F12)")
    print("3. Go to Application/Storage tab")
    print("4. Copy cookies from pinterest.com")
    print("5. Save as JSON file")
    print(f"\n💾 Save cookies to: {shorten_path(COOKIES_FILE)}")
    response = input("\nHave you saved the cookies file? (y/N): ").strip().lower()
    if response in ['y', 'yes']:
        if check_cookies_available():
            print(f"{NEON_GREEN}✅ Cookies setup completed successfully!{RESET}")
            return True
        else:
            print(f"{RED}❌ Cookies file not found or invalid. Please try again.{RESET}")
            return False
    else:
        print(f"{GRAY}ℹ️  Cookie setup cancelled.{RESET}")
        return False

# -------------------------
# Processing logic
# -------------------------
def download_content(url: str, username: str, use_cookies: bool = False) -> Dict[str, Any]:
    """Download content using gallery-dl and organize files"""
    # Check if it's a short URL and expand if needed
    if url.startswith('https://pin.it/') or url.startswith('http://pin.it/'):
        expanded_url = expand_pinterest_url(url)
        if expanded_url != url:
            url = expanded_url
            # Update username based on expanded URL
            username = extract_username_from_url(url)

    print(f"\n{BOLD}🎯 Processing: {RESET}{NEON_RED}{url}{RESET}")
    print(f"{BOLD}👤 Detected User: {RESET}{NEON_PINK}{username}{RESET}")

    start_time = time.time()
    result = run_gallery_dl(url, cookies=use_cookies)
    result['url'] = url
    result['username'] = username
    result['duration'] = round(time.time() - start_time, 2)
    result['used_cookies'] = use_cookies and COOKIES_FILE.exists()

    if result['success']:
        temp_dir = Path(result.get('temp_dir', RAW_DIR))
        organized_files = organize_downloaded_files(temp_dir, username)
        result['organized_files'] = organized_files
        result['files_count'] = len(organized_files)
    
        # Always use "Download Completed" with capital C
        print(f"{NEON_GREEN}✅ Download Completed in {result['duration']}s{RESET}")
        print(f"{BOLD}📊 Organized {RESET}{len(organized_files)} Files{RESET}")
        try:
            if temp_dir.exists():
                shutil.rmtree(temp_dir)
        except Exception:
            pass

    else:
        error_msg = result.get('stderr', '') or result.get('stdout', '') or 'Unknown error'
        print(f"{RED}❌ Download failed: {error_msg.strip()}{RESET}")
        if use_cookies and not COOKIES_FILE.exists():
            print(f"{NEON_YELLOW}💡 Hint: This might require cookies. Consider running with --update-cookies{RESET}")
        elif any(keyword in error_msg.lower() for keyword in ['auth', 'login', 'unauthorized', 'forbidden']):
            print(f"{NEON_YELLOW}💡 Hint: This appears to be an authentication issue. Consider updating cookies with --update-cookies{RESET}")

    return result

def process_urls(urls: List[str], use_cookies: bool = False):
    success_count = 0
    failed_urls = []
    download_results = []
    
    print("=" * 60)
    
    # Expand all short URLs before processing
    print(f"{BOLD}🔗 Expanding short URLs...{RESET}")
    urls = expand_urls_if_needed(urls)
    
    for i, url in enumerate(urls, 1):
        print(f"{BOLD}📋 Progress: {i}/{len(urls)}{RESET}")
        username = extract_username_from_url(url)
        result = download_content(url, username, use_cookies)
        download_results.append(result)
        if result['success']:
            success_count += 1
            # Add empty line and separator after each completed URL except the last one
            if i < len(urls):
                print()
                print("=" * 60)
        else:
            failed_urls.append(url)
        if i < len(urls):
            wait_time = 5 if use_cookies else 3
            time.sleep(wait_time)
    return success_count, failed_urls, download_results

# -------------------------
# Reporting
# -------------------------
def generate_report(success_count: int, total_urls: int, failed_urls: List, download_results: List, duration: float):
    print("\n" + "=" * 60)
    print(f"{BOLD}📊 DOWNLOAD REPORT{RESET}")
    print("=" * 60)
    print()
    success_rate = (success_count / total_urls) * 100 if total_urls > 0 else 0
    total_files = sum(r.get('files_count', 0) for r in download_results)
    
    print(f"{BOLD}{WHITE}📥 Total URLs Processed: {NEON_YELLOW}{total_urls}{RESET}")
    print(f"{BOLD}{WHITE}✅ Successful Downloads: {NEON_GREEN}{success_count}{RESET}")
    print(f"{BOLD}{WHITE}❌ Failed Downloads: {NEON_RED}{len(failed_urls)}{RESET}")
    print(f"{BOLD}{WHITE}📈 Success Rate: {NEON_GREEN}{success_rate:.1f}%{RESET}")
    print(f"{BOLD}{WHITE}🖼️  Total Files Downloaded: {RESET}{NEON_YELLOW}{total_files}{RESET}")
    print(f"{BOLD}{WHITE}⏱️  Total Time: {RESET}{NEON_YELLOW}{duration:.1f} seconds{RESET}")
    print()
    
    # Extract just the directory names for display
    photos_display = "~~~/" + PHOTOS_DIR.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    videos_display = "~~~/" + VIDEOS_DIR.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    
    photo_count = 0
    video_count = 0
    for result in download_results:
        for file_info in result.get('organized_files', []):
            if file_info['type'] == 'photo':
                photo_count += 1
            else:
                video_count += 1
    
    # New file breakdown format
    print(f"{BOLD}📁 File Breakdown:{RESET}")
    print(f"   {BOLD}📸 Photos Location: {RESET}{NEON_YELLOW}{photos_display}{RESET}")
    print(f"   {BOLD}📸 Photos: {RESET}{photo_count}{RESET}")
    print(f"   {BOLD}🎥 Videos Location: {RESET}{NEON_YELLOW}{videos_display}{RESET}")
    print(f"   {BOLD}🎥 Videos: {RESET}{video_count}{RESET}")
    
    if failed_urls:
        print(f"\n❌ Failed URLs ({len(failed_urls)}):")
        for url in failed_urls:
            print(f"   - {url}")

def save_detailed_report(download_results: List, duration: float):
    script_info = get_script_info()
    report_data = {
        'script_info': script_info,
        'timestamp': datetime.now().isoformat(),
        'total_duration_seconds': round(duration, 2),
        'total_urls_processed': len(download_results),
        'successful_downloads': sum(1 for r in download_results if r['success']),
        'failed_downloads': sum(1 for r in download_results if not r['success']),
        'total_files_downloaded': sum(r.get('files_count', 0) for r in download_results),
        'download_results': [
            {
                'url': r['url'],
                'username': r.get('username', 'unknown'),
                'success': r['success'],
                'duration': r.get('duration', 0),
                'files_count': r.get('files_count', 0),
                'used_cookies': r.get('used_cookies', False),
                'organized_files': r.get('organized_files', []),
                'error': r.get('stderr', '') if not r['success'] else None
            } for r in download_results
        ],
        'directories': {
            'photos': str(PHOTOS_DIR),
            'videos': str(VIDEOS_DIR),
            'logs': shorten_path(LOGS_DIR),
            'cookies': shorten_path(COOKIES_DIR)
        }
    }
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = LOGS_DIR / f"download_report_{timestamp}.json"
    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
    except Exception as e:
        pass
    if any(not r['success'] for r in download_results):
        failed_urls = [r['url'] for r in download_results if not r['success']]
        failed_file = LOGS_DIR / f"failed_urls_{timestamp}.txt"
        try:
            with open(failed_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(failed_urls))
        except Exception:
            pass
    return report_file

# -------------------------
# Banner
# -------------------------
def display_banner():
    print()
    print(f"{BOLD}============================================================{RESET}")
    print(f"{NEON_RED}Pinterest Downloader Automation Script {NEON_GREEN}v{__version__}{RESET}")
    print(f"{BOLD}============================================================{RESET}")
    print()
    
    # Extract just the directory names for display
    photos_display = "~~~/" + PHOTOS_DIR.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    videos_display = "~~~/" + VIDEOS_DIR.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    cookies_display = "~~~/" + COOKIES_FILE.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    urls_display = "~~~/" + PINTEREST_URLS_FILE.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    
    print(f"{BOLD}📸 Photos: {RESET}{NEON_YELLOW}{photos_display}{RESET}")
    print(f"{BOLD}🎥 Videos: {RESET}{NEON_YELLOW}{videos_display}{RESET}")
    print(f"{BOLD}🍪 Cookies: {RESET}{NEON_YELLOW}{cookies_display}{RESET}")
    print(f"{BOLD}📝 URLs File: {RESET}{NEON_YELLOW}{urls_display}{RESET}")
    print()
    print(f"{BOLD}============================================================{RESET}")
    print()

# -------------------------
# Main CLI
# -------------------------
def main():
    parser = argparse.ArgumentParser(description='Pinterest Downloader Automation (gallery-dl backend)')
    parser.add_argument('urls', nargs='*', help='Pinterest URLs to download')
    parser.add_argument('--cookies', '-c', action='store_true', help='Use cookies for authentication (if available)')
    parser.add_argument('--update-cookies', '-u', action='store_true', help='Update cookies interactively')
    parser.add_argument('--list-scripts', action='store_true', help='List all script versions in base and backup directories')
    parser.add_argument('--backup-scripts', action='store_true', help='Backup all scripts to backup directory and remove old versions')
    args = parser.parse_args()

    # Admin commands first
    if args.list_scripts:
        list_script_versions()
        return
    if args.backup_scripts:
        backup_all_scripts()
        return

    # Normal operation
    display_banner()
    ensure_directories()
    ensure_gallery_dl_config()
    if not check_installation():
        return

    use_cookies = args.cookies
    if use_cookies and not check_cookies_available():
        print(f"{RED}❌ Cookies requested but no valid cookies file found.{RESET}")
        response = input("Would you like to set up cookies now? (y/N): ").strip().lower()
        if response in ['y', 'yes']:
            if update_cookies_interactive():
                use_cookies = True
            else:
                use_cookies = False
        else:
            use_cookies = False

    urls = args.urls
    if not urls:
        # Use the hardcoded Pinterest URLs file
        if PINTEREST_URLS_FILE.exists():
            try:
                with open(PINTEREST_URLS_FILE, 'r', encoding='utf-8') as f:
                    urls = [line.strip() for line in f if line.strip() and not line.startswith('#')]
                print(f"{BOLD}📋 Found {len(urls)} URLs to Process.....{RESET}")
                
                # Extract just the directory name for display
                urls_display = "~~~/" + PINTEREST_URLS_FILE.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
                print(f"{BOLD}📝 URLs File: {RESET}{NEON_YELLOW}{urls_display}{RESET}")
                print()
            except Exception as e:
                print(f"{RED}❌ Error reading hardcoded URLs file: {e}{RESET}")
                urls = []
        else:
            print(f"{RED}❌ Hardcoded URLs file not found: {PINTEREST_URLS_FILE}{RESET}")
            print(f"{NEON_YELLOW}💡 Creating empty file at: {PINTEREST_URLS_FILE}{RESET}")
            try:
                PINTEREST_URLS_FILE.parent.mkdir(parents=True, exist_ok=True)
                PINTEREST_URLS_FILE.touch()
                print(f"{NEON_GREEN}✅ Created empty URLs file. Add Pinterest URLs to:{RESET}")
                print(f"{BOLD}   {PINTEREST_URLS_FILE}{RESET}")
            except Exception as e:
                print(f"{RED}❌ Failed to create URLs file: {e}{RESET}")
            return

    if not urls:
        print(f"{RED}❌ No URLs provided and hardcoded URLs file is empty.{RESET}")
        print(f"\n{BOLD}Usage:{RESET}")
        print("   ptdl URL1 URL2 URL3")
        print("   ptdl --cookies URL1 URL2")
        print("   ptdl --update-cookies")
        print("   ptdl --list-scripts")
        print("   ptdl --backup-scripts")
        print(f"\n{BOLD}Or add URLs to the hardcoded file:{RESET}")
        print(f"   {PINTEREST_URLS_FILE}")
        return

    print(f"{BOLD}🚀 Processing {len(urls)} URLs.....{RESET}")

    start_time = time.time()
    success_count, failed_urls, download_results = process_urls(urls, use_cookies)
    end_time = time.time()
    total_duration = end_time - start_time

    generate_report(success_count, len(urls), failed_urls, download_results, total_duration)
    report_file = save_detailed_report(download_results, total_duration)
    
    # Extract just the directory name for display
    report_display = "~~~/" + report_file.relative_to(DOWNLOAD_BASE.parent.parent.parent).as_posix().split("Pinterest/pinterest-dl/")[-1]
    
    print(f"\n{BOLD}{WHITE}📝 Detailed Report: {RESET}{NEON_YELLOW}{report_display}{RESET}")
    print()
    print(f"{BOLD}{NEON_GREEN}🎉 Download completed! ✔{RESET}")
    print()

if __name__ == "__main__":
    main()
