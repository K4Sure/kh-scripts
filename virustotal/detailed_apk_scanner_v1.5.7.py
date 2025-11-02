import time
import requests
import os
import hashlib
import shutil
import random
import json
from pathlib import Path
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# =============================================
# CONFIGURATION - VERSION 1.5.7
# =============================================
VERSION = "1.5.7"
API_KEY = os.getenv("VT_API_KEY")
HEADERS = {"x-apikey": API_KEY}
BASE_URL = "https://www.virustotal.com/api/v3"

# Directory Configuration
SCAN_DIRECTORIES = [
    "/storage/emulated/0/Download/1DMP/Programs",
    "/storage/emulated/0/Download/Obtainium", 
    "/storage/emulated/0/Download"
]

APKS_BASE_DIR = "/storage/emulated/0/Download/APKs"
CLEAN_APKS_DIR = f"{APKS_BASE_DIR}/Clean_and_Safe_APKs"
INFECTED_APKS_DIR = f"{APKS_BASE_DIR}/Infected_and_High_Risk_APKs"
SCAN_LOGS_DIR = f"{APKS_BASE_DIR}/Termux–VirusTotal_Scan_Logs"
SCAN_RESULTS_DIR = f"{APKS_BASE_DIR}/Termux–VirusTotal_Scan_Results"
WHITELIST_FILE = f"{APKS_BASE_DIR}/whitelist.json"
BLACKLIST_FILE = f"{APKS_BASE_DIR}/blacklist.json"

# Backup Configuration
SCRIPT_DIR = "/data/data/com.termux/files/home/kh-scripts/virustotal"
BACKUP_DIR = "/data/data/com.termux/files/home/kh-scripts/virustotal/backup"

# =============================================
# COLOR CONSTANTS
# =============================================
BOLD = "\033[1m"
RESET = "\033[0m"
NEON_GREEN = "\033[38;2;57;255;20m"
NEON_RED = "\033[38;2;255;20;20m"
NEON_YELLOW = "\033[38;2;255;255;20m"
NEON_BLUE = "\033[38;2;57;97;255m"
NEON_PURPLE = "\033[38;2;180;60;220m"
PATH_COLOR = "\033[38;2;243;254;1m"
WHITE_BOLD = "\033[1;37m"

# =============================================
# BACKUP MANAGEMENT
# =============================================

def handle_backup_command(args):
    """Handle vt-backup command - Backup scripts, whitelist, and blacklist"""
    print()
    print(f"{BOLD}💾 Backup Manager{RESET}")
    
    # Create backup directory if it doesn't exist
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)
        print(f"      📁 Created backup directory: {BACKUP_DIR}")
    
    # Generate timestamp for this backup session
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    backup_success = []
    backup_failed = []
    
    # 1. Backup all scripts from SCRIPT_DIR with timestamps
    print(f"\n      📜 Backing up scripts from: {SCRIPT_DIR}")
    script_files = [f for f in os.listdir(SCRIPT_DIR) if f.endswith('.py') and os.path.isfile(os.path.join(SCRIPT_DIR, f))]
    
    # Find the latest script (highest version)
    latest_script = None
    latest_version = (0, 0, 0)
    
    for script_file in script_files:
        # Extract version from filename
        version_match = None
        if 'detailed_apk_scanner_v' in script_file:
            version_part = script_file.split('detailed_apk_scanner_v')[1].replace('.py', '')
            try:
                version_parts = tuple(map(int, version_part.split('.')))
                if version_parts > latest_version:
                    latest_version = version_parts
                    latest_script = script_file
            except:
                pass
    
    for script_file in script_files:
        source_path = os.path.join(SCRIPT_DIR, script_file)
        
        # Add timestamp to backup filename
        name_without_ext = os.path.splitext(script_file)[0]
        backup_filename = f"{name_without_ext}_{timestamp}.py"
        dest_path = os.path.join(BACKUP_DIR, backup_filename)
        
        try:
            shutil.copy2(source_path, dest_path)
            backup_success.append(f"Script: {script_file} -> {backup_filename}")
            print(f"        ✅ {NEON_GREEN}{script_file} -> {backup_filename}{RESET}")
        except Exception as e:
            backup_failed.append(f"Script: {script_file} - {str(e)}")
            print(f"        ❌ {NEON_RED}Failed: {script_file}{RESET}")
    
    # 2. Backup whitelist.json with timestamp
    print(f"\n      📋 Backing up whitelist")
    if os.path.exists(WHITELIST_FILE):
        try:
            whitelist_dest = os.path.join(BACKUP_DIR, f"whitelist_{timestamp}.json")
            shutil.copy2(WHITELIST_FILE, whitelist_dest)
            backup_success.append("Whitelist")
            print(f"        ✅ {NEON_GREEN}whitelist.json -> whitelist_{timestamp}.json{RESET}")
        except Exception as e:
            backup_failed.append(f"Whitelist - {str(e)}")
            print(f"        ❌ {NEON_RED}Failed: whitelist.json{RESET}")
    else:
        print(f"        ⚠️  {NEON_YELLOW}Whitelist file not found{RESET}")
    
    # 3. Backup blacklist.json with timestamp
    print(f"\n      🚫 Backing up blacklist")
    if os.path.exists(BLACKLIST_FILE):
        try:
            blacklist_dest = os.path.join(BACKUP_DIR, f"blacklist_{timestamp}.json")
            shutil.copy2(BLACKLIST_FILE, blacklist_dest)
            backup_success.append("Blacklist")
            print(f"        ✅ {NEON_GREEN}blacklist.json -> blacklist_{timestamp}.json{RESET}")
        except Exception as e:
            backup_failed.append(f"Blacklist - {str(e)}")
            print(f"        ❌ {NEON_RED}Failed: blacklist.json{RESET}")
    else:
        print(f"        ⚠️  {NEON_YELLOW}Blacklist file not found{RESET}")
    
    # Clean up source directory - remove all scripts except the latest one
    print(f"\n      🧹 Cleaning up source directory")
    if latest_script:
        removed_count = 0
        for script_file in script_files:
            if script_file != latest_script:
                try:
                    os.remove(os.path.join(SCRIPT_DIR, script_file))
                    print(f"        🗑️  {NEON_YELLOW}Removed: {script_file}{RESET}")
                    removed_count += 1
                except Exception as e:
                    print(f"        ❌ {NEON_RED}Failed to remove {script_file}: {e}{RESET}")
        
        print(f"        ✅ {NEON_GREEN}Kept latest: {latest_script}{RESET}")
        print(f"        📊 Cleanup: {removed_count} scripts removed, 1 kept")
    else:
        print(f"        ⚠️  {NEON_YELLOW}Could not determine latest script, no cleanup performed{RESET}")
    
    # Summary
    print(f"\n{BOLD}📊 Backup Summary:{RESET}")
    print(f"      ✅ {NEON_GREEN}Successful: {len(backup_success)} items{RESET}")
    if backup_failed:
        print(f"      ❌ {NEON_RED}Failed: {len(backup_failed)} items{RESET}")
    print(f"      📍 Backup Location: {BACKUP_DIR}")
    print(f"      🕐 Backup Timestamp: {timestamp}")
    print()

# =============================================
# PATH SHORTENING AND COLORIZATION
# =============================================

def shorten_path(path):
    """Shorten path for display only with specific mappings"""
    path_str = str(path)
    
    path_mappings = {
        "/storage/emulated/0/Download": "~~/Download",
        "/storage/emulated/0/Download/1DMP/Programs": "~~/1DMP/Programs", 
        "/storage/emulated/0/Download/APKs/Infected_and_High_Risk_APKs": "~~/APKs/Infected_and_High_Risk_APKs",
        "/storage/emulated/0/Download/Obtainium": "~~/Obtainium",
        "/storage/emulated/0/Download/APKs/Termux–VirusTotal_Scan_Logs": "~~/APKs/Termux–VirusTotal_Scan_Logs",
        "/storage/emulated/0/Download/APKs/Clean_and_Safe_APKs": "~~/APKs/Clean_and_Safe_APKs",
        "/storage/emulated/0/Download/APKs": "~~/APKs"
    }
    
    if path_str in path_mappings:
        return path_mappings[path_str]
    
    for full_path, shortened in path_mappings.items():
        if path_str.startswith(full_path + '/'):
            filename = path_str[len(full_path) + 1:]
            return f"{shortened}/{filename}"
    
    shortened = path_str.replace("/storage/emulated/0", "~~")
    
    if len(shortened) > 60:
        parts = shortened.split('/')
        if len(parts) > 4:
            shortened = ".../" + "/".join(parts[-3:])
    
    return shortened

def colorize_path(path):
    """Colorize path with PATH_COLOR"""
    return f"{PATH_COLOR}{path}{RESET}"

def display_path(path):
    """Shorten and colorize path for display"""
    return colorize_path(shorten_path(path))

# =============================================
# TRUE COLOR SYSTEM FOR APK NAMES
# =============================================

TRUE_COLORS = [
    (255, 105, 180), (30, 144, 255), (50, 205, 50), (255, 215, 0), (138, 43, 226),
    (255, 140, 0), (0, 206, 209), (255, 69, 0), (123, 104, 238), (60, 179, 113),
    (255, 20, 147), (65, 105, 225), (218, 112, 214), (240, 230, 140), (72, 209, 204)
]

apk_colors = {}
import hashlib

def get_apk_color(apk_name):
    """Deterministic truecolor for an APK name using SHA256 -> index in TRUE_COLORS."""
    try:
        h = hashlib.sha256(apk_name.encode('utf-8')).hexdigest()
        idx = int(h[:8], 16) % len(TRUE_COLORS)
        return TRUE_COLORS[idx]
    except Exception:
        return random.choice(TRUE_COLORS)

def colorize_apk_name(apk_name):
    r, g, b = get_apk_color(apk_name)
    return f"\033[38;2;{r};{g};{b}m{apk_name}{RESET}"

# =============================================
# WHITELIST & BLACKLIST MANAGEMENT
# =============================================

class DetectionListManager:
    def __init__(self):
        self.whitelist = self.load_list(WHITELIST_FILE)
        self.blacklist = self.load_list(BLACKLIST_FILE)
    
    def load_list(self, file_path):
        """Load whitelist or blacklist from JSON file"""
        try:
            if os.path.exists(file_path):
                with open(file_path, 'r', encoding='utf-8') as f:
                    return set(json.load(f))
            return set()
        except Exception:
            return set()
    
    def save_list(self, file_path, data_list):
        """Save whitelist or blacklist to JSON file"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(list(data_list), f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"{NEON_RED}❌ Error saving list: {e}{RESET}")
            return False
    
    def add_to_whitelist(self, detection_pattern):
        """Add a detection pattern to whitelist"""
        self.whitelist.add(detection_pattern.strip())
        if self.save_list(WHITELIST_FILE, self.whitelist):
            print(f"{NEON_GREEN}✅ Added to whitelist: {detection_pattern}{RESET}")
            return True
        return False
    
    def add_to_blacklist(self, detection_pattern):
        """Add a detection pattern to blacklist"""
        self.blacklist.add(detection_pattern.strip())
        if self.save_list(BLACKLIST_FILE, self.blacklist):
            print(f"{NEON_RED}✅ Added to blacklist: {detection_pattern}{RESET}")
            return True
        return False
    
    def remove_from_whitelist(self, detection_pattern):
        """Remove a detection pattern from whitelist"""
        if detection_pattern in self.whitelist:
            self.whitelist.remove(detection_pattern)
            if self.save_list(WHITELIST_FILE, self.whitelist):
                print(f"{NEON_YELLOW}✅ Removed from whitelist: {detection_pattern}{RESET}")
                return True
        else:
            print(f"{NEON_YELLOW}⚠️ Pattern not found in whitelist: {detection_pattern}{RESET}")
        return False
    
    def remove_from_blacklist(self, detection_pattern):
        """Remove a detection pattern from blacklist"""
        if detection_pattern in self.blacklist:
            self.blacklist.remove(detection_pattern)
            if self.save_list(BLACKLIST_FILE, self.blacklist):
                print(f"{NEON_YELLOW}✅ Removed from blacklist: {detection_pattern}{RESET}")
                return True
        else:
            print(f"{NEON_YELLOW}⚠️ Pattern not found in blacklist: {detection_pattern}{RESET}")
        return False
    
    def show_lists(self):
        """Display current whitelist and blacklist"""
        print(f"\n{BOLD}📋 Detection Lists:{RESET}")
        print(f"      {NEON_GREEN}✅ Whitelist ({len(self.whitelist)} patterns):{RESET}")
        for pattern in sorted(self.whitelist):
            print(f"            • {NEON_GREEN}{pattern}{RESET}")
        
        print(f"      {NEON_RED}🚫 Blacklist ({len(self.blacklist)} patterns):{RESET}")
        for pattern in sorted(self.blacklist):
            print(f"            • {NEON_RED}{pattern}{RESET}")
    
    def clear_whitelist(self):
        """Clear all whitelist entries"""
        self.whitelist.clear()
        if self.save_list(WHITELIST_FILE, self.whitelist):
            print(f"{NEON_YELLOW}✅ Whitelist cleared{RESET}")
            return True
        return False
    
    def clear_blacklist(self):
        """Clear all blacklist entries"""
        self.blacklist.clear()
        if self.save_list(BLACKLIST_FILE, self.blacklist):
            print(f"{NEON_YELLOW}✅ Blacklist cleared{RESET}")
            return True
        return False
    
    def is_whitelisted(self, vendor, result):
        """Check if a detection is whitelisted"""
        detection_string = f"{vendor}: {result}"
        for pattern in self.whitelist:
            if pattern.lower() in detection_string.lower():
                return True
        return False
    
    def is_blacklisted(self, vendor, result):
        """Check if a detection is blacklisted"""
        detection_string = f"{vendor}: {result}"
        for pattern in self.blacklist:
            if pattern.lower() in detection_string.lower():
                return True
        return False

# Initialize detection list manager
detection_manager = DetectionListManager()

# =============================================
# HYBRID VT CLIENT WITH USAGE TRACKING
# =============================================

class VTAPIClient:
    def __init__(self, api_key):
        self.api_key = api_key
        self.client = None
        self.using_sdk = False
        self.usage_stats = {"sdk": 0, "requests": 0, "sandbox": 0, "errors": 0, "rate_limits": 0}
        
    def initialize(self):
        try:
            import vt
            self.client = vt.Client(self.api_key)
            self.using_sdk = True
            return True
        except ImportError:
            self.using_sdk = False
            return False
        except Exception as e:
            self.using_sdk = False
            return False
    
    def close(self):
        if self.client:
            self.client.close()
    
    def get_file_analysis(self, file_hash):
        if self.using_sdk and self.client:
            self.usage_stats["sdk"] += 1
            return self._get_file_analysis_sdk(file_hash)
        else:
            self.usage_stats["requests"] += 1
            return self._get_file_analysis_requests(file_hash)
    
    def _get_file_analysis_sdk(self, file_hash):
        try:
            file_object = self.client.get_object(f"/files/{file_hash}")
            return {
                "status": "found",
                "file_object": file_object,
                "stats": file_object.last_analysis_stats,
                "full_data": file_object
            }
        except Exception as e:
            self.usage_stats["errors"] += 1
            error_msg = str(e)
            if "NotFoundError" in error_msg:
                return {"status": "not_found"}
            elif "QuotaExceededError" in error_msg:
                self.usage_stats["rate_limits"] += 1
                return {"status": "rate_limited"}
            else:
                return {"status": "error", "error": error_msg}
    
    def _get_file_analysis_requests(self, file_hash):
        try:
            url = f"{BASE_URL}/files/{file_hash}"
            response = requests.get(url, headers=HEADERS, timeout=30)
            
            if response.status_code == 429:
                self.usage_stats["rate_limits"] += 1
                return {"status": "rate_limited"}
                
            if response.status_code == 200:
                data = response.json()
                stats = data["data"]["attributes"]["last_analysis_stats"]
                return {
                    "status": "found", 
                    "malicious": stats["malicious"],
                    "suspicious": stats["suspicious"],
                    "undetected": stats["undetected"],
                    "harmless": stats["harmless"],
                    "total": sum(stats.values()),
                    "full_data": data
                }
            elif response.status_code == 404:
                return {"status": "not_found"}
            else:
                self.usage_stats["errors"] += 1
                return {"status": "api_error", "code": response.status_code}
                
        except requests.exceptions.Timeout:
            self.usage_stats["errors"] += 1
            return {"status": "timeout"}
        except Exception as e:
            self.usage_stats["errors"] += 1
            return {"status": "error", "error": str(e)}
    
    def print_usage_stats(self):
        total_api_calls = self.usage_stats["sdk"] + self.usage_stats["requests"]
        if total_api_calls > 0:
            print(f"{BOLD}📊 API Usage Statistics:{RESET}")
            print(f"      🔬 SDK Requests: {self.usage_stats['sdk']} ({self.usage_stats['sdk']/total_api_calls*100:.1f}%)")
            print(f"      🌐 Requests Fallback: {self.usage_stats['requests']} ({self.usage_stats['requests']/total_api_calls*100:.1f}%)")
            print(f"      🔍 Sandbox Analyses: {self.usage_stats['sandbox']}")
            
            # Colorize errors and rate limits
            errors_color = NEON_YELLOW if self.usage_stats['errors'] == 0 else NEON_RED
            limits_color = NEON_YELLOW if self.usage_stats['rate_limits'] == 0 else NEON_RED
            
            print(f"      ⚠️  Errors: {errors_color}{self.usage_stats['errors']}{RESET}")
            print(f"      🚦 Rate Limits: {limits_color}{self.usage_stats['rate_limits']}{RESET}")

# =============================================
# ENHANCED SANDBOX ANALYSIS
# =============================================

def extract_sandbox_verdicts(full_data, vt_client):
    try:
        if hasattr(full_data, 'sandbox_verdicts'):
            sandbox_verdicts = full_data.sandbox_verdicts
        else:
            sandbox_verdicts = full_data.get("data", {}).get("attributes", {}).get("sandbox_verdicts", {})
        
        if sandbox_verdicts:
            vt_client.usage_stats["sandbox"] += 1
        
        verdict_data = {}
        for sandbox, verdict in sandbox_verdicts.items():
            verdict_data[sandbox] = {
                'category': verdict.get('category', 'Unknown'),
                'confidence': verdict.get('confidence', 'Unknown'),
                'sandbox_name': verdict.get('sandbox_name', 'Unknown'),
                'malware_classification': verdict.get('malware_classification', []),
                'malware_names': verdict.get('malware_names', [])
            }
        
        return verdict_data
    except Exception as e:
        return None

def get_confidence_color(confidence):
    """Get color based on confidence percentage"""
    try:
        conf_num = int(confidence)
        if conf_num >= 80:
            return NEON_GREEN
        elif conf_num >= 40:
            return NEON_YELLOW
        else:
            return NEON_RED
    except:
        return NEON_YELLOW

def get_category_color(category):
    """Get color based on category"""
    category_lower = category.lower()
    if 'harmless' in category_lower or 'clean' in category_lower:
        return NEON_GREEN
    elif 'suspicious' in category_lower:
        return NEON_YELLOW
    elif 'malicious' in category_lower:
        return NEON_RED
    else:
        return NEON_BLUE

def print_sandbox_analysis(sandbox_verdicts, apk_name):
    if not sandbox_verdicts:
        return
        
    print(f"🔬 Sandbox Analysis:")
    
    for sandbox, verdict in sandbox_verdicts.items():
        print(f"      🧪 {sandbox}:")
        category_color = get_category_color(verdict['category'])
        print(f"      📊 Category: {category_color}{verdict['category']}{RESET}")
        
        confidence_color = get_confidence_color(verdict['confidence'])
        print(f"      🎯 Confidence: {confidence_color}{verdict['confidence']}%{RESET}")
        
        # Only print classification if it's not "CLEAN"
        if (verdict['malware_classification'] and 
            ', '.join(verdict['malware_classification']).upper() != 'CLEAN'):
            print(f"      🏷️  Classification: {', '.join(verdict['malware_classification'])}")

# =============================================
# ENHANCED DETECTION ANALYSIS WITH WHITELIST/BLACKLIST
# =============================================

def is_safe_detection_type(result_string):
    if not result_string:
        return False
    result_lower = result_string.lower()
    safe_indicators = ['pup', 'pua', 'riskware', 'potentially unwanted', 'unwanted', 'adware']
    for indicator in safe_indicators:
        if indicator in result_lower:
            return True
    return False

def is_malicious_detection_type(result_string):
    if not result_string:
        return False
    result_lower = result_string.lower()
    malicious_indicators = ['trojan', 'virus', 'malware', 'worm', 'backdoor', 'exploit', 'ransomware']
    for indicator in malicious_indicators:
        if indicator in result_lower:
            return True
    return False

def categorize_apk(malicious_count, suspicious_count, detailed_analysis):
    if malicious_count == 0 and suspicious_count == 0:
        return "clean"
    
    has_malicious_detections = False
    has_only_safe_detections = True
    
    # Check malicious detections
    for vendor, details in detailed_analysis.get("malicious", {}).items():
        result = details.get("result", "")
        if result:
            # Check if whitelisted
            if detection_manager.is_whitelisted(vendor, result):
                continue  # Skip whitelisted detections
            # Check if blacklisted
            if detection_manager.is_blacklisted(vendor, result):
                has_malicious_detections = True
                has_only_safe_detections = False
                break
            elif is_malicious_detection_type(result):
                has_malicious_detections = True
                has_only_safe_detections = False
            elif not is_safe_detection_type(result):
                has_malicious_detections = True
                has_only_safe_detections = False
    
    # Check suspicious detections
    for vendor, details in detailed_analysis.get("suspicious", {}).items():
        result = details.get("result", "")
        if result:
            # Check if whitelisted
            if detection_manager.is_whitelisted(vendor, result):
                continue  # Skip whitelisted detections
            # Check if blacklisted
            if detection_manager.is_blacklisted(vendor, result):
                has_malicious_detections = True
                has_only_safe_detections = False
                break
            elif is_malicious_detection_type(result):
                has_malicious_detections = True
                has_only_safe_detections = False
            elif not is_safe_detection_type(result):
                has_malicious_detections = True
                has_only_safe_detections = False
    
    if has_malicious_detections:
        return "infected"
    elif has_only_safe_detections:
        return "clean"
    else:
        return "infected"

def print_detection_analysis(detailed_analysis, apk_name):
    """Enhanced detection analysis with whitelist/blacklist status"""
    if not detailed_analysis or (not detailed_analysis.get("malicious") and not detailed_analysis.get("suspicious")):
        return 0, 0
    
    safe_detections = 0
    malicious_detections = 0
    
    print("🔍 Detection Analysis:")
    
    # Process malicious detections
    for vendor, details in detailed_analysis.get("malicious", {}).items():
        result = details["result"] if details["result"] else "Generic detection"
        
        # Check list status and detection type
        if detection_manager.is_whitelisted(vendor, result):
            safe_detections += 1
            safety_type = "WHITELISTED"
            safety_color = WHITE_BOLD
            list_icon = "✅"
        elif detection_manager.is_blacklisted(vendor, result):
            malicious_detections += 1
            safety_type = "BLACKLISTED"
            safety_color = NEON_RED
            list_icon = "❌"
        elif is_safe_detection_type(result):
            safe_detections += 1
            safety_type = "SAFE"
            safety_color = NEON_GREEN
            list_icon = "✅"
        else:
            malicious_detections += 1
            safety_type = "MALICIOUS"
            safety_color = NEON_RED
            list_icon = "❌"
        
        print(f"      {list_icon} {safety_color}{BOLD}{vendor}:{RESET}{safety_color} {result} - {safety_type}{RESET}")
    
    # Process suspicious detections
    for vendor, details in detailed_analysis.get("suspicious", {}).items():
        result = details["result"] if details["result"] else "Suspicious behavior"
        
        # Check list status and detection type
        if detection_manager.is_whitelisted(vendor, result):
            safe_detections += 1
            safety_type = "WHITELISTED"
            safety_color = WHITE_BOLD
            list_icon = "✅"
        elif detection_manager.is_blacklisted(vendor, result):
            malicious_detections += 1
            safety_type = "BLACKLISTED"
            safety_color = NEON_RED
            list_icon = "❌"
        elif is_safe_detection_type(result):
            safe_detections += 1
            safety_type = "SAFE"
            safety_color = NEON_GREEN
            list_icon = "✅"
        else:
            malicious_detections += 1
            safety_type = "MALICIOUS"
            safety_color = NEON_RED
            list_icon = "❌"
        
        print(f"      {list_icon} {safety_color}{BOLD}{vendor}:{RESET}{safety_color} {result} - {safety_type}{RESET}")
    
    return safe_detections, malicious_detections

# =============================================
# FINAL SUMMARY FORMATTING
# =============================================

def print_final_summary(results):
    separator = "=" * 60
    
    clean_count = len(results['clean'])
    infected_count = len(results['infected'])
    unknown_count = len(results['unknown'])
    
    print("\n" + separator)
    print()
    print(f"{BOLD}📊 Final Scan Summary:{RESET}")
    print(f"      ✅ {NEON_GREEN}Clean & Safe: {clean_count}{RESET}")
    print(f"      🚨 {NEON_RED}Infected & High Risk: {infected_count}{RESET}")
    print(f"      ❓ {NEON_YELLOW}Unknown: {unknown_count}{RESET}")
    print()
    print(separator)

# =============================================
# LOGGING SYSTEM
# =============================================

class ScanLogger:
    def __init__(self):
        self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = os.path.join(SCAN_LOGS_DIR, f"scan_session_{self.session_id}.log")
        self.ensure_log_directory()
        
    def ensure_log_directory(self):
        if not os.path.exists(SCAN_LOGS_DIR):
            os.makedirs(SCAN_LOGS_DIR)
    
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        try:
            with open(self.log_file, "a", encoding="utf-8") as f:
                f.write(log_entry)
        except Exception:
            pass
    
    def log_scan_start(self, total_files, method):
        self.log(f"VirusTotal PowerScanner v{VERSION} started")
        self.log(f"Scan directories: {SCAN_DIRECTORIES}")
        self.log(f"Total APK files to scan: {total_files}")
        self.log(f"API Method: {method}")

    def log_apk_processing(self, apk_name, apk_path):
        self.log(f"Processing APK: {apk_name} from {apk_path}")
    
    def log_hash_result(self, apk_name, malicious_count, suspicious_count, total_vendors):
        self.log(f"Hash result for {apk_name}: {malicious_count} malicious, {suspicious_count} suspicious / {total_vendors} vendors")
    
    def log_sandbox_analysis(self, apk_name, sandbox_verdicts):
        if sandbox_verdicts:
            self.log(f"Sandbox analysis for {apk_name}: {len(sandbox_verdicts)} sandbox verdicts")
    
    def log_categorization(self, apk_name, category, safe_detections, malicious_detections):
        self.log(f"Categorized {apk_name} as {category.upper()} - Safe: {safe_detections}, Malicious: {malicious_detections}")
    
    def log_file_move(self, apk_name, destination_folder):
        self.log(f"Moved {apk_name} to {destination_folder}")
    
    def log_scan_complete(self, clean_count, infected_count, unknown_count):
        self.log(f"Scan completed: {clean_count} clean, {infected_count} infected, {unknown_count} unknown")
        self.log(f"Scan results saved to: {SCAN_RESULTS_DIR}")
        self.log(f"Session log saved to: {self.log_file}")
    
    def log_error(self, apk_name, error_message):
        self.log(f"Error processing {apk_name}: {error_message}", "ERROR")
    
    def log_rate_limit(self):
        self.log("Rate limit hit, waiting 60 seconds", "WARNING")

logger = None

# =============================================
# INITIALIZATION FUNCTIONS
# =============================================

def initialize_directories():
    """Silently initialize directories"""
    directories = [APKS_BASE_DIR, CLEAN_APKS_DIR, INFECTED_APKS_DIR, SCAN_LOGS_DIR, SCAN_RESULTS_DIR]
    for directory in directories:
        if not os.path.exists(directory):
            os.makedirs(directory)
            if logger:
                logger.log(f"Created directory: {directory}")

def cleanup_old_logs():
    """Only show cleanup when actually cleaning"""
    cutoff_date = datetime.now() - timedelta(days=3)
    deleted_count = 0
    
    for log_file in Path(SCAN_LOGS_DIR).glob("*.log"):
        file_time = datetime.fromtimestamp(log_file.stat().st_mtime)
        if file_time < cutoff_date:
            try:
                os.remove(log_file)
                deleted_count += 1
                if logger:
                    logger.log(f"Deleted old log: {log_file.name}")
            except Exception as e:
                if logger:
                    logger.log(f"Failed to delete {log_file.name}: {e}", "ERROR")
    
    if deleted_count > 0:
        print(f"🧹 Cleaned up {deleted_count} old log files")
        if logger:
            logger.log(f"Cleaned up {deleted_count} old log files")

# =============================================
# CORE SCANNING FUNCTIONS
# =============================================

def calculate_sha256(file_path):
    sha256_hash = hashlib.sha256()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()
    except Exception as e:
        if logger:
            logger.log_error(os.path.basename(file_path), f"Error calculating hash: {e}")
        return None

def get_detailed_analysis(file_hash):
    try:
        url = f"{BASE_URL}/files/{file_hash}"
        response = requests.get(url, headers=HEADERS, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            analysis_results = data["data"]["attributes"]["last_analysis_results"]
            
            malicious_vendors = {}
            suspicious_vendors = {}
            
            for vendor, result in analysis_results.items():
                category = result.get("category", "")
                method = result.get("method", "")
                result_name = result.get("result", "Unknown")
                
                if category == "malicious":
                    malicious_vendors[vendor] = {
                        "result": result_name,
                        "method": method
                    }
                elif category == "suspicious":
                    suspicious_vendors[vendor] = {
                        "result": result_name,
                        "method": method
                    }
            
            return {
                "malicious": malicious_vendors,
                "suspicious": suspicious_vendors
            }
        else:
            return None
    except Exception as e:
        return None

# =============================================
# FILE MANAGEMENT FUNCTIONS
# =============================================

def organize_apk_file(apk_path, scan_result):
    try:
        filename = os.path.basename(apk_path)
        category = scan_result["category"]
        
        if category == "clean":
            destination = os.path.join(CLEAN_APKS_DIR, filename)
            shutil.move(apk_path, destination)
            if logger:
                logger.log_file_move(filename, "Clean_and_Safe_APKs")
            return "clean"
        else:
            destination = os.path.join(INFECTED_APKS_DIR, filename)
            shutil.move(apk_path, destination)
            if logger:
                logger.log_file_move(filename, "Infected_and_High_Risk_APKs")
            return "infected"
            
    except Exception as e:
        if logger:
            logger.log_error(os.path.basename(apk_path), f"Failed to move file: {e}")
        return "failed"

def save_scan_result(apk_path, scan_result):
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = os.path.basename(apk_path)
        result_filename = f"{filename}_{timestamp}.txt"
        result_path = os.path.join(SCAN_RESULTS_DIR, result_filename)
        
        with open(result_path, "w", encoding="utf-8") as f:
            f.write(f"VirusTotal Scan Result - Version {VERSION}\n")
            f.write("=" * 50 + "\n")
            f.write(f"File: {filename}\n")
            f.write(f"Scan Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"File Hash: {scan_result.get('file_hash', 'N/A')}\n")
            f.write(f"Category: {scan_result['category'].upper()}\n")
            f.write(f"Detection: {scan_result['malicious']} malicious, {scan_result['suspicious']} suspicious out of {scan_result['total']} vendors\n")
            f.write(f"VirusTotal Report: https://www.virustotal.com/gui/file/{scan_result.get('file_hash', '')}\n\n")
            
            if scan_result.get("sandbox_verdicts"):
                f.write("\nSANDBOX BEHAVIORAL ANALYSIS:\n")
                f.write("-" * 40 + "\n")
                for sandbox, verdict in scan_result["sandbox_verdicts"].items():
                    f.write(f"{sandbox}:\n")
                    f.write(f"  Category: {verdict['category']}\n")
                    f.write(f"  Confidence: {verdict['confidence']}%\n")
                    if verdict['malware_names']:
                        f.write(f"  Malware Names: {', '.join(verdict['malware_names'])}\n")
                    if verdict['malware_classification']:
                        f.write(f"  Classification: {', '.join(verdict['malware_classification'])}\n")
                    f.write("\n")
            
            if scan_result["detailed_analysis"]:
                malicious = scan_result["detailed_analysis"].get("malicious", {})
                if malicious:
                    f.write("MALICIOUS DETECTIONS:\n")
                    f.write("-" * 30 + "\n")
                    for vendor, details in malicious.items():
                        result = details["result"] if details["result"] else "Generic detection"
                        method = details["method"] if details["method"] else "Static analysis"
                        safe_type = "SAFE" if is_safe_detection_type(result) else "MALICIOUS"
                        f.write(f"{vendor}: {result} ({method}) - {safe_type}\n")
                
                suspicious = scan_result["detailed_analysis"].get("suspicious", {})
                if suspicious:
                    f.write("\nSUSPICIOUS DETECTIONS:\n")
                    f.write("-" * 30 + "\n")
                    for vendor, details in suspicious.items():
                        result = details["result"] if details["result"] else "Suspicious behavior"
                        safe_type = "SAFE" if is_safe_detection_type(result) else "MALICIOUS"
                        f.write(f"{vendor}: {result} - {safe_type}\n")
        
        if logger:
            logger.log(f"Scan result saved: {result_filename}")
        return True
        
    except Exception as e:
        if logger:
            logger.log_error(os.path.basename(apk_path), f"Failed to save scan result: {e}")
        return False

# =============================================
# ENHANCED POWER SCANNING LOGIC
# =============================================

def power_scan_apk(apk_path, vt_client, file_number, total_files):
    apk_name = os.path.basename(apk_path)
    separator = "=" * 60
    
    print(separator)
    print()
    print(f"{BOLD}🔍 Processing File {file_number} of {total_files}:{RESET} {colorize_apk_name(apk_name)}")
    print(f"📍 Path: {display_path(str(apk_path.parent))}")
    
    if logger:
        logger.log_apk_processing(apk_name, str(apk_path.parent))
    
    file_hash = calculate_sha256(apk_path)
    if file_hash:
        print(f"✅ Hash Found: {file_hash[:16]}...")
    
    hash_result = vt_client.get_file_analysis(file_hash)
    
    if hash_result["status"] == "found":
        if vt_client.using_sdk:
            stats = hash_result["stats"]
            malicious_count = stats["malicious"]
            suspicious_count = stats["suspicious"]
            total_vendors = sum(stats.values())
            full_data = hash_result["file_object"]
        else:
            malicious_count = hash_result["malicious"]
            suspicious_count = hash_result["suspicious"]
            total_vendors = hash_result["total"]
            full_data = hash_result["full_data"]
        
        # Colorize detection counts
        malicious_color = NEON_RED if malicious_count > 0 else NEON_GREEN
        suspicious_color = NEON_YELLOW if suspicious_count > 0 else NEON_GREEN
        
        print(f"📊 Detection Summary: {malicious_color}{malicious_count} malicious{RESET}, {suspicious_color}{suspicious_count} suspicious{RESET} out of {total_vendors}")
        
        if logger:
            logger.log_hash_result(apk_name, malicious_count, suspicious_count, total_vendors)
        
        sandbox_verdicts = extract_sandbox_verdicts(full_data, vt_client)
        if sandbox_verdicts:
            print_sandbox_analysis(sandbox_verdicts, apk_name)
            if logger:
                logger.log_sandbox_analysis(apk_name, sandbox_verdicts)
        
        detailed_analysis = get_detailed_analysis(file_hash)
        safe_detections, malicious_detections = print_detection_analysis(detailed_analysis, apk_name)
        
        # Use enhanced categorization that considers whitelist/blacklist
        category = categorize_apk(malicious_count, suspicious_count, detailed_analysis)
        
        # Colorize categorization
        category_color = NEON_GREEN if category == "clean" else NEON_RED
        print(f"🏷️  Categorization: {category_color}{category.upper()}{RESET}")
        print(f"🔗 VirusTotal Report: {NEON_BLUE}https://www.virustotal.com/gui/file/{file_hash}{RESET}")
        
        result_data = {
            "file": apk_name,
            "path": str(apk_path),
            "category": category,
            "malicious": malicious_count,
            "suspicious": suspicious_count,
            "total": total_vendors,
            "method": "hash_lookup",
            "file_hash": file_hash,
            "detailed_analysis": detailed_analysis,
            "sandbox_verdicts": sandbox_verdicts
        }
        
        move_result = organize_apk_file(apk_path, result_data)
        save_result = save_scan_result(apk_path, result_data)
        
        if save_result:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            result_filename = f"{apk_name}_{timestamp}.txt"
            print(f"💾 Scan Result: {result_filename}")
        
        if logger:
            logger.log_categorization(apk_name, category, safe_detections, malicious_detections)
        
        # Fixed: Removed extra empty line here
        return result_data
        
    elif hash_result["status"] == "rate_limited":
        if logger:
            logger.log_rate_limit()
        time.sleep(60)
        return power_scan_apk(apk_path, vt_client, file_number, total_files)
        
    elif hash_result["status"] == "not_found":
        if logger:
            logger.log_error(apk_name, "Hash not found in VirusTotal database")
        
        return {
            "file": apk_name,
            "path": str(apk_path),
            "category": "unknown",
            "reason": "hash_not_found",
            "method": "hash_lookup"
        }
    else:
        error_msg = f"Hash check failed for {colorize_apk_name(apk_name)}: {hash_result['status']}"
        if logger:
            logger.log_error(apk_name, f"Hash check failed: {hash_result['status']}")
        
        return {
            "file": apk_name,
            "path": str(apk_path),
            "category": "unknown",
            "reason": hash_result["status"],
            "method": "hash_lookup"
        }

# =============================================
# MAIN POWER SCANNING LOGIC
# =============================================

def get_apk_files_from_directories(directories):
    all_apk_files = []
    
    for directory in directories:
        apk_files = [f for f in Path(directory).glob("*.apk") if f.is_file()]
        
        if apk_files:
            print(f"{BOLD}📂 Scanning Directory: {display_path(directory)}{RESET}")
            print(f"{BOLD}      📁 Found {len(apk_files)} APK Files{RESET}")
            for apk_file in apk_files:
                print(f"            • {colorize_apk_name(apk_file.name)}")
        
        all_apk_files.extend(apk_files)
    
    return all_apk_files

def power_scan_all():
    global logger
    logger = ScanLogger()
    
    # Fixed: Removed duplicate title - only show enhanced one
    print(f"{NEON_BLUE}🔍 VirusTotal PowerScanner v{VERSION} - Enhanced Security Scan{RESET}")
    print()
    print(f"{BOLD}🔬 Enhanced Features:{RESET}")
    print(f"{BOLD}      🧩 Hybrid API Client{RESET}")
    print(f"{BOLD}      🧪 Sandbox Analysis{RESET}") 
    print(f"{BOLD}      🛟 Smart Fallback{RESET}")
    
    initialize_directories()
    cleanup_old_logs()
    
    vt_client = VTAPIClient(API_KEY)
    sdk_available = vt_client.initialize()
    
    method = "SDK" if sdk_available else "Requests"
    print(f"{BOLD}🔧 Using {method} for API Calls{RESET}")
    print()
    
    apk_files = get_apk_files_from_directories(SCAN_DIRECTORIES)
    
    if not apk_files:
        print("❌ No APK files found in any of the specified directories")
        if logger:
            logger.log("No APK files found in any directory", "WARNING")
        return
    
    print(f"{BOLD}\n📁 Total APK Files Found: {len(apk_files)}{RESET}")
    print()
    
    if logger:
        logger.log_scan_start(len(apk_files), method)
    
    results = {
        "clean": [],
        "infected": [],
        "unknown": []
    }
    
    for i, apk_file in enumerate(apk_files, 1):
        result = power_scan_apk(apk_file, vt_client, i, len(apk_files))
        
        category = result.get("category", "unknown")
        if category == "clean":
            results["clean"].append(result)
        elif category == "infected":
            results["infected"].append(result)
        else:
            results["unknown"].append(result)
        
        if i < len(apk_files):
            print()  # Add an empty line before the waiting message
            print("⏳ Waiting 15 seconds before next file...")
            time.sleep(15)
    
    vt_client.close()
    
    print_final_summary(results)
    print()
    vt_client.print_usage_stats()
    
    separator = "=" * 60
    print()
    print(separator)
    print()
    
    if logger:
        logger.log_scan_complete(len(results['clean']), len(results['infected']), len(results['unknown']))
    
    print(f"{BOLD}📁 Organized Files:{RESET}")
    
    # Clean APKs
    if results['clean']:
        print(f"      ✅ {NEON_GREEN}Clean & Safe APKs:{RESET}")
        for file in results['clean']:
            print(f"            • {NEON_GREEN}{file['file']}{RESET}")
    
    # Infected APKs  
    if results['infected']:
        print(f"      🚨 {NEON_RED}Infected & High Risk APKs:{RESET}")
        for file in results['infected']:
            print(f"            • {NEON_RED}{file['file']}{RESET}")
    
    print()
    print(separator)
    print()
    # Only print current session log, not scan results or scan logs
    print(f"📄 Current Session: {display_path(logger.log_file)}")
    print()
    print(separator)
    print()

# =============================================
# COMMAND LINE INTERFACE FOR WHITELIST/BLACKLIST
# =============================================

def handle_whitelist_command(args):
    """Handle vt-white command"""
    print()  # Empty line before command output
    if not args:
        detection_manager.show_lists()
        print()  # Empty line after command output
        return
    
    # Check if the first argument is a subcommand
    if args[0] in ["list", "clear", "remove", "add"]:
        action = args[0]
        if action == "list":
            detection_manager.show_lists()
        elif action == "clear":
            detection_manager.clear_whitelist()
        elif action == "remove" and len(args) > 1:
            pattern = " ".join(args[1:])
            detection_manager.remove_from_whitelist(pattern)
        elif action == "add" and len(args) > 1:
            pattern = " ".join(args[1:])
            detection_manager.add_to_whitelist(pattern)
        else:
            print(f"{NEON_YELLOW}Usage:{RESET}")
            print(f"  {NEON_BLUE}vt-white{RESET} {NEON_GREEN}list{RESET} - Show whitelist")
            print(f"  {NEON_BLUE}vt-white{RESET} {NEON_GREEN}clear{RESET} - Clear whitelist")
            print(f"  {NEON_BLUE}vt-white{RESET} {NEON_GREEN}remove <pattern>{RESET} - Remove from whitelist")
            print(f"  {NEON_BLUE}vt-white{RESET} {NEON_GREEN}add <pattern>{RESET} - Add to whitelist")
    else:
        # If no recognized action, treat the entire argument as a pattern to add
        pattern = " ".join(args)
        detection_manager.add_to_whitelist(pattern)
    print()  # Empty line after command output

def handle_blacklist_command(args):
    """Handle vt-black command"""
    print()  # Empty line before command output
    if not args:
        detection_manager.show_lists()
        print()  # Empty line after command output
        return
    
    # Check if the first argument is a subcommand
    if args[0] in ["list", "clear", "remove", "add"]:
        action = args[0]
        if action == "list":
            detection_manager.show_lists()
        elif action == "clear":
            detection_manager.clear_blacklist()
        elif action == "remove" and len(args) > 1:
            pattern = " ".join(args[1:])
            detection_manager.remove_from_blacklist(pattern)
        elif action == "add" and len(args) > 1:
            pattern = " ".join(args[1:])
            detection_manager.add_to_blacklist(pattern)
        else:
            print(f"{NEON_YELLOW}Usage:{RESET}")
            print(f"  {NEON_BLUE}vt-black{RESET} {NEON_RED}list{RESET} - Show blacklist")
            print(f"  {NEON_BLUE}vt-black{RESET} {NEON_RED}clear{RESET} - Clear blacklist")
            print(f"  {NEON_BLUE}vt-black{RESET} {NEON_RED}remove <pattern>{RESET} - Remove from blacklist")
            print(f"  {NEON_BLUE}vt-black{RESET} {NEON_RED}add <pattern>{RESET} - Add to blacklist")
    else:
        # If no recognized action, treat the entire argument as a pattern to add
        pattern = " ".join(args)
        detection_manager.add_to_blacklist(pattern)
    print()  # Empty line after command output

# =============================================
# ENHANCED MAIN EXECUTION
# =============================================

def main():
    global logger
    
    # Check for command line arguments
    import sys
    args = sys.argv[1:]  # Skip script name
    
    # Handle different command formats
    command = None
    command_args = []
    
    if len(args) == 0:
        # No arguments - run normal scan
        pass
    elif args[0] in ["vt-white", "vt-black", "vt-backup"]:
        # Direct command: python script.py vt-white ...
        command = args[0]
        command_args = args[1:] if len(args) > 1 else []
    elif len(args) >= 2 and args[0] == "vt" and args[1] in ["vt-white", "vt-black", "vt-backup"]:
        # Alias command: vt vt-white ...
        command = args[1]
        command_args = args[2:] if len(args) > 2 else []
    elif args[0] in ["-h", "--help", "help"]:
        # Help command
        command = "help"
    else:
        # Unknown command, show help
        command = "help"
    
    # Process commands
    if command == "vt-white":
        handle_whitelist_command(command_args)
        return
    elif command == "vt-black":
        handle_blacklist_command(command_args)
        return
    elif command == "vt-backup":
        handle_backup_command(command_args)
        return
    elif command == "help":
        print()  # Empty line before help
        print(f"{BOLD}📖 VirusTotal PowerScanner v{VERSION} - Help{RESET}")
        print()
        print(f"{NEON_BLUE}Usage:{RESET}")
        print(f"  {NEON_GREEN}vt{RESET} - Run normal scan")
        print(f"  {NEON_GREEN}vt vt-white <pattern>{RESET} - Add to whitelist")
        print(f"  {NEON_GREEN}vt vt-black <pattern>{RESET} - Add to blacklist")
        print(f"  {NEON_GREEN}vt vt-backup{RESET} - Backup scripts and detection lists")
        print(f"  {NEON_GREEN}vt vt-white remove <pattern>{RESET} - Remove from whitelist")
        print(f"  {NEON_GREEN}vt vt-black remove <pattern>{RESET} - Remove from blacklist")
        print(f"  {NEON_GREEN}vt vt-white list{RESET} - Show whitelist")
        print(f"  {NEON_GREEN}vt vt-black list{RESET} - Show blacklist")
        print(f"  {NEON_GREEN}vt vt-white clear{RESET} - Clear whitelist")
        print(f"  {NEON_GREEN}vt vt-black clear{RESET} - Clear blacklist")
        print()
        print(f"{NEON_BLUE}Direct Commands:{RESET}")
        print(f"  {NEON_GREEN}python {sys.argv[0]} vt-white <pattern>{RESET}")
        print(f"  {NEON_GREEN}python {sys.argv[0]} vt-black <pattern>{RESET}")
        print(f"  {NEON_GREEN}python {sys.argv[0]} vt-backup{RESET}")
        print()
        print(f"{NEON_BLUE}Examples:{RESET}")
        print(f"  {NEON_YELLOW}vt vt-white \"Microsoft: Trojan:Script/Wacatac.B!ml\"{RESET}")
        print(f"  {NEON_YELLOW}vt vt-black \"SomeVendor: Trojan.Generic\"{RESET}")
        print()  # Empty line after help
        return
    
    # Normal scan execution
    if not API_KEY:
        print("❌ Please set VT_API_KEY in your .env file")
        exit(1)
    
    power_scan_all()

if __name__ == "__main__":
    main()
