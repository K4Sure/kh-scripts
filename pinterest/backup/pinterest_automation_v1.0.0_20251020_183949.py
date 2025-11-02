#!/usr/bin/env python3
"""
Pinterest Downloader Automation Script v1.0.0
Uses the pinterest-dl command line interface for maximum compatibility

Base Directory: /data/data/com.termux/files/home/kh-scripts/pinterest
Backup Directory: /data/data/com.termux/files/home/kh-scripts/pinterest/backup
"""

import os
import sys
import time
import json
import shutil
import subprocess
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

# Script version - update this with each major change
__version__ = "1.0.0"
__author__ = "Pinterest Automation Script"
__created__ = "2024-10-20"

# Base directories
BASE_DIR = Path("/data/data/com.termux/files/home/kh-scripts/pinterest")
BACKUP_DIR = BASE_DIR / "backup"
SCRIPTS_DIR = BASE_DIR

def ensure_directories():
    """Ensure all required directories exist"""
    directories = [BASE_DIR, BACKUP_DIR, SCRIPTS_DIR]
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
        'created': __created__,
        'author': __author__
    }

def backup_script():
    """Create a backup of this script"""
    try:
        script_path = Path(__file__)
        if script_path.exists():
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_name = f"{script_path.stem}_backup_{timestamp}{script_path.suffix}"
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

def setup_download_directories():
    """Create organized download directories within base directory"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    downloads_dir = BASE_DIR / f"downloads_{timestamp}"
    
    directories = {
        'base': downloads_dir,
        'pins': downloads_dir / "pins",
        'boards': downloads_dir / "boards", 
        'profiles': downloads_dir / "profiles",
        'searches': downloads_dir / "searches",
        'cookies': downloads_dir / "cookies",
        'logs': downloads_dir / "logs",
        'urls': downloads_dir / "urls",
        'metadata': downloads_dir / "metadata"
    }
    
    for dir_path in directories.values():
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"✓ Created: {dir_path}")
    
    return directories

def create_url_template():
    """Create a comprehensive URL template with examples"""
    template_content = f"""# Pinterest Downloader URL List
# Script Version: {__version__}
# Created: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
# Base Directory: {BASE_DIR}

# Add your Pinterest URLs below (one per line)
# Remove the # from the beginning to activate a URL

# === SINGLE PINS ===
# https://www.pinterest.com/pin/1234567890/
# https://pin.it/abc123

# === BOARDS ===
# https://www.pinterest.com/username/board-name/
# https://www.pinterest.com/username/my-board/

# === USER PROFILES ===
# https://www.pinterest.com/username/
# https://www.pinterest.com/username/_saved/

# === SEARCH RESULTS ===
# https://www.pinterest.com/search/pins/?q=nature%20photography
# https://www.pinterest.com/search/pins/?q=recipes&rs=typed

# === EXAMPLE ACTIVE URLS (remove the # to use) ===
# https://www.pinterest.com/pin/1234567890/
# https://www.pinterest.com/username/my-awesome-board/
"""
    
    url_file = BASE_DIR / "pinterest_urls.txt"
    if not url_file.exists():
        with open(url_file, 'w', encoding='utf-8') as f:
            f.write(template_content)
        print(f"✓ Created URL template: {url_file}")
        print("💡 Please edit this file and add your actual Pinterest URLs")
    
    return url_file

def read_urls_from_file(file_path=None):
    """Read and validate Pinterest URLs from file"""
    if file_path is None:
        file_path = BASE_DIR / "pinterest_urls.txt"
    
    urls = []
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as file:
            for line_num, line in enumerate(file, 1):
                line = line.strip()
                # Skip empty lines and comments
                if not line or line.startswith('#'):
                    continue
                
                # Validate Pinterest URL
                if any(domain in line for domain in ['pinterest.com', 'pin.it']):
                    urls.append({
                        'url': line,
                        'type': categorize_url(line),
                        'line_number': line_num
                    })
                else:
                    print(f"⚠️  Warning: Line {line_num} doesn't look like a Pinterest URL: {line}")
        
        print(f"✓ Loaded {len(urls)} valid Pinterest URLs from {file_path}")
    else:
        print(f"✗ URL file not found: {file_path}")
        create_url_template()
    
    return urls

def categorize_url(url: str) -> str:
    """Categorize the URL type for proper handling"""
    url_lower = url.lower()
    
    if '/pin/' in url_lower or 'pin.it' in url_lower:
        return 'pin'
    elif '/board/' in url_lower:
        return 'board'
    elif '/search/' in url_lower:
        return 'search'
    elif '/_saved/' in url_lower:
        return 'saved'
    else:
        # Assume it's a user profile
        return 'profile'

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

def download_content(url_info: Dict, download_dir: Path, use_cookies: bool = False) -> Dict[str, Any]:
    """Download content using the appropriate pinterest-dl command"""
    url = url_info['url']
    url_type = url_info['type']
    
    print(f"\n🎯 Processing {url_type}: {url}")
    
    start_time = time.time()
    
    # Build the base command
    if url_type == 'search':
        command = ["pinterest-dl", "search", url]
    else:
        command = ["pinterest-dl", "scrape", url]
    
    # Add output directory
    command.extend(["--output", str(download_dir)])
    
    # Add verbose logging
    command.append("--verbose")
    
    # Add cookies if requested
    if use_cookies:
        cookies_file = download_dir.parent / "cookies" / "cookies.json"
        if cookies_file.exists():
            command.extend(["--cookies", str(cookies_file)])
    
    # Add limits for large collections
    if url_type in ['board', 'profile', 'saved']:
        command.extend(["--limit", "50"])  # Limit to 50 items
    
    # Run the command
    result = run_pinterest_dl_command(command)
    result['url'] = url
    result['type'] = url_type
    result['duration'] = round(time.time() - start_time, 2)
    
    if result['success']:
        print(f"✅ Success: Downloaded in {result['duration']}s")
        if result['stdout']:
            # Extract download count from output if possible
            lines = result['stdout'].split('\n')
            for line in lines:
                if 'downloaded' in line.lower() or 'saved' in line.lower():
                    print(f"📋 {line.strip()}")
    else:
        print(f"❌ Failed: {result.get('stderr', 'Unknown error')}")
    
    return result

def save_cookies_interactive(directories: Dict):
    """Interactive cookie setup for private boards"""
    print("\n🔐 Cookie Setup (Optional)")
    print("=" * 40)
    print("Cookies are needed for:")
    print("• Private boards")
    print("• User profiles you follow") 
    print("• Saved pins")
    print("• Higher rate limits")
    
    response = input("\nDo you want to set up cookies? (y/N): ").strip().lower()
    
    if response in ['y', 'yes']:
        print("\n📖 How to get cookies:")
        print("1. Login to Pinterest in your browser")
        print("2. Open Developer Tools (F12)")
        print("3. Go to Application/Storage tab")
        print("4. Copy cookies from pinterest.com")
        print("5. Save as JSON file in cookies directory")
        
        input("\nPress Enter when ready to continue...")
        
        # Run the login command to help with cookie setup
        print("\n🛠️  Running login helper...")
        login_result = run_pinterest_dl_command([
            "pinterest-dl", "login", "--help"
        ])
        
        if login_result['success']:
            print("✅ Login helper available")
        else:
            print("ℹ️  Manual cookie setup required")
        
        cookies_dir = directories['cookies']
        print(f"💾 Save cookies to: {cookies_dir}")
        
        return True
    return False

def batch_download(urls: List[Dict], directories: Dict, use_cookies: bool = False):
    """Process all URLs in batch"""
    success_count = 0
    failed_urls = []
    download_results = []
    
    print(f"\n🚀 Starting batch download of {len(urls)} URLs...")
    print("=" * 60)
    
    for i, url_info in enumerate(urls, 1):
        print(f"\n📋 Progress: {i}/{len(urls)}")
        
        # Determine the appropriate download directory
        url_type = url_info['type']
        download_dir = directories.get(url_type + 's', directories['base'])
        
        # Download the content
        result = download_content(url_info, download_dir, use_cookies)
        download_results.append(result)
        
        if result['success']:
            success_count += 1
        else:
            failed_urls.append(url_info)
        
        # Be respectful to Pinterest - add delay between requests
        if i < len(urls):  # Don't wait after the last one
            wait_time = 5 if use_cookies else 3
            print(f"⏳ Waiting {wait_time} seconds...")
            time.sleep(wait_time)
    
    return success_count, failed_urls, download_results

def generate_report(success_count: int, total_urls: int, failed_urls: List, 
                   download_results: List, directories: Dict, duration: float):
    """Generate a comprehensive download report"""
    print("\n" + "=" * 60)
    print("📊 DOWNLOAD REPORT")
    print("=" * 60)
    
    success_rate = (success_count / total_urls) * 100 if total_urls > 0 else 0
    
    print(f"📥 Total URLs processed: {total_urls}")
    print(f"✅ Successful downloads: {success_count}")
    print(f"❌ Failed downloads: {len(failed_urls)}")
    print(f"📈 Success rate: {success_rate:.1f}%")
    print(f"⏱️  Total time: {duration:.1f} seconds")
    print(f"💾 Download location: {directories['base']}")
    
    # Breakdown by type
    type_stats = {}
    for result in download_results:
        url_type = result['type']
        if url_type not in type_stats:
            type_stats[url_type] = {'total': 0, 'success': 0}
        type_stats[url_type]['total'] += 1
        if result['success']:
            type_stats[url_type]['success'] += 1
    
    print(f"\n📈 Breakdown by type:")
    for url_type, stats in type_stats.items():
        rate = (stats['success'] / stats['total']) * 100
        print(f"   {url_type:8}: {stats['success']}/{stats['total']} ({rate:.1f}%)")
    
    if failed_urls:
        print(f"\n❌ Failed URLs ({len(failed_urls)}):")
        for url_info in failed_urls:
            print(f"   - {url_info['url']} (line {url_info['line_number']})")

def save_detailed_report(download_results: List, directories: Dict, duration: float):
    """Save detailed report to JSON file"""
    script_info = get_script_info()
    
    report_data = {
        'script_info': script_info,
        'timestamp': datetime.now().isoformat(),
        'total_duration_seconds': round(duration, 2),
        'total_urls_processed': len(download_results),
        'successful_downloads': sum(1 for r in download_results if r['success']),
        'failed_downloads': sum(1 for r in download_results if not r['success']),
        'download_results': [
            {
                'url': r['url'],
                'type': r['type'],
                'success': r['success'],
                'duration': r.get('duration', 0),
                'error': r.get('stderr', '') if not r['success'] else None,
                'command': r.get('command', '')
            }
            for r in download_results
        ],
        'directories': {k: str(v) for k, v in directories.items()}
    }
    
    # Save main report
    report_file = directories['logs'] / "download_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report_data, f, indent=2, ensure_ascii=False)
    
    # Save failed URLs separately for retry
    if any(not r['success'] for r in download_results):
        failed_urls = [r['url'] for r in download_results if not r['success']]
        failed_file = directories['logs'] / "failed_urls.txt"
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
    print(f"📝 Script: {Path(__file__).name}")
    print("🎨" + "="*50 + "🎨")

def main():
    """Main automation function"""
    # Display banner
    display_banner()
    
    # Ensure directories exist
    ensure_directories()
    
    # Create backup of this script
    backup_path = backup_script()
    
    # Check installation
    if not check_installation():
        return
    
    # Setup download directories
    directories = setup_download_directories()
    
    # Read URLs
    urls = read_urls_from_file()
    
    if not urls:
        print("\n❌ No valid URLs found. Please add Pinterest URLs to 'pinterest_urls.txt'")
        print("💡 A template has been created for you.")
        return
    
    # Display URL summary
    print(f"\n📋 URL Summary:")
    type_counts = {}
    for url_info in urls:
        url_type = url_info['type']
        type_counts[url_type] = type_counts.get(url_type, 0) + 1
    
    for url_type, count in type_counts.items():
        print(f"   {url_type}: {count}")
    
    # Ask about cookies
    use_cookies = save_cookies_interactive(directories)
    
    # Confirm before starting
    print(f"\n⚠️  About to download {len(urls)} URLs.")
    if use_cookies:
        print("🔐 Cookies will be used for authentication")
    else:
        print("ℹ️  Downloading public content only")
    
    response = input("Continue? (y/N): ").strip().lower()
    
    if response not in ['y', 'yes']:
        print("Download cancelled.")
        return
    
    # Start batch download
    start_time = time.time()
    success_count, failed_urls, download_results = batch_download(urls, directories, use_cookies)
    end_time = time.time()
    
    total_duration = end_time - start_time
    
    # Generate report
    generate_report(success_count, len(urls), failed_urls, download_results, directories, total_duration)
    
    # Save detailed report
    report_file = save_detailed_report(download_results, directories, total_duration)
    
    print(f"\n📝 Detailed report saved to: {report_file}")
    if backup_path:
        print(f"💾 Script backup: {backup_path}")
    print("🎉 Automation completed!")
    
    # Show next steps
    print(f"\n📌 Next steps:")
    print(f"1. Check downloaded content in: {directories['base']}")
    print(f"2. Review the report: {report_file}")
    if failed_urls:
        print(f"3. Retry failed downloads from: {directories['logs']}/failed_urls.txt")

if __name__ == "__main__":
    main()
