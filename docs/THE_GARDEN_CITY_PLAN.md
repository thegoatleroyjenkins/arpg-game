# The Garden City Plan

A major hub/metro center that anchors the open-world frontier loop mentioned in the Discord todo list. The goal is to give players an expressive, livable city scene they can travel to from early frontier zones while also satisfying the specific todo items: city scene, district breakdown, fast travel, and a permanent NPC guide/quest giver.

## Requirements
- Create "The Garden" as an explorable city with distinct sub-districts (market, quest square, crafting quarter, etc.).
- Wire a fast-travel/entry route so frontier players can reach the city quickly once unlocked.
- Place the NPC Gnome as a permanent resident who can guide players, hand out quests, and tie into city lore.

## Existing references
- `data/sql/open_world_seed.sql` already defines `poi_the_garden` tied to `chunk_ashwood_00` with tags `major_city`, `hub`, `capital` and an NPC `npc_gnome` flagged as `garden_keeper` (quest giver / city guide).
- `systems/world/world_streamer.gd` / `world/streamer` handle chunk loading; any new city scene needs to register a chunk ID and ensure that `world_map_layout.json` includes the appropriate grid slot.
- Starter data already has a `world/levels/starter_village_3d.tscn`; the new city should live under `world/levels/` (e.g., `world/levels/the_garden_city.tscn`) and reuse streaming/prop placement utilities as needed.

## Proposed layout
1. **Market District** – wide boulevard with stalls, prop crowding, and a central plaza featuring vendor kiosks and hub NPCs. This area should include interactive stalls for crafting info and a subtle tutorial for shopping quests.
2. **Quest Square** – a civic plaza with the City Hall, a quest board, and a dedicated pedestal for the NPC Gnome to stand/patrol. The square can include decorative lighting and signage pointing toward the crafting quarter to orient players.
3. **Crafting Quarter** – tucked near the back of the city with forges, workbenches, and crafting props that can later host player-operated crafting flows. Provide a pathway link between this quarter and the market so the districts feel cohesive.
4. **Peripheral neighborhoods** – quick-access residential buildings + fast travel port (archway, gate, or carriage circle) to give the city a lived-in feel and a logical arrival/exit point for fast travel.

## Integration steps
1. **Scene build**: Create `world/levels/the_garden_city.tscn` with modular district blocks that can be toggled via streaming. Start with block placeholders and clearly mark where Market/Quest/Crafting districts sit relative to each other.
2. **Layout documentation**: Keep track of district coordinates, major landmarks, and potential occluders so the streaming system and nav meshes can be tuned afterward.
3. **Entrances & fast travel**: Define a fast-travel trigger (door arch, portal, or carriage circle) that can be referenced from the frontier/outbound chunks. Add an entry point to `data/world/world_map_layout.json` `poi` list with guard data (e.g., `chunk_the_garden_entry` which streams this scene). Update `systems/world/world_streamer.gd` if new chunk IDs or metadata are needed.
4. **NPC placement**: Use `npc_gnome` prefab (or create a placeholder) and pin it to the Quest Square. Build a simple `CityGuide` script to anchor dialogue/quest logic and tag it as `garden_keeper` to match the SQL seed entry.

## Next actions
- Sketch block layout inside the new scene so the Market/Quest/Crafting flows form a natural loop.
- Wire a test fast-travel trigger so the scene can be teleported into from `chunk_ashwood_00` during early frontier runs.
- Prototype the NPC Gnome behavior, ensuring the quest board and city guide signals are ready for future quest system integration.
