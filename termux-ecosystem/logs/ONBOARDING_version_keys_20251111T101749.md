# Version keys 20251111T101749
- Scope: Insert concrete version keys expected by smoke tests
- YAML: "version: X.Y.Z" (after '---' if present)
- CONF: "version=X.Y.Z" on first line
- Files: /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/base_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/override_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/edge_base_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/edge_ovr_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/dbml/presets/box-wide_v1.0.0.conf /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/dbml/presets/box-double_v1.0.0.conf
- Backups: /data/data/com.termux/files/home/kh-scripts/backups/version_keys_20251111T101749/*.orig
- Rollback: cp -p backups/version_keys_20251111T101749/*.orig <target-path>
