#!/usr/bin/env python3
# large_apk_scanner_v1.0.1.py
# Visual style synchronized with detailed_apk_scanner_v1.5.7
# Same directories, same .env, but supports uploads up to 650 MB.

import os, sys, json, time, random, shutil, hashlib, requests
from pathlib import Path
from datetime import datetime, timedelta
from dotenv import load_dotenv

VERSION = "1.0.1"
PROJECT_DIR = "/data/data/com.termux/files/home/kh-scripts/virustotal"
ENV_FILE = os.path.join(PROJECT_DIR, ".env")
if os.path.exists(ENV_FILE):
    load_dotenv(ENV_FILE)

API_KEY = os.getenv("VT_API_KEY", "")
HEADERS = {"x-apikey": API_KEY}
BASE_URL = "https://www.virustotal.com/api/v3"

# ===== Directory Layout =====
APK_BASE = "/storage/emulated/0/Download/APKs"
CLEAN_APKS_DIR = f"{APK_BASE}/Clean_and_Safe_APKs"
INFECTED_APKS_DIR = f"{APK_BASE}/Infected_and_High_Risk_APKs"
TOO_LARGE_DIR = f"{APK_BASE}/Too_Large_For_VT_APKs"
PENDING_DIR = f"{APK_BASE}/Pending_Manual_Review_APKs"
RESULTS_DIR = f"{APK_BASE}/Termux–VirusTotal_Scan_Results"
LOGS_DIR = f"{APK_BASE}/Termux–VirusTotal_Scan_Logs"
BACKUP_DIR = f"{PROJECT_DIR}/backup"
for d in [CLEAN_APKS_DIR, INFECTED_APKS_DIR, TOO_LARGE_DIR,
          PENDING_DIR, RESULTS_DIR, LOGS_DIR, BACKUP_DIR]:
    os.makedirs(d, exist_ok=True)

SCAN_DIRS = [
    "/storage/emulated/0/Download/1DMP/Programs",
    "/storage/emulated/0/Download/Obtainium",
    "/storage/emulated/0/Download"
]

# ===== CML TrueColor Palette (fallback copy of your v1.5.7 colors) =====
RESET = "\033[0m"
NEON_GREEN  = "\033[38;2;57;255;20m"
NEON_RED    = "\033[38;2;255;20;20m"
NEON_YELLOW = "\033[38;2;255;255;20m"
NEON_BLUE   = "\033[38;2;57;97;255m"
PATH_COLOR  = "\033[38;2;243;254;1m"
BOLD = "\033[1m"

def colorize_name(name:str) -> str:
    r,g,b = random.choice([(255,105,180),(30,144,255),(50,205,50),
                           (255,215,0),(138,43,226),(255,140,0),
                           (0,206,209),(255,69,0),(123,104,238),(60,179,113)])
    return f"\033[38;2;{r};{g};{b}m{name}{RESET}"

def shorten(p:str)->str:
    s = p.replace("/storage/emulated/0","~~").replace("/data/data/com.termux/files/home","~")
    return s if len(s)<70 else "..."+s[-67:]

def dual_line(left:str,right:str,width:int=60)->str:
    gap = max(1, width - len(left))
    return f"{left}{' ' * gap}{right}"

def rule_line(char="=", width=60): return char*width

def show_header():
    print(dual_line(f"{BOLD}🚀 Launching VirusTotal PowerScanner (Large) v{VERSION}{RESET}",
                    f"🔍 VirusTotal PowerScanner (Large) v{VERSION}{RESET}"))
    print()
    print(dual_line("🔬 Enhanced Features:",
                    "🧩 Hybrid API Client"))
    print(dual_line("      🧪 Sandbox Analysis",
                    "🛟 Smart Fallback"))
    print(dual_line("      🔧 Large File Uploads (up to 650 MB)",
                    "🔒 Using Direct API Calls"))
    print()

def show_summary_header(): print(rule_line("=",60))
def show_section(title): print(f"\n{rule_line('=',60)}\n{title}")

def log(msg,level="INFO"):
    ts=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        with open(f"{LOGS_DIR}/scan_session_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log","a") as f:
            f.write(f"[{ts}] [{level}] {msg}\n")
    except: pass

def sha256sum(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for chunk in iter(lambda:f.read(65536),b""): h.update(chunk)
    return h.hexdigest()

def human(n):
    for u in ["B","KB","MB","GB"]:
        if n<1024.0: return f"{n:3.1f}{u}"
        n/=1024.0
    return f"{n:.1f}TB"

# ===== REPLACEMENT PART B: scanning engine, detection logic, file moves, results =====
# Replace the previous PART B content in large_apk_scanner_v1.0.1.py with this block.

MAX_STD = 32 * 1024 * 1024
MAX_LARGE = 650 * 1024 * 1024
WAIT_BETWEEN = 15
RATE_LIMIT_WAIT = 60

# Simple detection keywords (heuristic)
SAFE_INDICATORS = ['pup','pua','riskware','potentially unwanted','unwanted','adware']
MALICIOUS_INDICATORS = ['trojan','virus','malware','worm','backdoor','exploit','ransomware']

# Detection list manager (loads JSON arrays, gracefully handles missing files)
class DetectionListManager:
    def __init__(self, project_dir):
        self.whitelist_file = os.path.join(project_dir, "whitelist.json")
        self.blacklist_file = os.path.join(project_dir, "blacklist.json")
        self.whitelist = self._load(self.whitelist_file)
        self.blacklist = self._load(self.blacklist_file)

    def _load(self, path):
        try:
            if os.path.exists(path):
                with open(path, "r", encoding="utf-8") as f:
                    arr = json.load(f)
                    return set(arr if isinstance(arr, list) else [])
        except Exception:
            pass
        return set()

    def is_whitelisted(self, vendor, result):
        t = f"{vendor}: {result}".lower()
        return any(pat.lower() in t for pat in self.whitelist)

    def is_blacklisted(self, vendor, result):
        t = f"{vendor}: {result}".lower()
        return any(pat.lower() in t for pat in self.blacklist)

detection_manager = DetectionListManager(PROJECT_DIR)

# Helper: write per-file detailed scan report
def save_scan_text_result(scan_result):
    try:
        os.makedirs(RESULTS_DIR, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        fname = f"{scan_result.get('file','unknown')}_{ts}.txt"
        path = os.path.join(RESULTS_DIR, fname)
        with open(path, "w", encoding="utf-8") as f:
            f.write(f"VirusTotal Large APK Scanner v{VERSION}\n")
            f.write("="*70 + "\n")
            f.write(f"File: {scan_result.get('file')}\n")
            f.write(f"Path: {scan_result.get('path')}\n")
            f.write(f"Size: {scan_result.get('size')}\n")
            f.write(f"Category: {scan_result.get('category')}\n")
            f.write(f"Method: {scan_result.get('method')}\n")
            if 'file_hash' in scan_result:
                f.write(f"SHA256: {scan_result.get('file_hash')}\n")
                f.write(f"VT Report: https://www.virustotal.com/gui/file/{scan_result.get('file_hash')}\n")
            if scan_result.get("detection_summary"):
                f.write("\nDETECTION SUMMARY:\n")
                for k,v in scan_result["detection_summary"].items():
                    f.write(f"  {k}: {v}\n")
            if scan_result.get("detailed"):
                f.write("\nDETAILED DETECTIONS:\n")
                i = 0
                for vendor,det in scan_result["detailed"].items():
                    if i >= 300: break
                    f.write(f"  {vendor}: {det}\n")
                    i += 1
            if scan_result.get("note"):
                f.write("\nNOTE:\n")
                f.write(f"  {scan_result.get('note')}\n")
        # small log
        try:
            with open(os.path.join(LOGS_DIR, f"scan_session_results_{datetime.now().strftime('%Y%m%d')}.log"), "a") as lf:
                lf.write(f"[{datetime.now().isoformat()}] Saved {fname}\n")
        except Exception:
            pass
        return True
    except Exception:
        return False

# Move helper (safe)
def move_file_to_folder(src_path, dest_dir):
    try:
        os.makedirs(dest_dir, exist_ok=True)
        dest = os.path.join(dest_dir, os.path.basename(src_path))
        if os.path.exists(dest):
            base, ext = os.path.splitext(os.path.basename(dest))
            dest = os.path.join(dest_dir, f"{base}_{int(time.time())}{ext}")
        shutil.move(src_path, dest)
        return dest
    except Exception:
        return None

# VT helper class (thin wrapper)
class VT:
    def __init__(self,key):
        self.s = requests.Session()
        if key:
            self.s.headers.update({"x-apikey": key})
    def get(self, path, **kwargs):
        return self.s.get(path, timeout=40, **kwargs)
    def post(self, path, files=None, **kwargs):
        return self.s.post(path, files=files, timeout=600, **kwargs)

# Extract last_analysis_results safely
def parse_last_analysis_results(vt_file_json):
    try:
        return vt_file_json.get("data", {}).get("attributes", {}).get("last_analysis_results", {})
    except Exception:
        return {}

def parse_last_analysis_stats(vt_file_json):
    try:
        return vt_file_json.get("data", {}).get("attributes", {}).get("last_analysis_stats", {})
    except Exception:
        return {}

# Main scanning loop
def scan_files():
    if not API_KEY:
        print(f"{NEON_RED}❌ VT_API_KEY missing in .env{RESET}")
        sys.exit(1)

    # header already printed in Part A run; optional here as well
    show_header()

    # gather apks
    all_apks = []
    for d in SCAN_DIRS:
        p = Path(d)
        if not p.exists(): continue
        found = sorted(list(p.glob("*.apk")))
        if found:
            print(dual_line(f"📂 Scanning Directory: {PATH_COLOR}{shorten(d)}{RESET}",
                            f"📁 Found {len(found)} APK Files"))
            for a in found:
                print(f"      • {colorize_name(a.name)}")
            all_apks.extend(found)

    if not all_apks:
        print(f"{NEON_YELLOW}❌ No APK files found.{RESET}")
        return

    print(rule_line("=", 60))
    vt = VT(API_KEY)
    results = []

    for idx, apk in enumerate(all_apks, start=1):
        print(rule_line("=", 60))
        print(f"🔍 Processing File {idx} of {len(all_apks)}: {colorize_name(apk.name)}")
        print(f"📍 Path: {PATH_COLOR}{shorten(str(apk.parent))}{RESET}")
        size = apk.stat().st_size
        print(f"💾 Size: {human(size)}")
        sha = sha256sum(apk)
        print(f"🔑 Hash: {sha[:20]}...")

        # 1) Try hash lookup
        try:
            r = vt.get(f"{BASE_URL}/files/{sha}")
        except Exception as e:
            print(f"{NEON_YELLOW}⚠️ Network error during lookup: {e}{RESET}")
            results.append({"file":apk.name,"category":"unknown","note":"network_error"})
            # move on
            if idx < len(all_apks): time.sleep(WAIT_BETWEEN)
            continue

        if r.status_code == 200:
            file_json = r.json()
            stats = parse_last_analysis_stats(file_json) or {}
            mal = stats.get("malicious", 0)
            susp = stats.get("suspicious", 0)
            tot = sum(stats.values()) if stats else 0
            # Build simple vendor->result map
            results_map = {}
            last_results = parse_last_analysis_results(file_json)
            for vendor, info in last_results.items():
                # 'result' sometimes None; fallback to category or engine name
                res = info.get("result") or info.get("category") or info.get("engine_name") or "unknown"
                results_map[vendor] = res

            # Apply whitelist/blacklist & heuristics
            mal_count = 0
            for vendor, res in results_map.items():
                if detection_manager.is_whitelisted(vendor, res):
                    continue
                if detection_manager.is_blacklisted(vendor, res):
                    mal_count += 1
                    continue
                # heuristic
                low = (res or "").lower()
                if any(k in low for k in MALICIOUS_INDICATORS):
                    mal_count += 1

            # final categorization
            category = "INFECTED" if mal_count > 0 else "CLEAN"
            color = NEON_RED if category == "INFECTED" else NEON_GREEN
            print(f"📊 Detection Summary: {mal} malicious, {susp} suspicious out of {tot}")
            print(f"🏷️  Categorization: {color}{category}{RESET}")

            # move file
            dest_dir = CLEAN_APKS_DIR if category == "CLEAN" else INFECTED_APKS_DIR
            moved = move_file_to_folder(str(apk), dest_dir)
            moved_path = moved or str(apk)
            # save result
            scan_result = {
                "file": apk.name,
                "path": moved_path,
                "size": human(size),
                "category": category,
                "method": "hash_lookup",
                "file_hash": sha,
                "detection_summary": {"malicious": mal, "suspicious": susp, "total": tot},
                "detailed": results_map
            }
            save_scan_text_result(scan_result)
            results.append(category)

        elif r.status_code == 404:
            # Not found -> attempt upload if allowed by size
            if size > MAX_LARGE:
                note = f"File larger than allowed maximum ({human(MAX_LARGE)})"
                print(f"{NEON_YELLOW}⚠️ {note}{RESET}")
                moved = move_file_to_folder(str(apk), TOO_LARGE_DIR)
                scan_result = {"file": apk.name, "path": moved or str(apk), "size": human(size), "category":"TOO_LARGE", "method":"skip_too_large", "note":note}
                save_scan_text_result(scan_result)
                results.append("TOO_LARGE")
            else:
                print(f"{NEON_BLUE}⬆️ Uploading {human(size)} to VirusTotal...{RESET}")
                upload_ok = False
                upload_resp = None
                try:
                    if size <= MAX_STD:
                        with open(apk, "rb") as f:
                            files = {"file": (apk.name, f)}
                            upload_resp = vt.post(f"{BASE_URL}/files", files=files)
                    else:
                        # try getting upload URL
                        uu = vt.get(f"{BASE_URL}/files/upload_url")
                        if uu.status_code == 200:
                            j = uu.json()
                            upload_url = (j.get("data") or {}).get("upload_url") or j.get("data")
                            if upload_url:
                                with open(apk, "rb") as f:
                                    files = {"file": (apk.name, f)}
                                    upload_resp = requests.post(upload_url, files=files, timeout=900)
                except Exception as e:
                    print(f"{NEON_YELLOW}⚠️ Upload error: {e}{RESET}")

                if upload_resp is not None and upload_resp.status_code in (200,201):
                    print(f"{NEON_GREEN}✔ Uploaded successfully. File moved to Pending for manual review while VT processes it.{RESET}")
                    moved = move_file_to_folder(str(apk), PENDING_DIR)
                    scan_result = {"file": apk.name, "path": moved or str(apk), "size": human(size), "category":"PENDING", "method":"uploaded", "note":"uploaded_wait"}
                    save_scan_text_result(scan_result)
                    results.append("PENDING")
                else:
                    print(f"{NEON_RED}❌ Upload failed or not available. Moved to Too_Large / Pending as fallback.{RESET}")
                    # fallback: move to TOO_LARGE to avoid frantic retries
                    moved = move_file_to_folder(str(apk), TOO_LARGE_DIR)
                    scan_result = {"file": apk.name, "path": moved or str(apk), "size": human(size), "category":"UPLOAD_FAILED", "method":"upload_failed", "note": str(upload_resp)}
                    save_scan_text_result(scan_result)
                    results.append("UPLOAD_FAILED")

        elif r.status_code == 429:
            print(f"{NEON_YELLOW}⚠️ Rate limited on lookup — waiting {RATE_LIMIT_WAIT}s{RESET}")
            time.sleep(RATE_LIMIT_WAIT)
            results.append("RATE_LIMIT")
        else:
            print(f"{NEON_YELLOW}⚠️ Unexpected response from VT: {r.status_code}{RESET}")
            results.append("ERROR")

        # inter-file wait
        if idx < len(all_apks):
            print(f"⏳ Waiting {WAIT_BETWEEN}s before next file...")
            time.sleep(WAIT_BETWEEN)

    # Summary block (matching v1.5.7 style)
    print(rule_line("=", 60))
    clean_count = len([x for x in results if x == "CLEAN"])
    infected_count = len([x for x in results if x == "INFECTED"])
    unknown_count = len([x for x in results if x not in ("CLEAN","INFECTED")])
    print(f"📊 Final Scan Summary:")
    print(f"      ✅ {NEON_GREEN}Clean & Safe: {clean_count}{RESET}")
    print(f"      🚨 {NEON_RED}Infected & High Risk: {infected_count}{RESET}")
    print(f"      ❓ {NEON_YELLOW}Unknown / Pending: {unknown_count}{RESET}")
    print(rule_line("=", 60))

    # Organized Files Snapshot
    try:
        clean_files = len(os.listdir(CLEAN_APKS_DIR)) if os.path.isdir(CLEAN_APKS_DIR) else 0
        inf_files = len(os.listdir(INFECTED_APKS_DIR)) if os.path.isdir(INFECTED_APKS_DIR) else 0
        too_large_files = len(os.listdir(TOO_LARGE_DIR)) if os.path.isdir(TOO_LARGE_DIR) else 0
    except Exception:
        clean_files = inf_files = too_large_files = 0

    print(f"📁 Organized Files Snapshot:")
    print(f"      ✅ Clean & Safe: {clean_files}")
    print(f"      🚨 Infected: {inf_files}")
    print(f"      ⚠️ Too Large For VT: {too_large_files}")
    print(f"\n📄 Session Log: {PATH_COLOR}{shorten(LOGS_DIR)}/scan_session_*.log{RESET}\n")

# Run scanner when this block is executed
if __name__ == "__main__":
    scan_files()
