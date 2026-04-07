# Presentation Layer

`Luna's Quest` now has a bespoke title-screen shell in front of a richly styled combat scene. Both are authored against fixed `1920x1080` compositions and scaled at runtime, and the repo's recent asset pass has made the presentation layer easier to reason about as a set of named art domains instead of loose top-level files.

## Scene Ownership

- `project.godot` now boots into `scenes/title_screen.tscn`.
- `scenes/title_screen.tscn` is the front-door shell with background art, texture buttons, and bark audio.
- `scripts/title_screen.gd` handles viewport scaling, button feedback, scene handoff, and bark playback.
- `scenes/main.tscn` is the playable combat screen.
- `scenes/card_ui.tscn` is the reusable card view for hand cards and pile cards.
- `scenes/unit_status_bars.tscn` renders combined HP and block bars.

## Title Screen Presentation

- The title screen is authored against a `1920x1080` `TitleCanvas` and centered inside the viewport with black fill around the composition.
- It uses large texture buttons rather than stock Godot button styling.
- Buttons idle-bounce even when untouched.
- Hover or cursor proximity increases lift, scale, brightness, and slight rotation, making the front door feel animated before the player clicks.
- One button performs an immediate scene change into combat; the other plays a bark sound effect without leaving the screen.

## Card Presentation

- Cards support hover, drag start, drag motion, drag end, and animated return-to-rest transforms.
- Hand cards fan out visually with overlap, arc, lift, and hover emphasis.
- Draw and discard piles reuse the card scene in face-down or top-card-preview form.
- Rules text can render as rich text so modified values are color-highlighted in the card body.

## Battle Screen Presentation

- The combat scene is authored against a `1920x1080` composition and scaled to the viewport at runtime.
- Lucide SVG icons are used for intent and quick-stat UI.
- The palette emphasizes warm golds against dark blue/black panels, supporting the anxious-but-cozy tone.
- Buttons, panels, and labels are styled directly in GDScript rather than through a shared theme resource.
- The latest layout pass moves `Try Again` below `End Turn`, making the reset affordance feel more like a local combat control than a competing primary action.

## Asset Organization

- Backgrounds now live under `assets/backgrounds/`.
- Character renders live under `assets/characters/`.
- Card art lives under `assets/card_art/`.
- Reusable UI frames, buttons, and atlases live under `assets/ui/`.
- App and Lucide icons live under `assets/icons/`.
- Audio feedback for the title screen currently lives under `assets/sfx/`.
- The presentation scripts continue to load shipped assets through `res://`, which keeps them aligned with Godot import/export expectations.

## Status Feedback

- HP and block bars use an atlas-texture frame with separate fill lanes.
- HP and block fills tween smoothly toward new values.
- Block display is hidden when the unit has zero block.
- Intent icons switch based on encounter state and intent kind.

## Open Questions

- Should the visual theme graduate into reusable theme resources as more scenes are added?
- Should the title screen grow into a fuller menu shell with settings, continue, and transition states?
- Will card drag/drop interactions remain the primary play input on mobile and web?
- Should the pile hover panel expand into a full pile-inspection view once decks grow larger?

## Related Pages

- [Project Overview](../overview/project-overview.md)
- [Title Screen And Shell](../systems/title-screen-and-shell.md)

## Sources

- [Title Screen And Asset Pass (2026-04-07)](../sources/title-screen-and-asset-pass-2026-04-07.md)
- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/project.godot`](/Users/jared/projects/lunasquest/project.godot)
- [`/Users/jared/projects/lunasquest/scripts/title_screen.gd`](/Users/jared/projects/lunasquest/scripts/title_screen.gd)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/scripts/card_ui.gd`](/Users/jared/projects/lunasquest/scripts/card_ui.gd)
- [`/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd`](/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd)
- [`/Users/jared/projects/lunasquest/scenes/title_screen.tscn`](/Users/jared/projects/lunasquest/scenes/title_screen.tscn)
- [`/Users/jared/projects/lunasquest/scenes/main.tscn`](/Users/jared/projects/lunasquest/scenes/main.tscn)
- [`/Users/jared/projects/lunasquest/scenes/card_ui.tscn`](/Users/jared/projects/lunasquest/scenes/card_ui.tscn)
- [`/Users/jared/projects/lunasquest/scenes/unit_status_bars.tscn`](/Users/jared/projects/lunasquest/scenes/unit_status_bars.tscn)
