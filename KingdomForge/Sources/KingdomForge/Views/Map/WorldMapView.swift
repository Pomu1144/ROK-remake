import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject var engine: GameEngine
    @State private var selectedTile: WorldTile?

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 4), count: engine.state.worldGridSize)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(engine.state.worldTiles) { tile in
                        WorldTileCell(tile: tile)
                            .onTapGesture {
                                if tile.kind != .homeCity { selectedTile = tile }
                            }
                    }
                }
                .padding()

                if !engine.state.marches.isEmpty {
                    MarchListView()
                        .environmentObject(engine)
                        .padding(.horizontal)
                        .padding(.bottom)
                }

                if !engine.state.eventLog.isEmpty {
                    EventLogView()
                        .environmentObject(engine)
                        .padding()
                }
            }
            .navigationTitle("World Map")
            .sheet(item: $selectedTile) { tile in
                MarchSheetView(tile: tile).environmentObject(engine)
            }
        }
    }
}

private struct WorldTileCell: View {
    let tile: WorldTile

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: symbolName)
                .font(.caption)
            switch tile.kind {
            case .resourceNode(let resource, let richness):
                Text("\(resource.displayName.prefix(1))\(richness)")
                    .font(.system(size: 8))
            case .barbarianCamp(_, let tier):
                Text("T\(tier)")
                    .font(.system(size: 8))
            default:
                EmptyView()
            }
        }
        .frame(width: 32, height: 32)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var symbolName: String {
        switch tile.kind {
        case .homeCity: return "house.fill"
        case .empty: return "circle"
        case .resourceNode(let resource, _): return resource.symbolName
        case .barbarianCamp: return "flame.fill"
        }
    }

    private var backgroundColor: Color {
        switch tile.kind {
        case .homeCity: return .blue.opacity(0.4)
        case .empty: return .gray.opacity(0.1)
        case .resourceNode: return .green.opacity(0.25)
        case .barbarianCamp: return .red.opacity(0.25)
        }
    }
}

private struct MarchListView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active Marches").font(.headline)
            ForEach(engine.state.marches) { march in
                HStack {
                    Text(label(for: march)).font(.caption)
                    Spacer()
                    Text(timeDescription(max(0, timeRemaining(for: march))))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func label(for march: March) -> String {
        let kindText = march.kind == .gather ? "Gathering" : "Attacking"
        let statusText = march.phase == .returning ? "returning" : "en route"
        return "\(kindText) (\(march.destination.x), \(march.destination.y)) - \(statusText)"
    }

    private func timeRemaining(for march: March) -> TimeInterval {
        switch march.phase {
        case .outbound: return march.arrivesAt.timeIntervalSinceNow
        default: return march.returnsAt.timeIntervalSinceNow
        }
    }
}

private struct EventLogView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent Events").font(.headline)
            ForEach(Array(engine.state.eventLog.prefix(10).enumerated()), id: \.offset) { _, event in
                Text(event).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
