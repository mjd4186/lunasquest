# Project Overview

`Luna's Quest` is now a Godot 4.6 prototype with a bespoke title-screen shell that hands off into a one-encounter combat slice. The project still centers on Luna confronting The Dark Hallway through card-driven combat, but recent work has also started shaping first-impression framing, asset organization, and the sense that the prototype is the front edge of a fuller game rather than a raw combat test scene.

## Current Playable Slice

- Runtime boot scene: `res://scenes/title_screen.tscn`
- Combat scene: `res://scenes/main.tscn`
- Note: `AGENTS.md` still names `res://scenes/main.tscn` as the main scene, but `project.godot` reflects the current runtime boot target.
- Player avatar: Luna, represented in combat as "The Little Dog"
- Prototype enemy: "The Dark Hallway"
- Title-screen actions: start the combat scene or trigger a bark sound interaction
- Core loop: enter through the title screen, then shuffle the starting deck, draw a hand, spend courage on cards, resolve a monster intent, and repeat until victory or defeat
- Content source of truth: `data/cards.json` and `data/starting_deck.json`

## Design Direction

- Stated target: a deck-building roguelike influenced by `Slay the Spire 2`, `Across the Obelisk`, and `Monster Train`
- Current tone: anxious-but-cozy, with fear framed as an emotional and mechanical obstacle rather than pure horror
- Current mechanical identity: block and sustain tools, persistent comfort-item buffs, and one X-cost finisher
- Recent implemented direction: bespoke title-screen presentation, audio-backed mascot interaction, and a cleaner domain-organized `assets/` tree
- `Inference:` current steering appears to emphasize stronger tone-setting and player-facing shell polish before the repo grows much broader systemic depth

## Repo Map

- `scripts/`: combat state, title-screen shell logic, card loading, and reusable UI scripts
- `scenes/`: title screen, main combat scene, and reusable card/status-bar scenes
- `data/`: card definitions and starter-deck composition
- `assets/`: organized presentation assets under `backgrounds/`, `card_art/`, `characters/`, `icons/`, `sfx/`, and `ui/`
- `ideas.md`: loose design backlog

## Known Gaps

- No run map, node graph, or encounter sequencing
- No post-combat rewards, card picks, shop flow, or relic system
- Only one enemy and one battle context
- Title screen is still a thin shell with no continue, settings, save-slot, or return-from-combat flow
- No save/load, meta-progression, or account for web-export persistence
- No structured wiki ingest yet for playtest notes, external design docs, or art-direction references beyond repo/code snapshots

## Good Next Ingests

- The handoff between title screen, combat, and any future run-start flow
- Art coverage in `assets/ui/`, `assets/backgrounds/`, `assets/characters/`, and `assets/sfx/` if provenance or style guides start to matter
- Any future progression/reward prototype code or data
- Playtest notes once the prototype is being tuned against desired roguelike references

## Related Pages

- [Combat Loop](../systems/combat-loop.md)
- [Card And Deck Model](../systems/card-and-deck-model.md)
- [Title Screen And Shell](../systems/title-screen-and-shell.md)
- [Presentation Layer](../systems/presentation-layer.md)
- [Current Card Pool](../content/current-card-pool.md)
- [Luna](../entities/luna.md)
- [The Dark Hallway](../entities/the-dark-hallway.md)
- [Design Backlog](../backlog/design-backlog.md)

## Sources

- [Title Screen And Asset Pass (2026-04-07)](../sources/title-screen-and-asset-pass-2026-04-07.md)
- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/AGENTS.md`](/Users/jared/projects/lunasquest/AGENTS.md)
- [`/Users/jared/projects/lunasquest/project.godot`](/Users/jared/projects/lunasquest/project.godot)
- [`/Users/jared/projects/lunasquest/scenes/title_screen.tscn`](/Users/jared/projects/lunasquest/scenes/title_screen.tscn)
- [`/Users/jared/projects/lunasquest/scripts/title_screen.gd`](/Users/jared/projects/lunasquest/scripts/title_screen.gd)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
- [`/Users/jared/projects/lunasquest/data/starting_deck.json`](/Users/jared/projects/lunasquest/data/starting_deck.json)
