import Foundation

enum TechEffect: Equatable {
    case productionBoost(resource: ResourceType, percent: Double)
    case combatBoost(percent: Double)
    case storageBoost(percent: Double)
    case unlockTroop(TroopType)
}

// Swift does not auto-synthesize Codable for enums with associated values,
// so this is implemented explicitly.
extension TechEffect: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind, resource, percent, troop
    }

    private enum Kind: String, Codable {
        case productionBoost, combatBoost, storageBoost, unlockTroop
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .productionBoost:
            let resource = try container.decode(ResourceType.self, forKey: .resource)
            let percent = try container.decode(Double.self, forKey: .percent)
            self = .productionBoost(resource: resource, percent: percent)
        case .combatBoost:
            self = .combatBoost(percent: try container.decode(Double.self, forKey: .percent))
        case .storageBoost:
            self = .storageBoost(percent: try container.decode(Double.self, forKey: .percent))
        case .unlockTroop:
            self = .unlockTroop(try container.decode(TroopType.self, forKey: .troop))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .productionBoost(let resource, let percent):
            try container.encode(Kind.productionBoost, forKey: .kind)
            try container.encode(resource, forKey: .resource)
            try container.encode(percent, forKey: .percent)
        case .combatBoost(let percent):
            try container.encode(Kind.combatBoost, forKey: .kind)
            try container.encode(percent, forKey: .percent)
        case .storageBoost(let percent):
            try container.encode(Kind.storageBoost, forKey: .kind)
            try container.encode(percent, forKey: .percent)
        case .unlockTroop(let troop):
            try container.encode(Kind.unlockTroop, forKey: .kind)
            try container.encode(troop, forKey: .troop)
        }
    }
}

struct TechNode: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var tier: Int
    var cost: ResourceBundle
    var researchTime: TimeInterval
    var prerequisites: [String]
    var effect: TechEffect
}
