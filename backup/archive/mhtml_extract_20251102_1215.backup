import os, sys, re, base64, email
from bs4 import BeautifulSoup

if len(sys.argv) != 2:
    print("USAGE: python mhtml_extract.py <path_to_mhtml>")
    sys.exit(1)

src = sys.argv[1]
if not os.path.exists(src):
    print(f"❌ FILE NOT FOUND: {src}")
    sys.exit(1)

# Read the MHTML as a multipart email message
with open(src, "rb") as f:
    msg = email.message_from_binary_file(f)

# Prepare output directory
outdir = os.path.splitext(src)[0] + "_extracted"
os.makedirs(outdir, exist_ok=True)
html_path = os.path.join(outdir, "index.html")

html_content = ""
res_count = 0

for part in msg.walk():
    ctype = part.get_content_type()
    cid = part.get("Content-ID", "")
    if ctype == "text/html":
        html_content = part.get_payload(decode=True).decode("utf-8", errors="replace")
        continue
    if "image" in ctype or "css" in ctype or "javascript" in ctype:
        res_count += 1
        content = part.get_payload(decode=True)
        # sanitize name
        cid_clean = re.sub(r'[^a-zA-Z0-9_.-]', '_', cid)
        ext = ".bin"
        if "jpeg" in ctype: ext = ".jpg"
        elif "png" in ctype: ext = ".png"
        elif "gif" in ctype: ext = ".gif"
        elif "css" in ctype: ext = ".css"
        elif "javascript" in ctype: ext = ".js"
        fname = f"{cid_clean or 'resource_' + str(res_count)}{ext}"
        with open(os.path.join(outdir, fname), "wb") as f:
            f.write(content)

# Fix cid references
soup = BeautifulSoup(html_content, "html.parser")
for tag in soup.find_all(["img", "link", "script"]):
    attr = "src" if tag.name in ["img", "script"] else "href"
    if tag.has_attr(attr):
        old = tag[attr]
        if old.startswith("cid:"):
            tag[attr] = re.sub(r'[^a-zA-Z0-9_.-]', '_', old[4:])

with open(html_path, "w", encoding="utf-8") as f:
    f.write(str(soup))

print(f"✔ EXTRACTED: {res_count} RESOURCES")
print(f"📂 OUTPUT: {outdir}")
print(f"📄 MAIN HTML: {html_path}")
