# Quick copy commands (one-line) - generated
- Run preflight: ~/kh-scripts/termux-ecosystem/bin/te-preflight-1.0.1.sh
- Run full smoke: ~/kh-scripts/termux-ecosystem/bin/te-smoke.sh
- Regenerate wrappers (example): ~/kh-scripts/termux-ecosystem/bin/te-wrapper-gen.sh sh pml-helper 1.0.1
- Propagate shims (apply + backup): ~/kh-scripts/tools/propagate-shims.sh --apply --backup
- Restore backups (example): for f in ~/kh-scripts/backups/<timestamp>/*.orig; do cp -p "$f" ~/kh-scripts/termux-ecosystem/$(basename "$f" .orig); done
