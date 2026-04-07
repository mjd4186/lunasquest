# Title Screen And Shell

`Luna's Quest` now has a lightweight front door before combat: the game boots into a dedicated title screen, lets the player trigger a bark interaction or start immediately, and then hands off into the existing single-battle prototype. This is the first clear shell layer outside the combat scene itself.

## Current Flow

- `project.godot` sets `run/main_scene` to `res://scenes/title_screen.tscn`.
- Pressing the title screen's play button calls `change_scene_to_file("res://scenes/main.tscn")`.
- Pressing the bark button plays a dog-bark sound through `AudioStreamPlayer`.
- The shell currently has no continue flow, options menu, profile selection, or return path from combat back into a wider run structure.

## Interaction Model

- The title screen is authored around a `1920x1080` `TitleCanvas`.
- `_update_canvas_transform()` scales and centers that canvas to fit the live viewport.
- Button defaults are stored once, then `_process()` updates both buttons every frame.
- Cursor proximity within a `210` pixel radius increases button lift, scale, brightness, and rotation.
- Buttons also idle-bounce even when untouched, so the screen feels animated before the player clicks anything.

## Steering Notes

- Direct fact: the runtime entry point changed from direct combat boot to a bespoke title scene with custom art and sound.
- Direct fact: the combat prototype still lives in its own scene and is entered through an immediate scene swap.
- `Inference:` this work marks a shift from "combat prototype only" toward a fuller game shell, even if the shell is still very thin.
- `Inference:` the use of large authored texture buttons instead of stock controls suggests a preference for bespoke illustrated presentation as part of the game's identity.

## Open Questions

- Should this screen grow into a fuller front end with continue, settings, and save-slot logic, or stay minimal until run structure exists?
- How should combat outcomes route back into the shell once rewards, progression, or run failure states are added?
- Do the fixed button positions need alternate layouts or safe-area handling for smaller web-export viewports?

## Related Pages

- [Project Overview](../overview/project-overview.md)
- [Presentation Layer](../systems/presentation-layer.md)
- [Luna](../entities/luna.md)
- [Design Backlog](../backlog/design-backlog.md)

## Sources

- [Title Screen And Asset Pass (2026-04-07)](../sources/title-screen-and-asset-pass-2026-04-07.md)
- [`/Users/jared/projects/lunasquest/project.godot`](/Users/jared/projects/lunasquest/project.godot)
- [`/Users/jared/projects/lunasquest/scenes/title_screen.tscn`](/Users/jared/projects/lunasquest/scenes/title_screen.tscn)
- [`/Users/jared/projects/lunasquest/scripts/title_screen.gd`](/Users/jared/projects/lunasquest/scripts/title_screen.gd)
- [`/Users/jared/projects/lunasquest/scenes/main.tscn`](/Users/jared/projects/lunasquest/scenes/main.tscn)
