import Foundation

enum TroopType: String, Codable, CaseIterable, Identifiable, Hashable {
    case infantry, archer, cavalry

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .infantry: return "Infantry"
        case .archer: return "Archer"
        case .cavalry: return "Cavalry"
        }
    }

    var symbolName: String {
        switch self {
        case .infantry: return "shield.fill"
        case .archer: return "arrow.up.forward.circle.fill"
        case .cavalry: return "hare.fill"
        }
    }

    var basePower: Double {
        switch self {
        case .infantry: return 10
        case .archer: return 14
        case .cavalry: return 20
        }
    }

    var trainCost: ResourceBundle {
        switch self {
        case .infantry: return ResourceBundle(gold: 0, food: 20, wood: 10, stone: 0)
        case .archer: return ResourceBundle(gold: 0, food: 15, wood: 25, stone: 0)
        case .cavalry: return ResourceBundle(gold: 10, food: 30, wood: 20, stone: 0)
        }
    }

    var trainTime: TimeInterval {
        switch self {
        case .infantry: return 8
        case .archer: return 10
        case .cavalry: return 15
        }
    }

    var requiredBarracksLevel: Int {
        switch self {
        case .infantry: return 1
        case .archer: return 2
        case .cavalry: return 4
        }
    }
}

struct TrainingOrder: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var troopType: TroopType
    var quantity: Int
    var startedAt: Date
    var completesAt: Date
}
