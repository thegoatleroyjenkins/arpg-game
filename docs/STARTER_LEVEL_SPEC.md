# Starter Level Spec — Ashfall Outskirts (Stage 0)

## Intent
Deliver an 8–12 minute onboarding level that feels intentional, readable, and replayable:
- Teaches movement, basic attack, one starter ability, potion use, and loot pickup.
- Establishes dark-fantasy tone (ruined village + corrupted forest edge).
- Ends with a mini-boss and a meaningful first reward.

## Tone + Art Direction
- **Location:** Ruined frontier village, edge of corrupted tree line.
- **Lighting:** Cool blue/purple ambient fill, warm fire pockets for contrast.
- **Fog:** Low, desaturated violet ground fog with stronger density near boss arena.
- **Story props:** Burned carts, collapsed roofs, hanging lanterns, corpse notes, blight growths.

References to target:
- Diablo IV Fractured Peaks early readability
- Last Epoch campaign intro encounter clarity
- Torchlight readability/color separation for interactables

## Level Flow (8–12 min)
1. **Entry Lane (1–2 min)**
   - Prompt: move + camera + basic attack.
   - 2–3 Corrupted Villagers (slow melee) in open lane.
   - First drop: gold + guaranteed common item.

2. **Village Split (3–4 min)**
   - Semi-linear lane with optional side pocket.
   - Mixed encounter: melee + ranged (Blight Archer support).
   - Prompt: potion use appears after first meaningful HP loss.
   - Optional hidden chest behind breakable obstruction.

3. **Corrupted Square (2–3 min)**
   - Elite Brute introduction with stagger window.
   - Teaches telegraph reaction and spacing.

4. **Warden Arena (2–3 min)**
   - Mini-boss: **The Rotbound Warden**.
   - Abilities:
     - Ground Slam AoE (clear wind-up + impact ring)
     - Poison Puddle zones (area denial)
     - Enrage at 30% HP (faster cadence, clearer VFX)
   - Completion reward: rare item + 1 passive point (or specialization unlock flag).

## Encounter Design Targets
- 3 primary combat zones + 1 optional side pocket.
- Procedural spawn variation uses weighted spawn groups per zone.
- Keep intro pull sizes modest; increase pressure by composition, not raw HP inflation.

## Enemy Roster (Starter)
- **Corrupted Villager** (Tier 1): slow melee, low HP.
- **Blight Archer** (Tier 2): ranged poison shot, kites lightly.
- **Corrupted Brute (Elite)**: heavy melee, stagger interaction.
- **The Rotbound Warden (Mini-boss)**: arena controller + phase pressure.

## Progression + Rewards
- Start loadout: basic attack + 1 starter ability + 2 potions.
- Mid-level guaranteed **Magic** item chest.
- Boss guaranteed **Rare** item + progression unlock.
- XP pacing: level-up should occur immediately after boss kill.

## Tutorial Prompt Rules
- Prompts are contextual and self-dismissing after success.
- Never stack more than one prompt at once.
- Disable completed prompts for repeat attempts in same run.

## Systems/Data Boundaries
- Enemy, encounter, loot, and progression config are DB-driven.
- Layout authored in JSON with zone metadata.
- Runtime scene uses marker nodes and IDs that map to JSON zone IDs.

## Godot Scene Hierarchy (proposed)
- `res://world/levels/starter_village_3d.tscn`
  - `EnvironmentRoot`
  - `PathRoot`
  - `SpawnMarkers`
    - `Zone1_*`
    - `Zone2_*`
    - `Zone3_*`
    - `Boss_*`
  - `Interactables`
    - `HiddenChestMarker`
    - `BreakableWallMarker`
  - `TutorialAnchors`
  - `EncounterController`

## Enemy Stat Table (Starter Baseline)
| Enemy | HP | Damage | Move Speed | XP | Notes |
|---|---:|---:|---:|---:|---|
| Corrupted Villager | 45 | 6 | 2.8 | 12 | Intro melee fodder |
| Blight Archer | 36 | 5 (+poison 2/s x3s) | 3.2 | 16 | Ranged pressure |
| Corrupted Brute (Elite) | 140 | 14 | 2.4 | 48 | Stagger threshold: 40 posture |
| Rotbound Warden | 420 | 18 (slam 24) | 2.6 | 180 | Enrage at 30% HP |

## Loot Table Sample
| Source | Common | Magic | Rare | Gold |
|---|---:|---:|---:|---:|
| Villager | 72% | 25% | 3% | 4–9 |
| Archer | 65% | 30% | 5% | 5–11 |
| Elite Brute | 30% | 55% | 15% | 14–24 |
| Mid Chest | 0% | 100% | 0% | 12–18 |
| Rotbound Warden | 0% | 20% | 80% | 30–55 |

## XP Curve Sample (early)
| Level | XP to Next |
|---:|---:|
| 1 | 120 |
| 2 | 180 |
| 3 | 260 |
| 4 | 360 |

Target: a clean run lands Level 2 immediately after Warden kill.

## Implementation Checklist (Vertical Slice)
- [ ] Wire combat via shared damage resolver (`request_damage` path only)
- [ ] Add one melee + one ranged enemy using same damage path
- [ ] Implement boss telegraphs and phase change at 30%
- [ ] Implement guaranteed mid-chest magic drop
- [ ] Implement boss rare drop + passive point unlock
- [ ] Add encounter completion gate + retry reset
