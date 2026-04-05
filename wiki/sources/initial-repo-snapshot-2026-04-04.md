# Initial Repo Snapshot (2026-04-04)

This source page captures the first wiki ingest of the existing `Luna's Quest` repository. It summarizes the initial playable state of the project as seen in the core combat scripts, card data, and loose idea notes.

## Files Read

- [`/Users/jared/projects/lunasquest/AGENTS.md`](/Users/jared/projects/lunasquest/AGENTS.md)
- [`/Users/jared/projects/lunasquest/ideas.md`](/Users/jared/projects/lunasquest/ideas.md)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/scripts/combat_state.gd`](/Users/jared/projects/lunasquest/scripts/combat_state.gd)
- [`/Users/jared/projects/lunasquest/scripts/card_library.gd`](/Users/jared/projects/lunasquest/scripts/card_library.gd)
- [`/Users/jared/projects/lunasquest/scripts/card_ui.gd`](/Users/jared/projects/lunasquest/scripts/card_ui.gd)
- [`/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd`](/Users/jared/projects/lunasquest/scripts/unit_status_bars.gd)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
- [`/Users/jared/projects/lunasquest/data/starting_deck.json`](/Users/jared/projects/lunasquest/data/starting_deck.json)

## Key Findings

- The repo currently contains a single polished combat prototype rather than a broader roguelike run structure.
- The current battle is Luna versus The Dark Hallway.
- Card content is authored in JSON and loaded into runtime dictionaries.
- The prototype already supports buffs, temporary stats, X-cost cards, draw/discard flow, and enemy intents.
- The UI layer is significantly more developed than the overall content breadth.
- Loose future card ideas exist in `ideas.md`, and at least one of them, `Winter Coat`, has already been implemented.

## Wiki Pages Seeded From This Ingest

- [Project Overview](../overview/project-overview.md)
- [Combat Loop](../systems/combat-loop.md)
- [Card And Deck Model](../systems/card-and-deck-model.md)
- [Presentation Layer](../systems/presentation-layer.md)
- [Current Card Pool](../content/current-card-pool.md)
- [Luna](../entities/luna.md)
- [The Dark Hallway](../entities/the-dark-hallway.md)
- [Design Backlog](../backlog/design-backlog.md)

## Notable Gaps

- No progression structure or reward economy
- No broader encounter roster
- No explicit persistence or save/load layer
- No wiki ingest yet for scene hierarchy, textures, or exported build behavior
