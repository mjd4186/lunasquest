# AGENTS

- `Luna's Quest` is a Godot 4.6 project. Main scene: `res://scenes/main.tscn`.
- End goal: a deck-building roguelike that pays tribute to and aims to mimic behavior patterns from `Slay the Spire 2`, `Across the Obelisk`, and `Monster Train`.
- Most repo code and content lives in `scenes/`, `scripts/`, `assets/`, and `data/`.
- When adding or replacing importable assets, commit both the source file and its matching `.import` file.
- Never commit `.godot/`; Godot regenerates it.
- Load shipped assets through `res://` with `preload()` or `load()`, not direct filesystem reads.
- Treat the web export as a packaged runtime. Make sure new assets are tracked under `res://` and included in export.
