# Wiki AGENTS

This directory is the persistent knowledge layer for `Luna's Quest`. The raw source of truth stays in the game repo itself: `scripts/`, `scenes/`, `data/`, `assets/`, and project notes such as `ideas.md`. The wiki exists to synthesize those sources into a durable, interlinked markdown knowledge base that can compound over time.

## Goals

- Keep a current, navigable picture of the project without re-deriving it from code every session.
- Prefer updating existing pages over creating near-duplicates.
- Separate direct facts from interpretation. If something is not explicitly backed by a source, label it `Inference:`.
- Preserve a clear trail from synthesis back to raw sources.

## Structure

- `overview/`: high-level state, project framing, major summaries
- `systems/`: combat flow, data model, UI/presentation, progression, save/load
- `content/`: card pools, encounters, items, relics, runs, rewards
- `entities/`: characters, enemies, bosses, locations, factions
- `sources/`: one page per ingest or source batch
- `backlog/`: open questions, future directions, unresolved design threads
- `index.md`: content-oriented catalog of the wiki
- `log.md`: append-only operational timeline

## Page Conventions

- Start each durable page with a short summary paragraph.
- Use relative markdown links between wiki pages.
- End pages with a `## Sources` section that links to the raw repo files or relevant `sources/` pages.
- Keep headings descriptive and stable so future edits can update pages in place.
- Prefer concise bullets and tables over long prose when summarizing game content.

## Operation Rules

- Never modify raw source files when doing a wiki-only ingest.
- Update `index.md` whenever pages are created, renamed, or materially repurposed.
- Append to `log.md` for every ingest, query filing, or lint pass.
- If a new source contradicts an existing page, update the page and note the change instead of silently overwriting the old understanding.
- If a question produces reusable insight, file it back into the wiki rather than leaving it stranded in chat history.

## Ingest Workflow

1. Read the changed raw sources.
2. Create or update a page in `sources/` summarizing what was learned.
3. Update the affected overview, system, content, entity, and backlog pages.
4. Update `index.md`.
5. Append a parseable entry to `log.md`.

## Query Workflow

1. Read `index.md` first.
2. Open only the most relevant pages.
3. Answer with citations to wiki pages and raw sources.
4. If the answer adds lasting knowledge, file it into the wiki and log the operation.

## Lint Workflow

Look for:

- broken or missing cross-links
- orphan pages
- stale claims after code or data changes
- inconsistent naming
- important entities or systems mentioned without their own page
- backlog notes that should graduate into structured content pages

## Repo-Specific Notes

- Treat the current codebase itself as the raw source corpus.
- Favor pages that mirror how the prototype is actually organized today: combat loop, card/deck model, presentation layer, encounter/content state, and design backlog.
- When documenting shipped assets or game behavior, reference `res://`-tracked sources rather than local filesystem paths outside the repo.
