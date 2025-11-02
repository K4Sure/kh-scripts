#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pinterest Downloader Automation Script v1.4.3
Uses gallery-dl as the download engine (embedded config.json)
Global command: ptdl (with auto-version detection)
Organizes downloads into Photos & Videos with proper naming
Quiet output: hides gallery-dl verbose lines unless an error occurs
UTF-8 safe — emojis and ANSI colors included
"""

import os
import sys
import time
import json
import shutil
import subprocess
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

# -------------------------
# Script metadata
# -------------------------
__version__ = "1.4.3"
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
GRAY = '\033[38;5;248m'
BOLD = '\033[1m'
RESET = '\033[0m'

# -------------------------
# Utility functions
# -------------------------
def shorten_path(path: Path) -> str:
    """Shorten path by replacing HOME base with ~~"""
    base_path = Path("/data/data/com.termux/files/home")
    try:
        relative_path = path.relative_to(base_path)
        return f"~~/{relative_path}"
    except Exception:
        return str(path)

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
            # fail silently here — permissions will surface when used
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
# Backup / version management
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
    
    # List 1: Backed up scripts in backup directory
    print(f"{BOLD}💾 Backed Up Scripts:{RESET}")
    print(f"📍 Path: {NEON_YELLOW}{shorten_path(BACKUP_DIR)}{RESET}")
    backup_scripts = list(BACKUP_DIR.glob("pinterest_automation_v*.py"))
    
    if backup_scripts:
        for script in sorted(backup_scripts, key=lambda x: extract_version_from_filename(x.name), reverse=True):
            print(f"   📄 {script.name}")
    else:
        print(f"   ❌ No Backed Up Scripts Found")
    
    # List 2: Scripts in main directory
    print(f"{BOLD}📂 Current Scripts:{RESET}")
    print(f"📍 Path: {NEON_YELLOW}{shorten_path(BASE_DIR)}{RESET}")
    main_scripts = list(BASE_DIR.glob("pinterest_automation_v*.py"))
    current_script = Path(__file__).name
    
    if main_scripts:
        for script in sorted(main_scripts, key=lambda x: extract_version_from_filename(x.name), reverse=True):
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

    # Ensure backup directory exists
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    # Generate timestamp for this backup session
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # Find all scripts in base directory
    script_files = [f for f in BASE_DIR.iterdir()
                   if f.is_file() and f.name.startswith('pinterest_automation_v') and f.suffix == '.py']

    if not script_files:
        print("❌ No Pinterest automation scripts found to backup")
        return False

    # Find the latest script (highest version)
    latest_script = None
    latest_version = (0, 0, 0)

    for script_file in script_files:
        version = extract_version_from_filename(script_file.name)
        if version > latest_version:
            latest_version = version
            latest_script = script_file

    print(f"{BOLD}🔍 Found {len(script_files)} Script(s){RESET}")
    print(f"{BOLD}⭐ Latest Version: {RED}{latest_script.name}{RESET}")

    backup_success = []
    backup_failed = []

    # Backup all scripts with timestamps
    print(f"{BOLD}📤 Backing Up Scripts...{RESET}")
    print(f"📍 Backup Path: {NEON_YELLOW}{shorten_path(BACKUP_DIR)}{RESET}")
    for script_file in script_files:
        source_path = script_file

        # Add timestamp to backup filename
        name_without_ext = script_file.stem
        backup_filename = f"{name_without_ext}_{timestamp}.py"
        dest_path = BACKUP_DIR / backup_filename

        try:
            shutil.copy2(source_path, dest_path)
            backup_success.append(f"{script_file.name} → {backup_filename}")
            print(f"   {RED}📄 {script_file.name}{RESET}")
            print(f"      {NEON_GREEN}➜ {backup_filename}{RESET}")
        except Exception as e:
            backup_failed.append(f"{script_file.name} - {str(e)}")
            print(f"   ❌ Failed: {script_file.name} - {e}")

    # Remove all scripts except the latest version
    print(f"{GRAY}🧹 Cleaning Up Old Versions...{RESET}")
    removed_count = 0
    for script_file in script_files:
        if script_file != latest_script:
            try:
                script_file.unlink()
                print(f"   ✅ Removed: {script_file.name}")
                removed_count += 1
            except Exception as e:
                print(f"   ❌ Failed to remove {script_file.name}: {e}")

    # Summary
    print(f"{BOLD}📊 Backup Summary:{RESET}")
    print(f"   ✅ Successfully Backed Up: {NEON_GREEN}{len(backup_success)} Script(s){RESET}")
    print(f"   ❌ Failed to Backup: {RED}{len(backup_failed)} Script(s){RESET}")
    print(f"   🧹 Removed Old Versions: {GRAY}{removed_count} Script(s){RESET}")
    print(f"   {BOLD}⭐ Kept Latest: {RED}{latest_script.name}{RESET}")
    print()

    if backup_failed:
        print(f"⚠️  Some backups failed:")
        for failed in backup_failed:
            print(f"   - {failed}")

    return len(backup_failed) == 0


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
            print(f"{NEON_GREEN}✔ Created gallery-dl config: {shorten_path(CONFIG_FILE)}{RESET}")
        else:
            print(f"{NEON_YELLOW}ℹ️  gallery-dl config already exists: {shorten_path(CONFIG_FILE)}{RESET}")
        return True
    except Exception as e:
        print(f"{RED}❌ Failed to create gallery-dl config: {e}{RESET}")
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
        # optionally verify version
        result = subprocess.run(["gallery-dl", "--version"], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print(f"{NEON_GREEN}✅ gallery-dl found: {result.stdout.strip()}{RESET}")
            return True
        else:
            print(f"{RED}❌ gallery-dl appears installed but returned non-zero on --version{RESET}")
            return False
    except Exception:
        print(f"{RED}❌ gallery-dl not found or not runnable{RESET}")
        return False

# -------------------------
# URL / filename helpers
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
    print(f"{BOLD}📁 Organizing files for user: {username}{RESET}")
    image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'}
    video_extensions = {'.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv'}
    moved_files = []

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
                    print(f"  {NEON_GREEN}✅ {file_path.name} → {new_filename}{RESET}")
                except Exception as e:
                    print(f"  {RED}❌ Failed to move {file_path.name}: {e}{RESET}")
    except Exception as e:
        print(f"{RED}❌ Error while organizing files: {e}{RESET}")

    return moved_files

# -------------------------
# Running gallery-dl quietly
# -------------------------
def run_gallery_dl(url: str, cookies: bool = False, timeout: int = 600) -> Dict[str, Any]:
    """
    Run gallery-dl with config set to CONFIG_FILE and destination to a temporary folder under RAW_DIR.
    Suppress gallery-dl stdout/stderr unless an error occurs. Return result dict.
    """
    timestamp = int(time.time())
    temp_dir = RAW_DIR / f"temp_{timestamp}"
    temp_dir.mkdir(parents=True, exist_ok=True)

    cmd = ["gallery-dl", "--config", str(CONFIG_FILE), "--destination", str(temp_dir), url]
    if cookies and COOKIES_FILE.exists():
        cmd = ["gallery-dl", "--config", str(CONFIG_FILE), "--cookies", str(COOKIES_FILE), "--destination", str(temp_dir), url]

    # Run and capture outputs
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
    # Only print minimal user-friendly messages; on error, show stderr to assist debugging.
    if success:
        return {
            'success': True,
            'returncode': proc.returncode,
            'stdout': proc.stdout,
            'stderr': proc.stderr,
            'command': ' '.join(cmd),
            'temp_dir': str(temp_dir)
        }
    else:
        return {
            'success': False,
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
                print(f"{NEON_GREEN}✅ Cookies file found and appears valid{RESET}")
                return True
            else:
                print(f"{NEON_YELLOW}⚠️  Cookies file exists but appears empty{RESET}")
                return False
        except json.JSONDecodeError:
            print(f"{NEON_YELLOW}⚠️  Cookies file exists but is not valid JSON{RESET}")
            return False
        except Exception:
            return False
    else:
        print(f"{GRAY}ℹ️  No cookies file found - using public access only{RESET}")
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
    if 'pin.it' in url:
        print(f"{NEON_YELLOW}⚠️  Warning: Shortened 'pin.it' URLs may not always resolve; prefer full pinterest.com URLs{RESET}")

    print(f"\n{BOLD}🎯 Processing: {url}{RESET}")
    print(f"{BOLD}👤 Detected user: {username}{RESET}")

    start_time = time.time()
    result = run_gallery_dl(url, cookies=use_cookies)
    result['url'] = url
    result['username'] = username
    result['duration'] = round(time.time() - start_time, 2)
    result['used_cookies'] = use_cookies and COOKIES_FILE.exists()

    if result['success']:
        # Organize downloaded files from temp folder
        temp_dir = Path(result.get('temp_dir', RAW_DIR))
        organized_files = organize_downloaded_files(temp_dir, username)
        result['organized_files'] = organized_files
        result['files_count'] = len(organized_files)
        print(f"{NEON_GREEN}✅ Download completed in {result['duration']}s{RESET}")
        print(f"{BOLD}📊 Organized {len(organized_files)} files{RESET}")
        # clean up temp dir
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
    print(f"\n{BOLD}🚀 Processing {len(urls)} URLs...{RESET}")
    print("=" * 50)
    for i, url in enumerate(urls, 1):
        print(f"\n📋 Progress: {i}/{len(urls)}")
        username = extract_username_from_url(url)
        result = download_content(url, username, use_cookies)
        download_results.append(result)
        if result['success']:
            success_count += 1
        else:
            failed_urls.append(url)
        if i < len(urls):
            wait_time = 5 if use_cookies else 3
            print(f"⏳ Waiting {wait_time} seconds...")
            time.sleep(wait_time)
    return success_count, failed_urls, download_results

# -------------------------
# Reporting
# -------------------------
def generate_report(success_count: int, total_urls: int, failed_urls: List, download_results: List, duration: float):
    print("\n" + "=" * 60)
    print("📊 DOWNLOAD REPORT")
    print("=" * 60)
    success_rate = (success_count / total_urls) * 100 if total_urls > 0 else 0
    total_files = sum(r.get('files_count', 0) for r in download_results)
    print(f"📥 Total URLs processed: {total_urls}")
    print(f"✅ Successful downloads: {success_count}")
    print(f"❌ Failed downloads: {len(failed_urls)}")
    print(f"📈 Success rate: {success_rate:.1f}%")
    print(f"🖼️  Total files downloaded: {total_files}")
    print(f"⏱️  Total time: {duration:.1f} seconds")
    print(f"📸 Photos location: {PHOTOS_DIR}")
    print(f"🎥 Videos location: {VIDEOS_DIR}")
    photo_count = 0
    video_count = 0
    for result in download_results:
        for file_info in result.get('organized_files', []):
            if file_info['type'] == 'photo':
                photo_count += 1
            else:
                video_count += 1
    print(f"\n📁 File breakdown:")
    print(f"   📸 Photos: {photo_count}")
    print(f"   🎥 Videos: {video_count}")
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
        print(f"{RED}❌ Failed to write report: {e}{RESET}")
    if any(not r['success'] for r in download_results):
        failed_urls = [r['url'] for r in download_results if not r['success']]
        failed_file = LOGS_DIR / f"failed_urls_{timestamp}.txt"
        try:
            with open(failed_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(failed_urls))
            print(f"{NEON_GREEN}💾 Failed URLs saved to: {shorten_path(failed_file)}{RESET}")
        except Exception:
            pass
    return report_file

# -------------------------
# Banner
# -------------------------
def display_banner():
    print(f"{RED}🎨" + "="*50 + "🎨" + RESET)
    print(f"      Pinterest Downloader Automation Script")
    print(f"               Version {__version__}")
    print(f"{RED}🎨" + "="*50 + "🎨" + RESET)
    print(f"{NEON_YELLOW}📁 Base Directory: {shorten_path(DOWNLOAD_BASE)}{RESET}")
    print(f"{NEON_YELLOW}💾 Backup Directory: {shorten_path(BACKUP_DIR)}{RESET}")
    print(f"{NEON_YELLOW}📸 Photos: {PHOTOS_DIR}{RESET}")
    print(f"{NEON_YELLOW}🎥 Videos: {VIDEOS_DIR}{RESET}")
    print(f"{NEON_YELLOW}🍪 Cookies: {shorten_path(COOKIES_FILE)}{RESET}")
    print(f"{RED}🎨" + "="*50 + "🎨" + RESET)

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

    # Handle admin commands
    if args.list_scripts:
        list_script_versions()
        return
    if args.backup_scripts:
        backup_all_scripts()
        return

    # Normal operation
    display_banner()
    ensure_directories()
    # write config if missing
    ensure_gallery_dl_config()
    # check gallery-dl
    if not check_installation():
        return

    use_cookies = args.cookies
    if use_cookies:
        if not check_cookies_available():
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
        url_file = BASE_DIR / "pinterest_urls.txt"
        if url_file.exists():
            try:
                with open(url_file, 'r', encoding='utf-8') as f:
                    urls = [line.strip() for line in f if line.strip() and not line.startswith('#')]
            except Exception:
                urls = []
        if not urls:
            print(f"{RED}❌ No URLs provided. Usage:{RESET}")
            print("   ptdl URL1 URL2 URL3")
            print("   ptdl --cookies URL1 URL2")
            print("   ptdl --update-cookies")
            print("   ptdl --list-scripts")
            print("   ptdl --backup-scripts")
            print("\nOr create a file: pinterest_urls.txt in the script directory")
            return

    print(f"{BOLD}📋 Found {len(urls)} URLs to process{RESET}")
    print(f"\n{NEON_YELLOW}⚠️  About to download {len(urls)} URLs.{RESET}")
    if use_cookies:
        print(f"{NEON_YELLOW}🔐 Using cookies for authentication{RESET}")
    else:
        print(f"{GRAY}ℹ️  Using public access (no cookies){RESET}")

    response = input("Continue? (y/N): ").strip().lower()
    if response not in ['y', 'yes']:
        print("Download cancelled.")
        return

    start_time = time.time()
    success_count, failed_urls, download_results = process_urls(urls, use_cookies)
    end_time = time.time()
    total_duration = end_time - start_time

    generate_report(success_count, len(urls), failed_urls, download_results, total_duration)
    report_file = save_detailed_report(download_results, total_duration)
    print(f"\n📝 Detailed report saved to: {shorten_path(report_file)}")
    print("🎉 Download completed!")

if __name__ == "__main__":
    main()
```0
