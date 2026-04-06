# Card And Deck Model

Card content is authored in JSON, normalized into a consistent runtime shape, and then decorated with optional art and UI-only rich text before appearing in combat. The current model is small, but it already separates authored data, runtime combat state, and display formatting in a clean way.

## Source Of Truth

- `data/cards.json` defines the card library.
- `data/starting_deck.json` defines which cards seed the player draw pile.
- `scripts/card_library.gd` loads, normalizes, and decorates card definitions.
- `scripts/main.gd` interprets card properties into combat outcomes.

## Load Pipeline

1. `CardLibrary` reads the card JSON files.
2. Each card definition is normalized:
   - ids and names are cleaned up
   - card type is lowercased
   - top-level immediate stats like `damage`, `block`, `draw`, and `heal` are folded into `properties`
   - legacy property names are mapped forward
3. Card art is looked up from `res://assets/card_art/<slug>.(png|jpg)` if it exists.
4. The starting deck is assembled by card id or case-insensitive name lookup.
5. During battle, the runtime deck uses duplicated dictionaries rather than mutating the library templates directly.

## Current Runtime Property Vocabulary

- Immediate effects: `damage`, `block`, `draw`, `heal`
- Cost behavior: `x_cost`, `damage_per_x`
- Persistent buff effects: `block_every_turn`, `draw_every_turn`, `energy_every_turn`, `strength_every_turn`, `shred_block_every_turn`
- Temporary turn effects: `energy_this_turn`, `energy_next_turn`, `strength_this_turn`
- Zone behavior: `exile`

## Behavior Conventions

- `attack`, `skill`, and `buff` are the currently used card types.
- Buff cards become fight buffs instead of going to discard.
- Non-buff cards with `exile` also leave the cycle after play.
- X-cost cards spend all remaining courage and scale from the courage actually spent.
- Card rules text is recolored at render time so displayed damage/block/heal values reflect current modifiers.

## Data Model Observations

- The authored rules vocabulary still uses `energy_*` keys even though the game fiction and UI call the resource `courage`.
- Buff stacking is intentionally prevented by card id/name rather than by a broader tag system.
- The current model supports both authored card ids and human-readable names as starter-deck references.
- Missing art is non-fatal; cards still load and render with the shared card frame.

## Good Next Evolutions

- Move enemy kits and encounters into data alongside cards.
- Decide whether `energy_*` property names should be renamed to `courage_*` for consistency.
- Introduce data-driven debuffs or status application cards once the card pool expands.
- Add richer metadata for rarity, archetype, reward pools, upgrade paths, or unlock state.

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/scripts/card_library.gd`](/Users/jared/projects/lunasquest/scripts/card_library.gd)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
- [`/Users/jared/projects/lunasquest/data/starting_deck.json`](/Users/jared/projects/lunasquest/data/starting_deck.json)
