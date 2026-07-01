import SwiftUI

struct BuildingDetailView: View {
    @EnvironmentObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    let buildingID: UUID

    private var building: PlacedBuilding? {
        engine.state.buildings.first(where: { $0.id == buildingID })
    }

    var body: some View {
        NavigationStack {
            if let building {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: building.type.symbolName).font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(building.type.displayName).font(.title2.bold())
                            Text("Level \(building.level) / \(building.type.maxLevel)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if building.isUpgrading, let completesAt = building.upgradeCompletesAt {
                        Text("Upgrading... completes in \(timeDescription(max(0, completesAt.timeIntervalSinceNow)))")
                            .font(.footnote)
                    } else if building.level < building.type.maxLevel {
                        let cost = building.type.baseCost(level: building.level + 1)
                        let time = building.type.buildTime(level: building.level + 1)
                        Button {
                            engine.upgradeBuilding(id: building.id)
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Upgrade to Level \(building.level + 1)")
                                Text("\(costDescription(cost)) | \(timeDescription(time))")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!engine.state.resources.canAfford(cost))
                    } else {
                        Text("Max level reached").foregroundStyle(.secondary)
                    }

                    if let resource = building.type.producesResource {
                        Text("Produces \(String(format: "%.0f", building.type.productionPerHour(level: building.level))) \(resource.displayName)/hr")
                            .font(.footnote)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle(building.type.displayName)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
            } else {
                Text("Building not found")
                    .onAppear { dismiss() }
            }
        }
    }
}
