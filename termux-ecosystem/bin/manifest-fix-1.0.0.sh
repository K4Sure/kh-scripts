TMPDIR="${XDG_RUNTIME_DIR:-$HOME/.cache/tmp}"
#!/usr/bin/env sh
# manifest-fix v1.0.0 - non-destructive fixer: prints suggested JSON to stdout (dry-run) or --apply to overwrite
set -eu
APPLY=0
for a in "$@"; do case "$a" in --apply) APPLY=1 ;; esac; done
for f in $(find manifests -type f -name '*.json' -o -name '*.manifest.json' 2>/dev/null); do
  echo "Inspecting: $f"
  tmp=$(mktemp)
  cat > "$tmp" <<'PY'
import json,sys,os
p=sys.argv[1]
j=json.load(open(p))
changed=False
if 'name' not in j or not j.get('name'):
    j['name']=os.path.splitext(os.path.basename(p))[0]
    changed=True
if 'version' not in j or not j.get('version'):
    j['version']='v0.0.1'
    changed=True
if 'type' not in j or not j.get('type'):
    j['type']='library'
    changed=True
if 'entry' not in j or not j.get('entry'):
    # try to guess an entry under lib/ or bin/ with same base name
    base=os.path.splitext(os.path.basename(p))[0]
    cand=['bin/'+base+'.sh','lib/'+base+'/'+base+'.sh']
    for c in cand:
        if os.path.exists(c):
            j['entry']=c; changed=True; break
print(json.dumps(j, indent=2))
sys.exit(0 if changed else 2)
PY
  python "$tmp" "$f" > "${f}.suggest" 2>/dev/null || true
  if [ $APPLY -eq 1 ]; then
    mv "${f}.suggest" "$f" && echo "Applied fixes to $f" || echo "No changes for $f"
  else
    echo "Suggestion saved to: ${f}.suggest (use --apply to overwrite)"
  fi
  rm -f "$tmp"
done
echo "manifest-fix: done"
