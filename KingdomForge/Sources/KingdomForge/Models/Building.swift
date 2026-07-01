import Foundation

enum BuildingType: String, Codable, CaseIterable, Identifiable, Hashable {
    case townHall, farm, sawmill, quarry, goldMine, barracks, academy, wall

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .townHall: return "Town Hall"
        case .farm: return "Farm"
        case .sawmill: return "Sawmill"
        case .quarry: return "Quarry"
        case .goldMine: return "Gold Mine"
        case .barracks: return "Barracks"
        case .academy: return "Academy"
        case .wall: return "Wall"
        }
    }

    var symbolName: String {
        switch self {
        case .townHall: return "building.columns.fill"
        case .farm: return "leaf.fill"
        case .sawmill: return "tree.fill"
        case .quarry: return "cube.fill"
        case .goldMine: return "dollarsign.circle.fill"
        case .barracks: return "shield.lefthalf.filled"
        case .academy: return "flask.fill"
        case .wall: return "square.stack.3d.up.fill"
        }
    }

    var maxLevel: Int {
        switch self {
        case .wall: return 5
        default: return 10
        }
    }

    /// Minimum Town Hall level required to place this building type.
    var minTownHallLevel: Int {
        switch self {
        case .townHall: return 0
        case .farm, .sawmill, .quarry, .goldMine: return 1
        case .wall: return 2
        case .barracks: return 2
        case .academy: return 3
        }
    }

    var producesResource: ResourceType? {
        switch self {
        case .farm: return .food
        case .sawmill: return .wood
        case .quarry: return .stone
        case .goldMine: return .gold
        default: return nil
        }
    }

    private var baseHourlyRate: Double {
        switch self {
        case .farm: return 90
        case .sawmill: return 90
        case .quarry: return 75
        case .goldMine: return 40
        default: return 0
        }
    }

    func productionPerHour(level: Int) -> Double {
        baseHourlyRate * Double(level)
    }

    /// Resource cost to construct (level 1) or upgrade to the given target level.
    func baseCost(level: Int) -> ResourceBundle {
        let scale = pow(1.5, Double(max(level, 1) - 1))
        let cost: ResourceBundle
        switch self {
        case .townHall: cost = ResourceBundle(gold: 100, food: 200, wood: 200, stone: 200)
        case .farm: cost = ResourceBundle(gold: 0, food: 0, wood: 100, stone: 50)
        case .sawmill: cost = ResourceBundle(gold: 0, food: 100, wood: 0, stone: 50)
        case .quarry: cost = ResourceBundle(gold: 0, food: 100, wood: 100, stone: 0)
        case .goldMine: cost = ResourceBundle(gold: 0, food: 80, wood: 80, stone: 80)
        case .barracks: cost = ResourceBundle(gold: 0, food: 0, wood: 150, stone: 150)
        case .academy: cost = ResourceBundle(gold: 100, food: 0, wood: 200, stone: 200)
        case .wall: cost = ResourceBundle(gold: 0, food: 0, wood: 0, stone: 150)
        }
        return cost * scale
    }

    func buildTime(level: Int) -> TimeInterval {
        let base: TimeInterval
        switch self {
        case .townHall: base = 120
        case .barracks, .academy: base = 60
        case .wall: base = 45
        default: base = 30
        }
        return base * pow(1.4, Double(max(level, 1) - 1))
    }
}

struct PlacedBuilding: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var type: BuildingType
    var level: Int
    var position: GridPosition
    var upgradeStartedAt: Date?
    var upgradeCompletesAt: Date?

    var isUpgrading: Bool { upgradeCompletesAt != nil }
}
