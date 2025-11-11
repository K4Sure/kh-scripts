# Smoke version alignment 20251111T102307
- YAML: add real 'version: X.Y.Z' keys at the top
- CONF: ensure first non-empty line is 'version=X.Y.Z'
- Files: /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/base_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/override_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/edge_base_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/cml/themes/edge_ovr_v1.0.0.yaml /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/dbml/presets/box-wide_v1.0.0.conf /data/data/com.termux/files/home/kh-scripts/termux-ecosystem/lib/dbml/presets/box-double_v1.0.0.conf
- Backups: /data/data/com.termux/files/home/kh-scripts/backups/smoke_version_alignment_20251111T102307/*.orig
- Rollback: cp -p backups/smoke_version_alignment_20251111T102307/*.orig <target>
