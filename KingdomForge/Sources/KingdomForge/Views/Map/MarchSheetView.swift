import SwiftUI

struct MarchSheetView: View {
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    let tile: WorldTile

    @State private var selectedCounts: [TroopType: Int] = [:]

    private var validKind: MarchKind? {
        switch tile.kind {
        case .resourceNode: return .gather
        case .barbarianCamp: return .attack
        default: return nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Target") {
                    Text(tileDescription)
                }

                if validKind != nil {
                    Section("Troops to send") {
                        ForEach(TroopType.allCases) { type in
                            Stepper(value: Binding(
                                get: { selectedCounts[type] ?? 0 },
                                set: { selectedCounts[type] = $0 }
                            ), in: 0...(engine.state.troops[type] ?? 0)) {
                                Text("\(type.displayName): \(selectedCounts[type] ?? 0) / \(engine.state.troops[type] ?? 0)")
                            }
                        }
                    }
                    Section {
                        Button("Send March") {
                            engine.sendMarch(to: tile.position, kind: validKind!, troops: selectedCounts)
                            dismiss()
                        }
                        .disabled(selectedCounts.values.reduce(0, +) == 0)
                    }
                } else {
                    Text("This tile has no available action.")
                }
            }
            .navigationTitle("March")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var tileDescription: String {
        switch tile.kind {
        case .homeCity: return "Home City"
        case .empty: return "Empty land"
        case .resourceNode(let resource, let richness): return "\(resource.displayName) node (richness \(richness))"
        case .barbarianCamp(let power, let tier): return "Barbarian Camp - Tier \(tier) (power \(Int(power)))"
        }
    }
}
