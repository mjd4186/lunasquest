# Design Backlog

The current backlog is still mostly implicit: a few loose card ideas in `ideas.md`, plus a larger set of missing systems inferred from the prototype's present scope. The new title-screen shell adds another layer of unresolved product decisions, so this page now tracks both combat-adjacent ideas and the wrapper systems that could turn the prototype into a fuller run-based game.

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
- Front-end shell beyond a single title screen
- Meta-progression or save/load
- Broader enemy and player status vocabulary

## Promising Near-Term Threads

- Decide whether the title screen should stay a thin wrapper or become the start of a fuller run shell with continue/settings flow.
- Add a transition or return path between combat outcomes and the shell instead of relying only on the in-combat `Try Again` loop.
- Turn `Dog Breath` into the first enemy-facing status card.
- Decide whether `Deer Antler Chew Toy` should be a buff card, relic-like item, or permanent deck upgrade.
- Move enemy data and encounter definitions out of `main.gd` into data files.
- Expand the wiki with pages for progression, rewards, encounters, title-screen flow, and art-direction coverage as those systems appear.

## Steering Signals

- `Inference:` recent work is prioritizing first-impression polish, character-forward tone, and project organization alongside combat iteration.
- `Inference:` the next meaningful layer may be wrapper systems that make a run feel like a session, not just additional combat content inside `main.tscn`.

## Filing Guidance

- Keep this page focused on unresolved work.
- When an idea becomes implemented, move the durable facts to a system/content/entity page and leave only the design question here if it still matters.
- If a backlog item becomes a deeper exploration, split it into its own page and link it from here.

## Sources

- [Title Screen And Asset Pass (2026-04-07)](../sources/title-screen-and-asset-pass-2026-04-07.md)
- [Initial Repo Snapshot (2026-04-04)](../sources/initial-repo-snapshot-2026-04-04.md)
- [`/Users/jared/projects/lunasquest/ideas.md`](/Users/jared/projects/lunasquest/ideas.md)
- [`/Users/jared/projects/lunasquest/project.godot`](/Users/jared/projects/lunasquest/project.godot)
- [`/Users/jared/projects/lunasquest/scenes/title_screen.tscn`](/Users/jared/projects/lunasquest/scenes/title_screen.tscn)
- [`/Users/jared/projects/lunasquest/scripts/title_screen.gd`](/Users/jared/projects/lunasquest/scripts/title_screen.gd)
- [`/Users/jared/projects/lunasquest/data/cards.json`](/Users/jared/projects/lunasquest/data/cards.json)
