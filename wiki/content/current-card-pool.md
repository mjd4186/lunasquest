# Current Card Pool

The prototype currently ships with a compact 10-card pool and an 18-card starting deck. The pool already sketches a defensively oriented "small dog finds courage" identity, with a mix of block, sustain, persistent comfort buffs, and one explosive X-cost payoff.

## Card Table

| Card | Type | Cost | Starter copies | Effect |
| --- | --- | --- | --- | --- |
| Yip! | Attack | 1 | 5 | Deal 6 damage. |
| Cower | Skill | 1 | 4 | Gain 5 block. |
| Peek Around Corner | Skill | 2 | 2 | Deal 7 damage and gain 7 block. |
| Find Courage | Skill | 0 | 1 | Gain 2 block. Draw 2 cards. |
| Treato | Skill | 0 | 1 | Exile. Heal 3. |
| Bite | Attack | X | 1 | Spend all remaining courage. Deal 5 damage per courage spent. |
| Favorite Sweater | Buff | 2 | 1 | Exile. At the start of your turn, gain 3 block and draw a card. |
| Winter Coat | Buff | 1 | 1 | Exile. At the start of your turn, gain 2 block. |
| Calming Drops | Buff | 1 | 1 | Exile. At the start of your turn, gain 1 courage. |
| Squeaky Hedgehog | Buff | 2 | 1 | Exile. Your attacks deal 1 extra damage. |

## Mechanical Shape

- Early baseline cards are simple and readable.
- Buff cards act like long-term comfort items that reshape the fight once played.
- `Bite` is the current payoff card and gives the deck a reason to bank courage-efficient turns.
- The pool leans much harder into defense and stability than into debuffs, combo lines, or encounter manipulation.

## Starter Deck Notes

- The opening deck is weighted toward repeated small attacks and blocks.
- Single-copy utility cards create mini-build paths within one fight:
  - sustain via `Treato`
  - scaling defense via `Favorite Sweater` and `Winter Coat`
  - scaling offense via `Squeaky Hedgehog`
  - resource smoothing via `Calming Drops`
- The deck currently includes every defined card, so there is no distinction yet between starter-only content and expandable card rewards.

## Gaps In The Pool

- No card currently applies debuffs to the enemy.
- No card currently interacts with discard, exhaust/exile synergies, card retention, or deck manipulation beyond raw draw.
- No upgrade system or rarity layer exists yet.
- No enemy-facing cards, relics, or reward-pool boundaries are modeled in data.

## Related Pages

- [Card And Deck Model](../systems/card-and-deck-model.md)
- [Luna](../entities/luna.md)
- [Design Backlog](../backlog/design-backlog.md)

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
- [`/Users/jared/projects/lunasquest/data/starting_deck.json`](/Users/jared/projects/lunasquest/data/starting_deck.json)
