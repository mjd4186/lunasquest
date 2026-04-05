# The Dark Hallway

The Dark Hallway is the lone prototype enemy encounter and currently functions as both monster and mood piece. It pressures Luna with steady damage, block disruption, and fear-themed debuffs rather than with a bespoke body or creature taxonomy.

## Current Encounter Profile

- Encounter HP: `40`
- Display name: `The Dark Hallway`
- Flavor framing: an oppressive, animate environment rather than a normal enemy body

## Passive Buffs

- `Shadow Teeth`: its attacks deal `+2` damage
- `Cold Draft`: at the start of its turn, strip `3` block from Luna

## Intent Deck

- `attack`: attack for `8` plus buffs
- `block`: gain `8` block
- `attack_debuff`: attack for `5` plus buffs and apply `Weak 2`
- `block_debuff`: gain `5` block and apply `Frail 2`

## Design Role

- Demonstrates that threats can be environmental and psychological, not only creature-based.
- Forces the player to respect both offense and block timing.
- Serves as a compact test bed for the game's status, intent, and buff systems.

## Open Questions

- Is The Dark Hallway a one-off tutorial encounter or the template for a broader class of environmental enemies?
- Should enemy kits become fully data-driven as soon as multiple encounters exist?
- What makes future enemies feel distinct if the current prototype already leans on mood-heavy abstraction?

## Related Pages

- [Project Overview](../overview/project-overview.md)
- [Combat Loop](../systems/combat-loop.md)

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/scripts/combat_state.gd`](/Users/jared/projects/lunasquest/scripts/combat_state.gd)
