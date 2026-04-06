# Project Overview

`Luna's Quest` is currently a one-encounter Godot 4.6 combat prototype built around a frightened little dog navigating a hostile hallway. The game already has a playable loop with card-driven combat, starter-deck data, buff cards, enemy intents, and a polished UI layer, but it does not yet have run structure, rewards, encounter progression, or broader content systems.

## Current Playable Slice

- Main scene: `res://scenes/main.tscn`
- Player avatar: Luna, represented in combat as "The Little Dog"
- Prototype enemy: "The Dark Hallway"
- Core loop: shuffle starting deck, draw a hand, spend courage on cards, resolve a monster intent, repeat until victory or defeat
- Content source of truth: `data/cards.json` and `data/starting_deck.json`

## Design Direction

- Stated target: a deck-building roguelike influenced by `Slay the Spire 2`, `Across the Obelisk`, and `Monster Train`
- Current tone: anxious-but-cozy, with fear framed as an emotional and mechanical obstacle rather than pure horror
- Current mechanical identity: block and sustain tools, persistent comfort-item buffs, and one X-cost finisher

## Repo Map

- `scripts/`: combat state, main combat scene logic, card loading, reusable UI scripts
- `scenes/`: main combat scene plus reusable card/status-bar scenes
- `data/`: card definitions and starter-deck composition
- `assets/`: Lucide icons and imported art assets
- `ideas.md`: loose design backlog

## Known Gaps

- No run map, node graph, or encounter sequencing
- No post-combat rewards, card picks, shop flow, or relic system
- Only one enemy and one battle context
- No save/load, meta-progression, or account for web-export persistence
- No structured wiki ingest for future design docs, playtest notes, or art direction yet beyond this initial snapshot

## Good Next Ingests

- The scene hierarchy in `scenes/main.tscn` to document layout and UI ownership in more detail
- Art coverage in `assets/card_art/`, `assets/ui/`, and the other organized asset folders
- Any future progression/reward prototype code or data
- Playtest notes once the prototype is being tuned against desired roguelike references

## Related Pages

- [Combat Loop](../systems/combat-loop.md)
- [Card And Deck Model](../systems/card-and-deck-model.md)
- [Current Card Pool](../content/current-card-pool.md)
- [Luna](../entities/luna.md)
- [The Dark Hallway](../entities/the-dark-hallway.md)
- [Design Backlog](../backlog/design-backlog.md)

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/AGENTS.md`](/Users/jared/projects/lunasquest/AGENTS.md)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
- [`/Users/jared/projects/lunasquest/data/starting_deck.json`](/Users/jared/projects/lunasquest/data/starting_deck.json)
