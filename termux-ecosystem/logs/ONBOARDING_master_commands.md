# ONBOARDING — Master one-line commands (generated)
Generated: TS

## Preflight and checks
- Run preflight check: ~/kh-scripts/termux-ecosystem/bin/te-preflight-1.0.1.sh
- Run full placeholder smoke (validation): ~/kh-scripts/termux-ecosystem/bin/te-smoke.sh

## Shim and wrapper management
- Propagate shims (apply with backups): ~/kh-scripts/tools/propagate-shims.sh --apply --backup
- Regenerate a specific wrapper (examples):
  - sh wrapper (pml-helper): ~/kh-scripts/termux-ecosystem/bin/te-wrapper-gen.sh sh pml-helper 1.0.1
  - yaml wrapper (theme-default): ~/kh-scripts/termux-ecosystem/bin/te-wrapper-gen.sh yaml theme-default 1.0.1
  - conf wrapper (box-thin): ~/kh-scripts/termux-ecosystem/bin/te-wrapper-gen.sh conf box-thin 1.0.0

## Python helpers
- Run json-tool helper: ~/kh-scripts/termux-ecosystem/lib/python-helpers/json-tool_v1.0.1.py
- Run manifest-gen helper: ~/kh-scripts/termux-ecosystem/lib/python-helpers/manifest-gen_v1.0.1.py

## Restores and rollbacks
- Restore backups (example, replace <timestamp> with the folder you want):
  for f in ~/kh-scripts/backups/<timestamp>/*.orig; do cp -p "$f" ~/kh-scripts/termux-ecosystem/$(basename "$f" .orig); done

## Quick developer tasks
- Show recent commits: git --no-pager log --oneline --decorate -n 8
- Show backup folders: ls -ld ~/kh-scripts/backups/* | sed -n '1,50p'
- Inspect shim propagation audit: less ~/kh-scripts/termux-ecosystem/logs/_shim_propagation_*.log

## Notes and audit
- Backups are always created under ~/kh-scripts/backups/ with timestamped folders.
- Onboarding logs and notes are in ~/kh-scripts/termux-ecosystem/logs/ (files named ONBOARDING_*.md).
- If a change feels unsafe, stop and restore from the matching backup folder.

