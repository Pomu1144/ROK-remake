import SwiftUI

struct CityTileView: View {
    @EnvironmentObject var engine: GameEngine
    let position: GridPosition

    private var building: PlacedBuilding? {
        engine.state.buildings.first(where: { $0.position == position })
    }

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: building?.type.symbolName ?? "plus")
                .font(.title3)
                .foregroundStyle(building == nil ? .secondary : .primary)
            if let building {
                Text("Lv \(building.level)")
                    .font(.caption2)
                if building.isUpgrading {
                    ProgressBar(progress: upgradeProgress(building))
                        .frame(height: 4)
                }
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(building == nil ? Color.gray.opacity(0.12) : Color.accentColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func upgradeProgress(_ building: PlacedBuilding) -> Double {
        guard let start = building.upgradeStartedAt, let end = building.upgradeCompletesAt else { return 0 }
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 1 }
        return Date().timeIntervalSince(start) / total
    }
}
