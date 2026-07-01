import Foundation

enum MarchKind: String, Codable, Equatable {
    case gather
    case attack
}

enum MarchPhase: String, Codable, Equatable {
    case outbound
    case acting
    case returning
}

struct March: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var kind: MarchKind
    var origin: GridPosition
    var destination: GridPosition
    var troops: [TroopType: Int]
    var departedAt: Date
    var arrivesAt: Date
    var actionDuration: TimeInterval
    var returnsAt: Date
    var phase: MarchPhase = .outbound
    var resolved: Bool = false
    var resultSummary: String?
    var rewards: ResourceBundle = ResourceBundle()
}
