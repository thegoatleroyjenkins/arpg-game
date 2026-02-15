# TODO

## Core Systems Backlog

- [ ] Build a full quest system where NPCs can give players quests.
  - [ ] Quest offer / accept / decline flow from NPC dialogue interaction.
  - [ ] Quest journal UI (active, completed, failed).
  - [ ] Objective tracking + waypoint hooks.
  - [ ] Reward pipeline (XP, gold, items, reputation).
  - [ ] Data-driven quest definitions (JSON/SQL) with versioning.

- [ ] Build out a full inventory system.
  - [ ] Inventory data model (stacking rules, slot types, capacity).
  - [ ] Pickup-to-inventory flow with overflow handling.
  - [ ] Inventory UI grid + drag/drop + equip/unequip integration.
  - [ ] Item tooltip/stat comparison panel.
  - [ ] Save/load persistence and schema versioning for inventory data.

- [ ] Build **The Garden** as a major city hub players can travel to.
  - [ ] Create city scene + district layout (market, quest square, crafting quarter).
  - [ ] Set fast-travel/entry routing from early frontier zones.
  - [ ] Place NPC Gnome as a permanent resident and city guide/quest giver.

- [ ] Build out a full open-world map system.
  - [ ] World map UI with pan/zoom and biome overlays.
  - [ ] Discovery fog + reveal state per chunk/POI.
  - [ ] Player/NPC/quest markers with filtering.
  - [ ] Fast-travel node integration and unlock states.
