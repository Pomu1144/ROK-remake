# Kingdom Forge

An original iOS mobile 4X kingdom-building strategy game: build a city, manage
four resources, research a tech tree, train an army with a leveling hero, and
send marches across a world map to gather resources or fight barbarian camps.

This is an original game — original name, mechanics, and (placeholder) art —
not a copy of, or affiliated with, any existing commercial game or its assets.

## Stack

- SwiftUI for all UI
- A plain-Swift `GameEngine`/`GameState` layer (no UIKit/SwiftUI dependency)
  driving a real-time tick loop: production, construction, research, troop
  training, and march resolution, including offline catch-up on relaunch
  (capped at 8 hours).
- Local JSON save file in the app's Documents directory (`SaveManager`).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) generates the `.xcodeproj`
  from `project.yml` so the project file itself isn't a hand-edited/committed
  binary blob.

## Build & run

Requires a Mac with Xcode 15+ (iOS 17 deployment target).

```sh
brew install xcodegen
cd KingdomForge
xcodegen generate
open KingdomForge.xcodeproj
```

Then pick an iPhone simulator (or a connected device with your team selected
under Signing & Capabilities) and hit Run.

> **Note:** This project was generated in a Linux container with no Xcode/Swift
> toolchain available, so it has **not** been compiled or run. The code was
> written carefully but hasn't been verified by a compiler. If you hit build
> errors, paste them back and they can be fixed quickly — Swift/SwiftUI errors
> are usually small (a missing conformance, an availability check, etc.).

## Game systems implemented

- **City**: 5x5 build grid, Town Hall (pre-placed) + Farm/Sawmill/Quarry/Gold
  Mine (produce Food/Wood/Stone/Gold), Barracks (train troops), Academy
  (research), Wall. Buildings gate on Town Hall level, cost/build-time scale
  per level, storage cap scales with Town Hall level.
- **Tech tree**: 8 nodes across 3 tiers with prerequisites — production
  boosts per resource, troop unlocks (Archery -> Archer, Horsemanship ->
  Cavalry), and combat/storage boosts. Requires an Academy to research.
- **Army**: three troop types (Infantry/Archer/Cavalry) with distinct power,
  cost, and train time; a Hero that gains XP from combat and boosts combat
  power per level.
- **World map**: 9x9 grid around your home city with resource nodes
  (gather) and barbarian camps (attack). Marches have real travel time based
  on distance, resolve on arrival, and return home with survivors/loot.
- **Combat**: deterministic power-vs-power resolution with hero/tech
  multipliers and casualty scaling by how lopsided the fight was.
- **Persistence**: autosaves periodically and on backgrounding; offline
  production/timers catch up when you reopen the app.

## Known gaps for a production game

This is a single-player vertical-slice demo, not a live-service game. It has
no backend, no multiplayer/alliances, no real-money economy, no matchmaking,
and no anti-cheat — building those out is a separate, much larger effort.
