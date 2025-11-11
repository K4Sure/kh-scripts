# ONBOARDING master commands — live enumeration

Generated: 20251111T113030

## Quick start (one-liners)
- Run preflight check
  ~/kh-scripts/termux-ecosystem/bin/te-preflight-1.0.1.sh

- Run full placeholder smoke tests
  ~/kh-scripts/termux-ecosystem/bin/te-smoke.sh

- Show recent smoke trace (first 240 lines)
  sed -n '1,240p' ~/kh-scripts/termux-ecosystem/logs/te-smoke-trace_*.log | head -n 240

- Push current branch when ready
  git -C ~/kh-scripts push origin HEAD

## Canonical helpers (short purpose)
Python helpers (placeholder stubs used by te-smoke)

### python-helpers (live listing)

- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/json-tool_v1.0.0.py
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/json-tool_v1.0.0.py.tmp.20251111T110750
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/json-tool_v1.0.1.py
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/json-tool_v1.0.1.py.tmp.20251111T110750
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/manifest-gen_v1.0.0.py
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/manifest-gen_v1.0.0.py.tmp.20251111T110750
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/manifest-gen_v1.0.1.py
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/python-helpers/manifest-gen_v1.0.1.py.tmp.20251111T110750

## bin helpers (live listing)
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/ci-local.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/cml
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/create-structure-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/dev-setup.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/manifest-fix-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/manifest-lint-1.1.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-backup-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-gen
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-install-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-install-1.1.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-lib-smoke-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-lib-smoke-1.1.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-lib-smoke-1.2.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-lib-smoke-1.3.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-lib-smoke-1.4.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-lib-smoke-1.5.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-log-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-preflight-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-preflight-1.0.1.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-restore-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-run-1.0.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-run-1.0.0.sh.auto.snapshot.1762792710.bak
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-run-1.0.0.sh.pre.orch.1762793031.bak
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-run-1.1.0.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-smoke.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-wrapper-gen.sh
- /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/bin/te-wrapper-gen.sh.bak

## Themes and presets (verified entries)
(see repo for details — these were validated during the session)

## Repo hygiene, backups and safe repair commands
- Inspect recent auto-fix backups:
  ls -l ~/kh-scripts/backups | tail -n 50

- Restore a backed-up original file (example)
  cp -p ~/kh-scripts/backups/<backup-dir>/<file>.orig ~/kh-scripts/termux-ecosystem/<target-path> && git -C ~/kh-scripts add -A && git -C ~/kh-scripts commit -m "restore: <file> from backup" --no-verify

Placeholder smoke: 18 passed, 0 failed; backups archived -> archive_confirmed_20251111T114418
