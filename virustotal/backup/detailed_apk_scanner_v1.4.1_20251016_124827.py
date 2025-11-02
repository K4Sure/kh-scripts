# detailed_apk_scanner_v1.4.1.py
import time
import requests
import os
import hashlib
import shutil
import random
from pathlib import Path
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# =============================================
# CONFIGURATION - VERSION 1.4.1
# =============================================
VERSION = "1.4.1"
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

# =============================================
# TRUE COLOR SYSTEM FOR APK NAMES
# =============================================

# Vibrant true colors (RGB) - will be randomly assigned daily
TRUE_COLORS = [
    (255, 105, 180),  # Hot Pink
    (30, 144, 255),   # Dodger Blue
    (50, 205, 50),    # Lime Green
    (255, 215, 0),    # Gold
    (138, 43, 226),   # Blue Violet
    (255, 140, 0),    # Dark Orange
    (0, 206, 209),    # Dark Turquoise
    (255, 69, 0),     # Red Orange
    (123, 104, 238),  # Medium Slate Blue
    (60, 179, 113),   # Medium Sea Green
    (255, 20, 147),   # Deep Pink
    (65, 105, 225),   # Royal Blue
    (218, 112, 214),  # Orchid
    (240, 230, 140),  # Khaki
    (72, 209, 204),   # Medium Turquoise
]

# Dictionary to store APK color assignments for this session
apk_colors = {}

def get_apk_color(apk_name):
    """Assign and return a consistent true color for each APK name"""
    if apk_name not in apk_colors:
        # Randomly assign a color from the pool (different each day)
        apk_colors[apk_name] = random.choice(TRUE_COLORS)
    return apk_colors[apk_name]

def colorize_apk_name(apk_name):
    """Apply true color to APK name using ANSI escape codes"""
    r, g, b = get_apk_color(apk_name)
    return f"\033[38;2;{r};{g};{b}m{apk_name}\033[0m"

# =============================================
# HYBRID VT CLIENT - SDK + REQUESTS FALLBACK
# =============================================

class VTAPIClient:
    def __init__(self, api_key):
        self.api_key = api_key
        self.client = None
        self.using_sdk = False
        
    def initialize(self):
        """Initialize the best available client"""
        # Try SDK first
        try:
            import vt
            self.client = vt.Client(self.api_key)
            self.using_sdk = True
            print("✅ Using VirusTotal Python SDK")
            return True
        except ImportError:
            print("⚠️  vt-py not available, using requests fallback")
            self.using_sdk = False
            return False
        except Exception as e:
            print(f"⚠️  SDK initialization failed: {e}, using requests fallback")
            self.using_sdk = False
            return False
    
    def close(self):
        """Close the SDK client if it exists"""
        if self.client:
            self.client.close()
    
    def get_file_analysis(self, file_hash):
        """Get file analysis using best available method"""
        if self.using_sdk and self.client:
            return self._get_file_analysis_sdk(file_hash)
        else:
            return self._get_file_analysis_requests(file_hash)
    
    def _get_file_analysis_sdk(self, file_hash):
        """Get file analysis using SDK"""
        try:
            file_object = self.client.get_object(f"/files/{file_hash}")
            return {
                "status": "found",
                "file_object": file_object,
                "stats": file_object.last_analysis_stats,
                "full_data": file_object
            }
        except Exception as e:
            error_msg = str(e)
            if "NotFoundError" in error_msg:
                return {"status": "not_found"}
            elif "QuotaExceededError" in error_msg:
                return {"status": "rate_limited"}
            else:
                print(f"❌ SDK Error: {error_msg}")
                return {"status": "error", "error": error_msg}
    
    def _get_file_analysis_requests(self, file_hash):
        """Fallback method using requests"""
        try:
            url = f"{BASE_URL}/files/{file_hash}"
            response = requests.get(url, headers=HEADERS, timeout=30)
            
            if response.status_code == 429:
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
                return {"status": "api_error", "code": response.status_code}
                
        except requests.exceptions.Timeout:
            return {"status": "timeout"}
        except Exception as e:
            return {"status": "error", "error": str(e)}

# =============================================
# ENHANCED SANDBOX ANALYSIS
# =============================================

def extract_sandbox_verdicts(full_data):
    """Extract sandbox verdicts from full data"""
    try:
        # Handle both SDK object and requests JSON data
        if hasattr(full_data, 'sandbox_verdicts'):
            # SDK data structure
            sandbox_verdicts = full_data.sandbox_verdicts
        else:
            # Requests data structure
            sandbox_verdicts = full_data.get("data", {}).get("attributes", {}).get("sandbox_verdicts", {})
        
        if not sandbox_verdicts:
            return None
            
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
        print(f"⚠️  Could not extract sandbox verdicts: {e}")
        return None

def print_sandbox_analysis(sandbox_verdicts, apk_name):
    """Print formatted sandbox analysis results"""
    if not sandbox_verdicts:
        return
        
    print(f"\n🔬 SANDBOX ANALYSIS for {colorize_apk_name(apk_name)}:")
    print("-" * 50)
    
    for sandbox, verdict in sandbox_verdicts.items():
        print(f"   🧪 {sandbox}:")
        print(f"      📊 Category: {verdict['category']}")
        print(f"      🎯 Confidence: {verdict['confidence']}%")
        if verdict['malware_names']:
            print(f"      ⚠️  Malware Names: {', '.join(verdict['malware_names'])}")
        if verdict['malware_classification']:
            print(f"      🏷️  Classification: {', '.join(verdict['malware_classification'])}")

# =============================================
# FINAL SUMMARY FORMATTING (v1.4.1)
# =============================================

def print_final_summary(results):
    """Print final scan summary with exact formatting requirements"""
    # Calculate separator length (75% of typical 80-column terminal = 60 chars)
    separator = "=" * 60
    
    # ANSI codes for bold and underline
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"
    RESET = "\033[0m"
    
    # True color codes for neon colors
    NEON_GREEN = "\033[38;2;57;255;20m"
    NEON_RED = "\033[38;2;255;20;20m"
    NEON_YELLOW = "\033[38;2;255;255;20m"
    
    clean_count = len(results['clean'])
    infected_count = len(results['infected'])
    unknown_count = len(results['unknown'])
    
    print("\n" + separator)
    print(f"{BOLD}📊 FINAL SCAN SUMMARY:{RESET}")
    print(f"✅ {NEON_GREEN}CLEAN & SAFE: {clean_count}{RESET}")
    print(f"🚨 {NEON_RED}INFECTED & HIGH RISK: {infected_count}{RESET}")
    print(f"❓ {NEON_YELLOW}UNKNOWN: {unknown_count}{RESET}")
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
        """Ensure log directory exists"""
        if not os.path.exists(SCAN_LOGS_DIR):
            os.makedirs(SCAN_LOGS_DIR)
    
    def log(self, message, level="INFO"):
        """Log message to file with timestamp"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        
        try:
            with open(self.log_file, "a", encoding="utf-8") as f:
                f.write(log_entry)
        except Exception as e:
            print(f"❌ Failed to write to log file: {e}")
    
    def log_scan_start(self, total_files, method):
        """Log scan session start"""
        self.log(f"🚀 VirusTotal PowerScanner v{VERSION} started")
        self.log(f"📁 Scan directories: {SCAN_DIRECTORIES}")
        self.log(f"📊 Total APK files to scan: {total_files}")
        self.log("🎨 True Color System activated")
        self.log(f"🔧 API Method: {method}")
        self.log("🔬 Enhanced Sandbox Analysis enabled")
    
    def log_apk_processing(self, apk_name, apk_path):
        """Log APK processing start"""
        self.log(f"🔍 Processing APK: {apk_name} from {apk_path}")
    
    def log_hash_result(self, apk_name, malicious_count, suspicious_count, total_vendors):
        """Log hash lookup result"""
        self.log(f"✅ Hash result for {apk_name}: {malicious_count} malicious, {suspicious_count} suspicious / {total_vendors} vendors")
    
    def log_sandbox_analysis(self, apk_name, sandbox_verdicts):
        """Log sandbox analysis results"""
        if sandbox_verdicts:
            self.log(f"🔬 Sandbox analysis for {apk_name}: {len(sandbox_verdicts)} sandbox verdicts")
    
    def log_categorization(self, apk_name, category, safe_detections, malicious_detections):
        """Log final categorization"""
        self.log(f"🏷️  Categorized {apk_name} as {category.upper()} - Safe: {safe_detections}, Malicious: {malicious_detections}")
    
    def log_file_move(self, apk_name, destination_folder):
        """Log file movement"""
        self.log(f"📁 Moved {apk_name} to {destination_folder}")
    
    def log_scan_complete(self, clean_count, infected_count, unknown_count):
        """Log scan completion"""
        self.log(f"📊 Scan completed: {clean_count} clean, {infected_count} infected, {unknown_count} unknown")
        self.log(f"💾 Scan results saved to: {SCAN_RESULTS_DIR}")
        self.log(f"📝 Session log saved to: {self.log_file}")
    
    def log_error(self, apk_name, error_message):
        """Log error for specific APK"""
        self.log(f"❌ Error processing {apk_name}: {error_message}", "ERROR")
    
    def log_rate_limit(self):
        """Log rate limiting"""
        self.log("⚠️  Rate limit hit, waiting 60 seconds", "WARNING")

# Global logger instance
logger = None

# =============================================
# INITIALIZATION FUNCTIONS
# =============================================

def initialize_directories():
    """Create all required directories if they don't exist"""
    directories = [APKS_BASE_DIR, CLEAN_APKS_DIR, INFECTED_APKS_DIR, SCAN_LOGS_DIR, SCAN_RESULTS_DIR]
    
    for directory in directories:
        if not os.path.exists(directory):
            os.makedirs(directory)
            print(f"📁 Created directory: {directory}")
            if logger:
                logger.log(f"Created directory: {directory}")
        else:
            print(f"✅ Directory exists: {directory}")

def cleanup_old_logs():
    """Remove log files older than 3 days"""
    print("\n🧹 Cleaning up old log files (older than 3 days)...")
    if logger:
        logger.log("Cleaning up old log files (older than 3 days)")
    
    cutoff_date = datetime.now() - timedelta(days=3)
    deleted_count = 0
    
    for log_file in Path(SCAN_LOGS_DIR).glob("*.log"):
        file_time = datetime.fromtimestamp(log_file.stat().st_mtime)
        if file_time < cutoff_date:
            try:
                os.remove(log_file)
                deleted_count += 1
                print(f"   🗑️  Deleted old log: {log_file.name}")
                if logger:
                    logger.log(f"Deleted old log: {log_file.name}")
            except Exception as e:
                print(f"   ❌ Failed to delete {log_file.name}: {e}")
                if logger:
                    logger.log(f"Failed to delete {log_file.name}: {e}", "ERROR")
    
    if deleted_count > 0:
        print(f"✅ Cleaned up {deleted_count} old log files")
        if logger:
            logger.log(f"Cleaned up {deleted_count} old log files")
    else:
        print("✅ No old log files to clean up")
        if logger:
            logger.log("No old log files to clean up")

# =============================================
# CORE SCANNING FUNCTIONS
# =============================================

def calculate_sha256(file_path):
    """Calculate SHA256 hash of a file"""
    sha256_hash = hashlib.sha256()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()
    except Exception as e:
        error_msg = f"Error calculating hash for {file_path}: {e}"
        print(f"❌ {error_msg}")
        if logger:
            logger.log_error(os.path.basename(file_path), error_msg)
        return None

def get_detailed_analysis(file_hash):
    """Get detailed analysis results showing which vendors flagged as malicious"""
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
        error_msg = f"Error getting detailed analysis: {e}"
        print(f"❌ {error_msg}")
        return None

# =============================================
# RISK ASSESSMENT & CATEGORIZATION
# =============================================

def is_safe_detection_type(result_string):
    """Check if detection is considered safe (PUP/PUA/Riskware)"""
    if not result_string:
        return False
    result_lower = result_string.lower()
    safe_indicators = ['pup', 'pua', 'riskware', 'potentially unwanted', 'unwanted', 'adware']
    
    for indicator in safe_indicators:
        if indicator in result_lower:
            return True
    return False

def is_malicious_detection_type(result_string):
    """Check if detection is considered malicious (Virus/Trojan/Malware)"""
    if not result_string:
        return False
    result_lower = result_string.lower()
    malicious_indicators = ['trojan', 'virus', 'malware', 'worm', 'backdoor', 'exploit', 'ransomware']
    
    for indicator in malicious_indicators:
        if indicator in result_lower:
            return True
    return False

def categorize_apk(malicious_count, suspicious_count, detailed_analysis):
    """
    Categorize APK based on detection types
    Returns: "clean" or "infected"
    """
    # 1a. Completely clean - no detections at all
    if malicious_count == 0 and suspicious_count == 0:
        return "clean"
    
    # If we have detections, analyze the types
    has_malicious_detections = False
    has_only_safe_detections = True
    
    # Check malicious detections
    for vendor, details in detailed_analysis.get("malicious", {}).items():
        result = details.get("result", "")
        if result:  # Only check if we have a result string
            if is_malicious_detection_type(result):
                has_malicious_detections = True
                has_only_safe_detections = False
            elif not is_safe_detection_type(result):
                # If it's not clearly malicious but also not safe, consider it infected
                has_malicious_detections = True
                has_only_safe_detections = False
    
    # Check suspicious detections
    for vendor, details in detailed_analysis.get("suspicious", {}).items():
        result = details.get("result", "")
        if result:  # Only check if we have a result string
            if is_malicious_detection_type(result):
                has_malicious_detections = True
                has_only_safe_detections = False
            elif not is_safe_detection_type(result):
                # If it's not clearly malicious but also not safe, consider it infected
                has_malicious_detections = True
                has_only_safe_detections = False
    
    # Final categorization
    if has_malicious_detections:
        return "infected"
    elif has_only_safe_detections:
        return "clean"
    else:
        # Default to infected if we're unsure
        return "infected"

# =============================================
# FILE MANAGEMENT FUNCTIONS
# =============================================

def organize_apk_file(apk_path, scan_result):
    """Move APK file to appropriate directory based on scan results"""
    try:
        filename = os.path.basename(apk_path)
        category = scan_result["category"]
        
        if category == "clean":
            destination = os.path.join(CLEAN_APKS_DIR, filename)
            shutil.move(apk_path, destination)
            print(f"📁 MOVED TO CLEAN: {colorize_apk_name(filename)}")
            if logger:
                logger.log_file_move(filename, "Clean_and_Safe_APKs")
            return "clean"
        else:  # infected
            destination = os.path.join(INFECTED_APKS_DIR, filename)
            shutil.move(apk_path, destination)
            print(f"🚨 MOVED TO INFECTED: {colorize_apk_name(filename)}")
            if logger:
                logger.log_file_move(filename, "Infected_and_High_Risk_APKs")
            return "infected"
            
    except Exception as e:
        error_msg = f"Failed to move file {filename}: {e}"
        print(f"❌ {error_msg}")
        if logger:
            logger.log_error(filename, error_msg)
        return "failed"

def save_scan_result(apk_path, scan_result):
    """Save detailed scan results to file"""
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
            
            # Add sandbox analysis if available
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
        
        print(f"💾 Scan result saved: {result_filename}")
        if logger:
            logger.log(f"Scan result saved: {result_filename}")
        return True
        
    except Exception as e:
        error_msg = f"Failed to save scan result: {e}"
        print(f"❌ {error_msg}")
        if logger:
            logger.log_error(os.path.basename(apk_path), error_msg)
        return False

# =============================================
# ENHANCED POWER SCANNING LOGIC (v1.4.1)
# =============================================

def power_scan_apk(apk_path, vt_client):
    """Enhanced APK scanning with SDK and sandbox analysis"""
    apk_name = os.path.basename(apk_path)
    print(f"\n🔍 Processing: {colorize_apk_name(apk_name)}")
    if logger:
        logger.log_apk_processing(apk_name, str(apk_path.parent))
    
    # Calculate file hash
    file_hash = calculate_sha256(apk_path)
    if file_hash:
        print(f"📄 Hash: {file_hash[:16]}...")
    
    # Perform hash lookup using available method
    hash_result = vt_client.get_file_analysis(file_hash)
    
    if hash_result["status"] == "found":
        # Extract data based on method used
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
        
        print(f"✅ Hash found for {colorize_apk_name(apk_name)}: {malicious_count} malicious, {suspicious_count} suspicious out of {total_vendors} vendors")
        if logger:
            logger.log_hash_result(apk_name, malicious_count, suspicious_count, total_vendors)
        
        # Get sandbox verdicts
        sandbox_verdicts = extract_sandbox_verdicts(full_data)
        if sandbox_verdicts:
            print_sandbox_analysis(sandbox_verdicts, apk_name)
            if logger:
                logger.log_sandbox_analysis(apk_name, sandbox_verdicts)
        
        # Get detailed analysis for proper categorization
        detailed_analysis = get_detailed_analysis(file_hash)
        
        # Categorize based on detection types
        category = categorize_apk(malicious_count, suspicious_count, detailed_analysis)
        
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
        
        # Print detailed report for categorization
        safe_detections, malicious_detections = print_categorization_report(apk_name, file_hash, result_data, detailed_analysis)
        if logger:
            logger.log_categorization(apk_name, category, safe_detections, malicious_detections)
        
        # Organize file and save results
        move_result = organize_apk_file(apk_path, result_data)
        save_scan_result(apk_path, result_data)
        
        return result_data
        
    elif hash_result["status"] == "rate_limited":
        print("⚠️  Rate limited - waiting 60 seconds")
        if logger:
            logger.log_rate_limit()
        time.sleep(60)
        # Retry the scan
        return power_scan_apk(apk_path, vt_client)
        
    elif hash_result["status"] == "not_found":
        print(f"🔍 Hash not found for {colorize_apk_name(apk_name)}")
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
        print(f"❌ {error_msg}")
        if logger:
            logger.log_error(apk_name, f"Hash check failed: {hash_result['status']}")
        return {
            "file": apk_name,
            "path": str(apk_path),
            "category": "unknown",
            "reason": hash_result["status"],
            "method": "hash_lookup"
        }

def print_categorization_report(filename, file_hash, scan_result, detailed_analysis):
    """Print detailed categorization report"""
    print(f"\n🏷️  CATEGORIZATION: {colorize_apk_name(filename)}")
    print("=" * 60)
    
    category = scan_result["category"]
    malicious_count = scan_result["malicious"]
    suspicious_count = scan_result["suspicious"]
    
    print(f"📊 Detection Summary: {malicious_count} malicious, {suspicious_count} suspicious")
    print(f"📁 Final Category: {category.upper()}")
    print(f"🔗 VirusTotal Report: https://www.virustotal.com/gui/file/{file_hash}")
    
    safe_detections = 0
    malicious_detections = 0
    
    if detailed_analysis:
        print(f"\n🔍 DETECTION ANALYSIS for {colorize_apk_name(filename)}:")
        print("-" * 50)
        
        # Analyze malicious vendors
        for vendor, details in detailed_analysis.get("malicious", {}).items():
            result = details["result"] if details["result"] else "Generic detection"
            if is_safe_detection_type(result):
                safe_detections += 1
                print(f"   ✅ {vendor}: {result} (PUP/PUA/Riskware - SAFE)")
            else:
                malicious_detections += 1
                print(f"   ❌ {vendor}: {result} (MALICIOUS)")
        
        # Analyze suspicious vendors
        for vendor, details in detailed_analysis.get("suspicious", {}).items():
            result = details["result"] if details["result"] else "Suspicious behavior"
            if is_safe_detection_type(result):
                safe_detections += 1
                print(f"   ✅ {vendor}: {result} (PUP/PUA/Riskware - SAFE)")
            else:
                malicious_detections += 1
                print(f"   ❌ {vendor}: {result} (MALICIOUS)")
        
        print(f"\n📈 FINAL ASSESSMENT for {colorize_apk_name(filename)}: {safe_detections} safe detections, {malicious_detections} malicious detections")
    
    return safe_detections, malicious_detections

# =============================================
# MAIN POWER SCANNING LOGIC
# =============================================

def get_apk_files_from_directories(directories):
    """Get APK files from specified directories (no subfolders)"""
    all_apk_files = []
    
    for directory in directories:
        print(f"📂 Scanning directory: {directory}")
        if logger:
            logger.log(f"Scanning directory: {directory}")
        
        if not os.path.exists(directory):
            print(f"   ❌ Directory does not exist, skipping")
            if logger:
                logger.log(f"Directory does not exist: {directory}", "WARNING")
            continue
            
        # Get only files in the immediate directory (no subfolders)
        apk_files = [f for f in Path(directory).glob("*.apk") if f.is_file()]
        
        print(f"   📁 Found {len(apk_files)} APK files")
        if logger:
            logger.log(f"Found {len(apk_files)} APK files in {directory}")
        for apk_file in apk_files:
            print(f"      • {colorize_apk_name(apk_file.name)}")
        
        all_apk_files.extend(apk_files)
    
    return all_apk_files

def power_scan_all():
    """Main scanning function with enhanced features"""
    global logger
    logger = ScanLogger()
    
    print(f"🚀 Starting VirusTotal PowerScanner v{VERSION}")
    print("🎨 True Color System: Each APK gets a unique color for this session")
    print("🔬 Enhanced Features: Hybrid API Client, Sandbox Analysis, Smart Fallback")
    print("📋 Target directories:")
    for directory in SCAN_DIRECTORIES:
        print(f"   • {directory}")
    print()
    
    # Initialize directory structure
    initialize_directories()
    
    # Clean up old logs
    cleanup_old_logs()
    
    # Initialize VT client
    vt_client = VTAPIClient(API_KEY)
    sdk_available = vt_client.initialize()
    
    method = "SDK" if sdk_available else "Requests"
    print(f"🔧 Using {method} for API calls")
    
    # Find APK files from all specified directories
    apk_files = get_apk_files_from_directories(SCAN_DIRECTORIES)
    
    if not apk_files:
        print("❌ No APK files found in any of the specified directories")
        logger.log("No APK files found in any directory", "WARNING")
        return
    
    print(f"\n📁 Total APK files found: {len(apk_files)}")
    logger.log_scan_start(len(apk_files), method)
    
    results = {
        "clean": [],
        "infected": [],
        "unknown": []
    }
    
    for i, apk_file in enumerate(apk_files, 1):
        apk_name = apk_file.name
        print(f"\n📋 File {i}/{len(apk_files)}")
        print(f"📍 Path: {apk_file.parent}")
        
        result = power_scan_apk(apk_file, vt_client)
        
        # Categorize results
        category = result.get("category", "unknown")
        if category == "clean":
            results["clean"].append(result)
            print(f"✅ CLEAN: {colorize_apk_name(apk_name)}")
        elif category == "infected":
            results["infected"].append(result)
            print(f"🚨 INFECTED: {colorize_apk_name(apk_name)}")
        else:
            results["unknown"].append(result)
            print(f"❓ UNKNOWN: {colorize_apk_name(apk_name)}")
        
        # Rate limiting between files
        if i < len(apk_files):
            print("⏳ Waiting 15 seconds before next file...")
            time.sleep(15)
    
    # Close VT client
    vt_client.close()
    
    # Print final summary with exact formatting
    print_final_summary(results)
    
    logger.log_scan_complete(len(results['clean']), len(results['infected']), len(results['unknown']))
    
    # Show organized results with colored APK names
    print(f"\n📁 ORGANIZED FILES:")
    print(f"   ✅ Clean & Safe APKs: {CLEAN_APKS_DIR}")
    if results['clean']:
        for file in results['clean']:
            print(f"      • {colorize_apk_name(file['file'])}")
    
    print(f"   🚨 Infected & High Risk APKs: {INFECTED_APKS_DIR}")
    if results['infected']:
        for file in results['infected']:
            print(f"      • {colorize_apk_name(file['file'])}")
    
    print(f"   📋 Scan Results: {SCAN_RESULTS_DIR}")
    print(f"   📝 Scan Logs: {SCAN_LOGS_DIR}")
    
    # Show the current session log file
    print(f"   📄 Current Session Log: {logger.log_file}")

if __name__ == "__main__":
    # Set your API key in .env file as VT_API_KEY=your_api_key_here
    if not API_KEY:
        print("❌ Please set VT_API_KEY in your .env file")
        exit(1)    

    # Start enhanced scanning
    power_scan_all()
