import SwiftUI

private enum CitySheet: Identifiable {
    case build(GridPosition)
    case detail(UUID)

    var id: String {
        switch self {
        case .build(let pos): return "build-\(pos.x)-\(pos.y)"
        case .detail(let id): return "detail-\(id.uuidString)"
        }
    }
}

struct CityView: View {
    @EnvironmentObject var engine: GameEngine
    @State private var activeSheet: CitySheet?

    private var size: Int { engine.state.cityGridSize }
    private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 6), count: size) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<(size * size), id: \.self) { index in
                        let pos = GridPosition(x: index % size, y: index / size)
                        CityTileView(position: pos)
                            .onTapGesture { handleTap(pos) }
                    }
                }
                .padding()
            }
            .navigationTitle("Your City")
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .build(let pos):
                    BuildMenuView(position: pos).environmentObject(engine)
                case .detail(let id):
                    BuildingDetailView(buildingID: id).environmentObject(engine)
                }
            }
        }
    }

    private func handleTap(_ pos: GridPosition) {
        if let building = engine.state.buildings.first(where: { $0.position == pos }) {
            activeSheet = .detail(building.id)
        } else {
            activeSheet = .build(pos)
        }
    }
}
