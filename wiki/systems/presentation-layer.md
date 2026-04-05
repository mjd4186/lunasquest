# Presentation Layer

The current prototype puts a surprising amount of polish into combat presentation relative to its small scope. `main.gd` owns a fixed-composition combat canvas, while `CardUI` and `UnitStatusBars` provide reusable interaction and feedback components for the battle screen.

## Scene Ownership

- `scenes/main.tscn` is the playable combat screen.
- `scenes/card_ui.tscn` is the reusable card view for hand cards and pile cards.
- `scenes/unit_status_bars.tscn` renders combined HP and block bars.

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

## Status Feedback

- HP and block bars use an atlas-texture frame with separate fill lanes.
- HP and block fills tween smoothly toward new values.
- Block display is hidden when the unit has zero block.
- Intent icons switch based on encounter state and intent kind.

## Open Questions

- Should the visual theme graduate into reusable theme resources as more scenes are added?
- Will card drag/drop interactions remain the primary play input on mobile and web?
- Should the pile hover panel expand into a full pile-inspection view once decks grow larger?

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/scripts/card_ui.gd`](/Users/jared/projects/lunasquest/scripts/card_ui.gd)
- [`/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd`](/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd)
- [`/Users/jared/projects/lunasquest/scenes/main.tscn`](/Users/jared/projects/lunasquest/scenes/main.tscn)
- [`/Users/jared/projects/lunasquest/scenes/card_ui.tscn`](/Users/jared/projects/lunasquest/scenes/card_ui.tscn)
- [`/Users/jared/projects/lunasquest/scenes/unit_status_bars.tscn`](/Users/jared/projects/lunasquest/scenes/unit_status_bars.tscn)
