<!-- TR-SHIM-NOTE: start -->
**Note:** This repository relies on a local Python-based `tr` shim (~/bin/tr) to provide Unicode-safe `tr` behavior for legacy scripts. We only modify files under `termux-ecosystem/` by default; non-ecosystem scripts remain unchanged unless explicitly requested. See ./_tr_migration_reports_* for details.
<!-- TR-SHIM-NOTE: end -->


## Termux Ecosystem helper commands

- Copypad helper: `copypad` (installed to Termux system bin).
- Run local audit: `scripts/ci-audit.sh`
- Run quick palette test: `tests/test_palette.sh`
- Restore latest bin/cml backup: `cp -a backups/$(ls -1t backups | grep cml | head -n1) bin/cml && chmod +x bin/cml`
- Logs: `logs/swatches.log` and `logs/ci/*`


### Quick local bootstrap (Termux)
1. Ensure termux-api installed: `pkg install -y termux-api`
2. Ensure copypad is available: `copypad` (or `~/bin/copypad`)
3. Run local audit: `bash scripts/ci-audit.sh`
4. Run tests: `bash tests/matrix-run.sh`
5. Inspect logs: `ls -1 logs/ci tests/logs`

