import Foundation

struct GridPosition: Hashable, Codable {
    var x: Int
    var y: Int
}

enum ResourceType: String, Codable, CaseIterable, Identifiable, Hashable {
    case gold, food, wood, stone

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gold: return "Gold"
        case .food: return "Food"
        case .wood: return "Wood"
        case .stone: return "Stone"
        }
    }

    var symbolName: String {
        switch self {
        case .gold: return "dollarsign.circle.fill"
        case .food: return "leaf.fill"
        case .wood: return "tree.fill"
        case .stone: return "cube.fill"
        }
    }
}

struct ResourceBundle: Codable, Equatable {
    var gold: Double = 0
    var food: Double = 0
    var wood: Double = 0
    var stone: Double = 0

    subscript(type: ResourceType) -> Double {
        get {
            switch type {
            case .gold: return gold
            case .food: return food
            case .wood: return wood
            case .stone: return stone
            }
        }
        set {
            switch type {
            case .gold: gold = newValue
            case .food: food = newValue
            case .wood: wood = newValue
            case .stone: stone = newValue
            }
        }
    }

    static func + (lhs: ResourceBundle, rhs: ResourceBundle) -> ResourceBundle {
        ResourceBundle(gold: lhs.gold + rhs.gold, food: lhs.food + rhs.food, wood: lhs.wood + rhs.wood, stone: lhs.stone + rhs.stone)
    }

    static func - (lhs: ResourceBundle, rhs: ResourceBundle) -> ResourceBundle {
        ResourceBundle(gold: lhs.gold - rhs.gold, food: lhs.food - rhs.food, wood: lhs.wood - rhs.wood, stone: lhs.stone - rhs.stone)
    }

    static func * (lhs: ResourceBundle, rhs: Double) -> ResourceBundle {
        ResourceBundle(gold: lhs.gold * rhs, food: lhs.food * rhs, wood: lhs.wood * rhs, stone: lhs.stone * rhs)
    }

    func canAfford(_ cost: ResourceBundle) -> Bool {
        gold >= cost.gold && food >= cost.food && wood >= cost.wood && stone >= cost.stone
    }

    mutating func capAt(_ cap: Double) {
        gold = min(gold, cap)
        food = min(food, cap)
        wood = min(wood, cap)
        stone = min(stone, cap)
    }
}
