import SwiftUI

struct RootView: View {
    @StateObject private var engine = GameEngine()
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: Tab = .city

    enum Tab {
        case city, map, tech, army
    }

    var body: some View {
        VStack(spacing: 0) {
            ResourceBarView()
                .environmentObject(engine)

            TabView(selection: $selectedTab) {
                CityView()
                    .environmentObject(engine)
                    .tabItem { Label("City", systemImage: "building.2.fill") }
                    .tag(Tab.city)

                WorldMapView()
                    .environmentObject(engine)
                    .tabItem { Label("Map", systemImage: "map.fill") }
                    .tag(Tab.map)

                TechTreeView()
                    .environmentObject(engine)
                    .tabItem { Label("Research", systemImage: "flask.fill") }
                    .tag(Tab.tech)

                ArmyView()
                    .environmentObject(engine)
                    .tabItem { Label("Army", systemImage: "shield.fill") }
                    .tag(Tab.army)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                engine.persistNow()
            }
        }
    }
}
