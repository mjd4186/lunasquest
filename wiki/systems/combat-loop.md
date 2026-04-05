# Combat Loop

The current prototype implements a complete single-battle loop with random enemy intents, turn-start buffs, hand cycling, and combat-end resolution. Nearly all battle orchestration lives in `scripts/main.gd`, while `scripts/combat_state.gd` holds the mutable fight state and low-level combat helpers.

## Battle Setup

- Player HP starts at `28`.
- Monster HP starts at `40`.
- Base courage per turn is `3`.
- Hand size target is `5`.
- Player and monster buffs are reset at battle start.
- The starting deck is built from `data/starting_deck.json`, shuffled, and used as the initial draw pile.
- The monster immediately rolls an intent before the first player turn.

## Player Turn

At the start of the player turn:

- `current_turn` becomes `player`
- courage is reset to `3 + bonus_courage_next_turn`
- next-turn bonus courage is cleared
- temporary player strength is cleared
- player block is reset to `0`
- start-of-turn player buffs are applied
- the hand is drawn up to `5 + extra_draws_from_buffs`

While the turn is active:

- A card can be played only if the player has enough courage.
- Card cost is dynamic for X-cost cards and equals all remaining courage.
- Courage is spent before the card resolves.
- Cards resolve immediate effects such as damage, block, draw, heal, temporary courage, next-turn courage, or temporary strength.
- Buff cards convert into persistent fight buffs rather than cycling back through the deck.

At end turn:

- Remaining cards in hand are discarded.
- Temporary strength is cleared.
- Player statuses tick down.
- Control passes to the monster turn.

## Monster Turn

At the start of the monster turn:

- monster block is reset to `0`
- monster start-of-turn buffs apply
- the current pending intent resolves

Current intent types:

- `attack`: direct damage
- `block`: gain block
- `attack_debuff`: damage plus `Weak`
- `block_debuff`: block plus `Frail`

After resolution:

- battle end is checked
- a new intent is rolled
- `turn_number` increments
- the next player turn begins

## Block, Buff, And Status Rules

- Player block survives across the monster turn but is wiped at the start of the next player turn.
- Monster block survives across the player turn but is wiped at the start of the next monster turn.
- Buff cards are keyed by buff id/name and do not stack if the same buff is already active.
- Player attack damage is affected by `Weak`.
- Monster damage taken is affected by `Vulnerable`.
- Player block gain is reduced by `Frail`.

## Current Implementation Notes

- Monster intents are rolled randomly from a fixed list; there is no intent sequencing or anti-repeat logic yet.
- The monster starts battle with two passive buffs:
  - `Shadow Teeth`: attacks deal `+2` damage
  - `Cold Draft`: remove `3` player block at the start of the monster turn
- As implemented, player statuses tick down each round, but monster statuses do not currently have a decay path.
- `monster_statuses` contains `Vulnerable`, but the current card pool does not yet apply it.

## Open Questions

- Should block reset rules stay symmetrical, or should some block persist longer as the design grows?
- Should enemy intents gain memory, sequencing rules, or difficulty curves?
- Should monster statuses tick down on the monster turn once more debuffs exist?
- When new encounters are added, should buffs and intents live in data instead of code?

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/scripts/main.gd`](/Users/jared/projects/lunasquest/scripts/main.gd)
- [`/Users/jared/projects/lunasquest/scripts/combat_state.gd`](/Users/jared/projects/lunasquest/scripts/combat_state.gd)
