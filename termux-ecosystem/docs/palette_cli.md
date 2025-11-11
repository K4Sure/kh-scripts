Palette CLI (local-first)
- Base: use `base` or `edge_base`, or pass a YAML path.
- Overrides: pass file paths or pipe raw `key: "#hex"` and add `-` (the wrapper auto-appends for piped stdin).
- Last-wins: later inputs override earlier ones.
- Normalization: keys lowercase; values trimmed and de-quoted.

Examples:
- File merge: `cml_palette_norm_wrap_v0.1.0.sh base lib/cml/themes/override_v1.0.0.yaml`
- Stdin override: `printf 'z: "#111111"\n' | cml_palette_norm_wrap_v0.1.0.sh edge_base`

CLI shim
- Use `bin/cml palette ...` for globally callable, local-first workflows.
- Behaves like the normalization wrapper with stdin ergonomics.
