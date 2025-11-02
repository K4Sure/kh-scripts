#!/usr/bin/env python3
"""
Pinterest Downloader Automation Script v1.1.0
Global command: ptdl
Organizes downloads into Photos & Videos with proper naming
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
from typing import List, Dict, Any, Optional

# Script version - update this with each major change
__version__ = "1.1.0"
__author__ = "Pinterest Automation Script"
__created__ = "2024-10-20"

# Base directories
BASE_DIR = Path("/data/data/com.termux/files/home/kh-scripts/pinterest")
BACKUP_DIR = BASE_DIR / "backup"

# Download directories (as per your specification)
DOWNLOAD_BASE = Path("/storage/emulated/0/Download/Social Media/Pinterest/pinterest-dl")
PHOTOS_DIR = DOWNLOAD_BASE / "ptdl Photos"
VIDEOS_DIR = DOWNLOAD_BASE / "ptdl Videos"
SEARCHES_DIR = DOWNLOAD_BASE / "ptdl searches"
COOKIES_DIR = DOWNLOAD_BASE / "ptdl cookies"
URLS_DIR = DOWNLOAD_BASE / "ptdl urls"
LOGS_DIR = DOWNLOAD_BASE / "ptdl logs"

def ensure_directories():
    """Ensure all required directories exist"""
    directories = [
        BASE_DIR, BACKUP_DIR, DOWNLOAD_BASE, 
        PHOTOS_DIR, VIDEOS_DIR, SEARCHES_DIR,
        COOKIES_DIR, URLS_DIR, LOGS_DIR
    ]
    
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)
        print(f"✓ Directory ensured: {directory}")

def get_script_info():
    """Get information about this script"""
    script_path = Path(__file__)
    return {
        'name': script_path.name,
        'version': __version__,
        'path': str(script_path),
        'base_dir': str(BASE_DIR),
        'backup_dir': str(BACKUP_DIR),
        'download_base': str(DOWNLOAD_BASE),
        'created': __created__,
        'author': __author__
    }

def backup_script():
    """Create a backup of this script with version and timestamp"""
    try:
        script_path = Path(__file__)
        if script_path.exists():
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_name = f"pinterest_automation_{__version__.replace('.', '_')}_{timestamp}.py"
            backup_path = BACKUP_DIR / backup_name
            
            shutil.copy2(script_path, backup_path)
            print(f"✓ Script backed up to: {backup_path}")
            return str(backup_path)
    except Exception as e:
        print(f"⚠️  Could not create backup: {e}")
    return None

def check_installation():
    """Check if pinterest-dl is properly installed"""
    try:
        result = subprocess.run(
            ["pinterest-dl", "--version"],
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode == 0:
            print(f"✅ pinterest-dl found: {result.stdout.strip()}")
            return True
        else:
            print("❌ pinterest-dl is installed but not working properly")
            return False
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ pinterest-dl not found. Please install with: pip install -e .")
        return False

def extract_username_from_url(url: str) -> str:
    """Extract username from Pinterest URL"""
    # Remove protocol and www
    clean_url = url.replace('https://', '').replace('http://', '').replace('www.', '')
    
    # Extract username from various URL patterns
    if 'pinterest.com/' in clean_url:
        parts = clean_url.split('pinterest.com/')[1].split('/')
        if parts and parts[0] and not parts[0].startswith('pin') and not parts[0].startswith('search'):
            return parts[0].replace('-', '_').replace('.', '_')
    
    return "unknown"

def get_next_file_number(directory: Path, username: str, extension: str) -> int:
    """Get the next file number for the username and extension"""
    pattern = f"{username}_*.{extension}"
    existing_files = list(directory.glob(pattern))
    
    if not existing_files:
        return 1
    
    numbers = []
    for file in existing_files:
        try:
            # Extract number from filename like "username_001.jpg"
            stem = file.stem
            if stem.startswith(username + "_"):
                num_part = stem[len(username) + 1:]
                if num_part.isdigit():
                    numbers.append(int(num_part))
        except (ValueError, IndexError):
            continue
    
    return max(numbers) + 1 if numbers else 1

def organize_downloaded_files(download_dir: Path, username: str):
    """Organize downloaded files into Photos and Videos with proper naming"""
    print(f"📁 Organizing files for user: {username}")
    
    # Supported image and video extensions
    image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'}
    video_extensions = {'.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv'}
    
    moved_files = []
    
    for file_path in download_dir.rglob('*'):
        if file_path.is_file():
            extension = file_path.suffix.lower()
            
            if extension in image_extensions:
                target_dir = PHOTOS_DIR
            elif extension in video_extensions:
                target_dir = VIDEOS_DIR
            else:
                # Skip unsupported file types
                continue
            
            # Get next file number
            next_num = get_next_file_number(target_dir, username, extension[1:])
            new_filename = f"{username}_{next_num:03d}{extension}"
            new_path = target_dir / new_filename
            
            # Move and rename the file
            try:
                shutil.move(str(file_path), str(new_path))
                moved_files.append({
                    'original': file_path.name,
                    'new': new_filename,
                    'type': 'photo' if extension in image_extensions else 'video',
                    'path': str(new_path)
                })
                print(f"  ✅ {file_path.name} → {new_filename}")
            except Exception as e:
                print(f"  ❌ Failed to move {file_path.name}: {e}")
    
    return moved_files

def run_pinterest_dl_command(command: List[str], timeout: int = 300) -> Dict[str, Any]:
    """Run a pinterest-dl command with proper error handling"""
    try:
        print(f"🔧 Running: {' '.join(command)}")
        
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        
        return {
            'success': result.returncode == 0,
            'returncode': result.returncode,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'command': ' '.join(command)
        }
        
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'returncode': -1,
            'stdout': '',
            'stderr': f'Command timed out after {timeout} seconds',
            'command': ' '.join(command)
        }
    except Exception as e:
        return {
            'success': False,
            'returncode': -1,
            'stdout': '',
            'stderr': str(e),
            'command': ' '.join(command)
        }

def download_content(url: str, username: str, use_cookies: bool = False) -> Dict[str, Any]:
    """Download content using pinterest-dl and organize files"""
    # Create a temporary download directory for this URL
    temp_dir = DOWNLOAD_BASE / f"temp_{int(time.time())}"
    temp_dir.mkdir(exist_ok=True)
    
    print(f"\n🎯 Processing: {url}")
    print(f"👤 Detected user: {username}")
    
    start_time = time.time()
    
    # Build the command based on URL type
    if 'search' in url.lower():
        command = ["pinterest-dl", "search", url]
    else:
        command = ["pinterest-dl", "scrape", url]
    
    # Add output directory and options
    command.extend(["--output", str(temp_dir), "--verbose"])
    
    # Add cookies if requested
    if use_cookies:
        cookies_file = COOKIES_DIR / "cookies.json"
        if cookies_file.exists():
            command.extend(["--cookies", str(cookies_file)])
    
    # Run the command
    result = run_pinterest_dl_command(command)
    result['url'] = url
    result['username'] = username
    result['temp_dir'] = str(temp_dir)
    result['duration'] = round(time.time() - start_time, 2)
    
    if result['success']:
        print(f"✅ Download completed in {result['duration']}s")
        
        # Organize the downloaded files
        organized_files = organize_downloaded_files(temp_dir, username)
        result['organized_files'] = organized_files
        result['files_count'] = len(organized_files)
        
        print(f"📊 Organized {len(organized_files)} files")
        
        # Clean up temp directory
        try:
            shutil.rmtree(temp_dir)
            print(f"🧹 Cleaned up temporary directory")
        except:
            pass
            
    else:
        print(f"❌ Download failed: {result.get('stderr', 'Unknown error')}")
    
    return result

def save_cookies_interactive():
    """Interactive cookie setup for private boards"""
    print("\n🔐 Cookie Setup (Optional)")
    print("=" * 40)
    print("Cookies are needed for private boards and higher rate limits")
    
    response = input("\nDo you want to set up cookies? (y/N): ").strip().lower()
    
    if response in ['y', 'yes']:
        print("\n📖 How to get cookies:")
        print("1. Login to Pinterest in your browser")
        print("2. Open Developer Tools (F12)")
        print("3. Go to Application/Storage tab")
        print("4. Copy cookies from pinterest.com")
        print("5. Save as JSON file in cookies directory")
        
        input("\nPress Enter when ready to continue...")
        
        print(f"💾 Save cookies to: {COOKIES_DIR / 'cookies.json'}")
        return True
    return False

def process_urls(urls: List[str], use_cookies: bool = False):
    """Process multiple URLs"""
    success_count = 0
    failed_urls = []
    download_results = []
    
    print(f"\n🚀 Processing {len(urls)} URLs...")
    print("=" * 50)
    
    for i, url in enumerate(urls, 1):
        print(f"\n📋 Progress: {i}/{len(urls)}")
        
        # Extract username from URL
        username = extract_username_from_url(url)
        
        # Download and organize content
        result = download_content(url, username, use_cookies)
        download_results.append(result)
        
        if result['success']:
            success_count += 1
        else:
            failed_urls.append(url)
        
        # Be respectful to Pinterest - add delay between requests
        if i < len(urls):
            wait_time = 5 if use_cookies else 3
            print(f"⏳ Waiting {wait_time} seconds...")
            time.sleep(wait_time)
    
    return success_count, failed_urls, download_results

def generate_report(success_count: int, total_urls: int, failed_urls: List, 
                   download_results: List, duration: float):
    """Generate a comprehensive download report"""
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
    
    # File type breakdown
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
    """Save detailed report to JSON file"""
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
                'organized_files': r.get('organized_files', []),
                'error': r.get('stderr', '') if not r['success'] else None
            }
            for r in download_results
        ],
        'directories': {
            'photos': str(PHOTOS_DIR),
            'videos': str(VIDEOS_DIR),
            'logs': str(LOGS_DIR)
        }
    }
    
    # Save main report
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = LOGS_DIR / f"download_report_{timestamp}.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report_data, f, indent=2, ensure_ascii=False)
    
    # Save failed URLs separately for retry
    if any(not r['success'] for r in download_results):
        failed_urls = [r['url'] for r in download_results if not r['success']]
        failed_file = LOGS_DIR / f"failed_urls_{timestamp}.txt"
        with open(failed_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(failed_urls))
        print(f"💾 Failed URLs saved to: {failed_file}")
    
    return report_file

def display_banner():
    """Display script banner with version information"""
    print("🎨" + "="*50 + "🎨")
    print("      Pinterest Downloader Automation Script")
    print(f"               Version {__version__}")
    print("🎨" + "="*50 + "🎨")
    print(f"📁 Base Directory: {BASE_DIR}")
    print(f"💾 Backup Directory: {BACKUP_DIR}")
    print(f"📸 Photos: {PHOTOS_DIR}")
    print(f"🎥 Videos: {VIDEOS_DIR}")
    print(f"📝 Script: {Path(__file__).name}")
    print("🎨" + "="*50 + "🎨")

def main():
    """Main automation function with command line support"""
    parser = argparse.ArgumentParser(description='Pinterest Downloader Automation')
    parser.add_argument('urls', nargs='*', help='Pinterest URLs to download')
    parser.add_argument('--cookies', '-c', action='store_true', help='Use cookies for authentication')
    parser.add_argument('--version', '-v', action='store_true', help='Show version information')
    
    args = parser.parse_args()
    
    # Show version and exit
    if args.version:
        print(f"ptdl (Pinterest Downloader) version {__version__}")
        return
    
    # Display banner
    display_banner()
    
    # Ensure directories exist
    ensure_directories()
    
    # Create backup of this script
    backup_path = backup_script()
    
    # Check installation
    if not check_installation():
        return
    
    # Get URLs from command line or file
    urls = args.urls
    if not urls:
        # Read from default URL file
        url_file = BASE_DIR / "pinterest_urls.txt"
        if url_file.exists():
            with open(url_file, 'r', encoding='utf-8') as f:
                urls = [line.strip() for line in f if line.strip() and not line.startswith('#')]
        
        if not urls:
            print("❌ No URLs provided. Usage:")
            print("   ptdl URL1 URL2 URL3")
            print("   ptdl --cookies URL1 URL2")
            print("   ptdl --version")
            print("\nOr create a file: pinterest_urls.txt in the script directory")
            return
    
    print(f"📋 Found {len(urls)} URLs to process")
    
    # Ask about cookies if not specified
    use_cookies = args.cookies
    if not use_cookies:
        use_cookies = save_cookies_interactive()
    
    # Confirm before starting
    print(f"\n⚠️  About to download {len(urls)} URLs.")
    if use_cookies:
        print("🔐 Cookies will be used for authentication")
    
    response = input("Continue? (y/N): ").strip().lower()
    
    if response not in ['y', 'yes']:
        print("Download cancelled.")
        return
    
    # Start download process
    start_time = time.time()
    success_count, failed_urls, download_results = process_urls(urls, use_cookies)
    end_time = time.time()
    
    total_duration = end_time - start_time
    
    # Generate report
    generate_report(success_count, len(urls), failed_urls, download_results, total_duration)
    
    # Save detailed report
    report_file = save_detailed_report(download_results, total_duration)
    
    print(f"\n📝 Detailed report saved to: {report_file}")
    if backup_path:
        print(f"💾 Script backup: {backup_path}")
    print("🎉 Download completed!")

if __name__ == "__main__":
    main()
