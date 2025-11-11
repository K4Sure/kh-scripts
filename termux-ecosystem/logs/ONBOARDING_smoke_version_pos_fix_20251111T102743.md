# Smoke version position fix 20251111T102743
- Purpose: Ensure concrete version appears where smoke expects
- YAML: 'version: X.Y.Z' inserted as first mapping key after comment header
- CONF: 'version=X.Y.Z' enforced as first non-empty line, duplicates removed
- Backups: /data/data/com.termux/files/home/kh-scripts/backups/smoke_version_pos_fix_20251111T102743/*.orig
- Rollback: cp -p backups/smoke_version_pos_fix_20251111T102743/*.orig <target-path>
