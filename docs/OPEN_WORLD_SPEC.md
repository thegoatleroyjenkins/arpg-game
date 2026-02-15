# Open World Spec — Emberfall Marches

## Core Philosophy
- The world simulates independently of the player.
- Main quest is optional; world remains playable and reactive without it.
- Discovery-first structure: landmarks, rumor trails, and encounter pull.
- Curiosity rewards (hidden POIs, optional dungeons, systemic outcomes).

## World Layout Concept
A seamless outer frontier ring around the Ember Scar (high-risk center).

### Biomes
1. **Ashwood Frontier (Forest)**
   - Starter-friendly routes, burned farms, bandit roads.
2. **Frostbreak Tundra**
   - Sparse villages, weather hazards, predator chains.
3. **Mire of Glass (Swamp)**
   - Poison ecology, occult remnants, low-visibility combat.
4. **Crownspine Mountains**
   - Vertical traversal, fortress ruins, elite patrols.
5. **Sunken Imperium (Ruins)**
   - Late-game dungeon clusters, unstable corruption events.

## Exploration Model
- Minimal initial markers; discovery reveals map nodes.
- Fast travel unlocked per discovered settlement/shrine.
- POIs clustered by biome identity, not quest corridors.
- Optional dungeons carry self-contained narratives.

## Faction Layer
- **March Wardens**: lawful road control, anti-bandit priorities.
- **Ember Synod**: magical research and risk management.
- **Black Briar Band**: smuggling/ambush economy.
- **Verdigris Covenant**: corruption expansion and ritual events.
- **Free Clans**: reputation-sensitive local settlements.

Faction relationships influence:
- Patrol conflict odds
- Guard response times
- Available radiant contracts
- Settlement prices/services

## Systemic Simulation Pillars
- NPC daily routines (work/sleep/social/flee states).
- Wildlife predator-prey interactions.
- Faction conflict simulation per chunk.
- Crime/witness/response loop.
- Radiant template system for reusable side content.

## Encounter Design Rules
- Handcrafted static dungeons + randomized wilderness events.
- Regional difficulty bands (soft scaling only).
- Rare world-unique encounters with long respawn timers.

## Technical Architecture (Godot + SQLite)
- SQLite stores POIs, NPC schedules, faction relations, radiant templates, world events.
- Chunk-based world streaming with load radius + unload hysteresis.
- `WorldStreamer` orchestrates chunk lifecycle.
- `WorldSector` contains sector-local entities + state adapters.
- `SpawnDirector` resolves biome/faction/event context into active spawns.

## Deliverables Included
- SQL schema + seed set for open-world systems
- JSON world layout concept
- Godot world-system scaffolding scripts
- MVP roadmap for “small but systemic” first milestone

## MVP Scope (Indie-Smart)
Start with 9 chunks (3x3 active frontier), 2 factions, 2 biome spawn tables, and 1 radiant quest family. Expand by adding data, not rewriting architecture.
