# AGENTS

## Godot Asset Imports

- When adding or replacing images, audio, fonts, or other importable assets, always commit both the source file and the matching `.import` file.
- Do not commit anything under `.godot/`. Godot regenerates imported cache artifacts there.
- Prefer loading packaged assets through Godot's resource system with `preload("res://...")` or `load("res://...")`.
- Do not use `Image.load_from_file(ProjectSettings.globalize_path(...))` or other direct filesystem reads for shipped game assets. That can work locally and still fail in exported web builds.
- If an asset must be discoverable at runtime, keep it under a tracked `res://` path and verify it is included by the export preset.
- For textures used by scenes or UI, prefer direct resource references over string indirection when practical so export detection stays reliable.

## Web Export

- Treat the web build as a packaged runtime, not a normal filesystem environment.
- After adding new imported assets, verify the web export path still includes them and avoid relying on stale export caches.
