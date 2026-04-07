# Title Screen And Asset Pass (2026-04-07)

This ingest captures the April 6 shell and presentation pass that moved `Luna's Quest` from booting directly into combat to opening on a bespoke title screen, while also reorganizing the repo's shipped presentation assets under a cleaner `assets/` taxonomy.

## Files Read

- [`/Users/jared/projects/lunasquest/AGENTS.md`](/Users/jared/projects/lunasquest/AGENTS.md)
- [`/Users/jared/projects/lunasquest/project.godot`](/Users/jared/projects/lunasquest/project.godot)
- [`/Users/jared/projects/lunasquest/scenes/title_screen.tscn`](/Users/jared/projects/lunasquest/scenes/title_screen.tscn)
- [`/Users/jared/projects/lunasquest/scripts/title_screen.gd`](/Users/jared/projects/lunasquest/scripts/title_screen.gd)
- [`/Users/jared/projects/lunasquest/scenes/main.tscn`](/Users/jared/projects/lunasquest/scenes/main.tscn)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/scripts/card_ui.gd`](/Users/jared/projects/lunasquest/scripts/card_ui.gd)
- [`/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd`](/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd)

## Repo History Reviewed

- `1acdb96` - Reorganize art assets under the assets directory
- `21e1a1e` - Add interactive title screen with bark and play buttons
- `87a10d5` - Enlarge and reposition title screen buttons
- `0a52e61` - Move Try Again below End Turn button

## Key Findings

- `project.godot` now boots into `res://scenes/title_screen.tscn` instead of directly into combat.
- The repo-level `AGENTS.md` still says the main scene is `res://scenes/main.tscn`; `project.godot` is the authoritative runtime source for current boot behavior.
- The title screen is a dedicated `Control` scene with authored background art, two large texture buttons, and a bark sound effect.
- `scripts/title_screen.gd` uses a fixed `1920x1080` composition that scales and centers to the current viewport, matching the combat screen's general layout approach.
- Title-screen buttons are animated rather than static: they idle-bounce and react to cursor proximity with lift, scale, brightness, and tilt.
- Combat remains a separate scene entered through `change_scene_to_file("res://scenes/main.tscn")`.
- Presentation assets are now organized under `assets/backgrounds/`, `assets/card_art/`, `assets/characters/`, `assets/icons/`, `assets/sfx/`, and `assets/ui/`.
- The combat HUD received a small usability pass: `Try Again` now sits below `End Turn`.

## Steering Read

- Direct fact: recent commits spent effort on shell polish, branded button art, audio feedback, and asset structure rather than on adding new cards, enemies, or run systems.
- `Inference:` current steering appears to be toward making the prototype feel legible and emotionally framed from the first click, not just mechanically functional once combat begins.

## Wiki Pages Updated From This Ingest

- [Project Overview](../overview/project-overview.md)
- [Title Screen And Shell](../systems/title-screen-and-shell.md)
- [Presentation Layer](../systems/presentation-layer.md)
- [Design Backlog](../backlog/design-backlog.md)
