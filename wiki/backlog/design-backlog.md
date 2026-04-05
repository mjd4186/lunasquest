# Design Backlog

The current backlog is still mostly implicit: a few loose card ideas in `ideas.md`, plus a larger set of missing systems inferred from the prototype's present scope. This page is the place to promote those fragments into structured design threads over time.

## Imported From `ideas.md`

- `Winter Coat`: implemented
  - Current game version is a 1-cost buff that exiles and grants 2 block each turn.
- `Dog Breath`: not implemented
  - Intended effect: apply 3 poison or damage-over-time stacks.
- `Deer Antler Chew Toy`: not implemented
  - Intended effect: +1 damage or strength.

## Major Missing Systems

- Run structure and map progression
- Reward flow after combat
- Encounter roster beyond The Dark Hallway
- Card acquisition, removal, upgrades, and rarity
- Meta-progression or save/load
- Broader enemy and player status vocabulary

## Promising Near-Term Threads

- Turn `Dog Breath` into the first enemy-facing status card.
- Decide whether `Deer Antler Chew Toy` should be a buff card, relic-like item, or permanent deck upgrade.
- Move enemy data and encounter definitions out of `main.gd` into data files.
- Expand the wiki with pages for progression, rewards, encounters, and card-art coverage as those systems appear.

## Filing Guidance

- Keep this page focused on unresolved work.
- When an idea becomes implemented, move the durable facts to a system/content/entity page and leave only the design question here if it still matters.
- If a backlog item becomes a deeper exploration, split it into its own page and link it from here.

## Sources

- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/ideas.md`](/Users/jared/projects/lunasquest/ideas.md)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
