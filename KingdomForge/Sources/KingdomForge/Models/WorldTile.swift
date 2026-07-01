import Foundation

enum WorldTileKind: Equatable {
    case homeCity
    case empty
    case resourceNode(resource: ResourceType, richness: Int)
    case barbarianCamp(power: Double, tier: Int)
}

// Swift does not auto-synthesize Codable for enums with associated values,
// so this is implemented explicitly.
extension WorldTileKind: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind, resource, richness, power, tier
    }

    private enum Kind: String, Codable {
        case homeCity, empty, resourceNode, barbarianCamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .homeCity:
            self = .homeCity
        case .empty:
            self = .empty
        case .resourceNode:
            let resource = try container.decode(ResourceType.self, forKey: .resource)
            let richness = try container.decode(Int.self, forKey: .richness)
            self = .resourceNode(resource: resource, richness: richness)
        case .barbarianCamp:
            let power = try container.decode(Double.self, forKey: .power)
            let tier = try container.decode(Int.self, forKey: .tier)
            self = .barbarianCamp(power: power, tier: tier)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .homeCity:
            try container.encode(Kind.homeCity, forKey: .kind)
        case .empty:
            try container.encode(Kind.empty, forKey: .kind)
        case .resourceNode(let resource, let richness):
            try container.encode(Kind.resourceNode, forKey: .kind)
            try container.encode(resource, forKey: .resource)
            try container.encode(richness, forKey: .richness)
        case .barbarianCamp(let power, let tier):
            try container.encode(Kind.barbarianCamp, forKey: .kind)
            try container.encode(power, forKey: .power)
            try container.encode(tier, forKey: .tier)
        }
    }
}

struct WorldTile: Codable, Identifiable, Equatable {
    var position: GridPosition
    var kind: WorldTileKind

    var id: GridPosition { position }
}
