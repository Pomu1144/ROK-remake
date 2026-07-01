import Foundation

enum BalanceData {
    static let cityGridSize = 5
    static let worldGridSize = 9

    static func startingBuildings() -> [PlacedBuilding] {
        let center = GridPosition(x: cityGridSize / 2, y: cityGridSize / 2)
        return [PlacedBuilding(type: .townHall, level: 1, position: center)]
    }

    static let techTree: [TechNode] = [
        TechNode(
            id: "agriculture", name: "Agriculture", tier: 1,
            cost: ResourceBundle(gold: 0, food: 150, wood: 50, stone: 0),
            researchTime: 60, prerequisites: [],
            effect: .productionBoost(resource: .food, percent: 20)
        ),
        TechNode(
            id: "forestry", name: "Forestry", tier: 1,
            cost: ResourceBundle(gold: 0, food: 50, wood: 150, stone: 0),
            researchTime: 60, prerequisites: [],
            effect: .productionBoost(resource: .wood, percent: 20)
        ),
        TechNode(
            id: "stonework", name: "Stonework", tier: 1,
            cost: ResourceBundle(gold: 0, food: 0, wood: 50, stone: 150),
            researchTime: 60, prerequisites: [],
            effect: .productionBoost(resource: .stone, percent: 20)
        ),
        TechNode(
            id: "coinage", name: "Coinage", tier: 1,
            cost: ResourceBundle(gold: 100, food: 100, wood: 0, stone: 0),
            researchTime: 75, prerequisites: [],
            effect: .productionBoost(resource: .gold, percent: 20)
        ),
        TechNode(
            id: "archery", name: "Archery", tier: 2,
            cost: ResourceBundle(gold: 0, food: 150, wood: 250, stone: 0),
            researchTime: 150, prerequisites: ["forestry"],
            effect: .unlockTroop(.archer)
        ),
        TechNode(
            id: "horsemanship", name: "Horsemanship", tier: 2,
            cost: ResourceBundle(gold: 150, food: 300, wood: 0, stone: 0),
            researchTime: 200, prerequisites: ["agriculture", "coinage"],
            effect: .unlockTroop(.cavalry)
        ),
        TechNode(
            id: "siegecraft", name: "Siegecraft", tier: 3,
            cost: ResourceBundle(gold: 200, food: 0, wood: 0, stone: 300),
            researchTime: 240, prerequisites: ["stonework"],
            effect: .combatBoost(percent: 15)
        ),
        TechNode(
            id: "masonry_vaults", name: "Masonry Vaults", tier: 3,
            cost: ResourceBundle(gold: 0, food: 0, wood: 200, stone: 400),
            researchTime: 240, prerequisites: ["stonework"],
            effect: .storageBoost(percent: 25)
        ),
    ]

    static func generateWorldTiles() -> [WorldTile] {
        var tiles: [WorldTile] = []
        let size = worldGridSize
        let center = GridPosition(x: size / 2, y: size / 2)
        var rng = SeededGenerator(seed: 42)

        for x in 0..<size {
            for y in 0..<size {
                let pos = GridPosition(x: x, y: y)
                if pos == center {
                    tiles.append(WorldTile(position: pos, kind: .homeCity))
                    continue
                }
                let roll = Int.random(in: 0..<100, using: &rng)
                let kind: WorldTileKind
                switch roll {
                case 0..<35:
                    kind = .empty
                case 35..<70:
                    let resource = ResourceType.allCases.randomElement(using: &rng)!
                    let richness = Int.random(in: 1...3, using: &rng)
                    kind = .resourceNode(resource: resource, richness: richness)
                default:
                    let tier = Int.random(in: 1...3, using: &rng)
                    kind = .barbarianCamp(power: Double(tier) * 80, tier: tier)
                }
                tiles.append(WorldTile(position: pos, kind: kind))
            }
        }
        return tiles
    }
}
