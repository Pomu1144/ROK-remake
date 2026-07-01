import SwiftUI

struct BuildMenuView: View {
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    let position: GridPosition

    private var eligibleTypes: [BuildingType] {
        BuildingType.allCases.filter { $0 != .townHall && engine.currentTownHallLevel() >= $0.minTownHallLevel }
    }

    var body: some View {
        NavigationStack {
            List(eligibleTypes) { type in
                Button {
                    engine.placeBuilding(type: type, at: position)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: type.symbolName)
                        VStack(alignment: .leading) {
                            Text(type.displayName)
                            Text(costDescription(type.baseCost(level: 1)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(timeDescription(type.buildTime(level: 1)))
                            .font(.caption)
                    }
                }
                .disabled(!engine.state.resources.canAfford(type.baseCost(level: 1)))
            }
            .navigationTitle("Build")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
