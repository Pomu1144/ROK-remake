import SwiftUI

struct ResourceBarView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        HStack(spacing: 16) {
            ForEach(ResourceType.allCases) { type in
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: type.symbolName)
                        Text("\(Int(engine.state.resources[type]))")
                            .font(.subheadline.bold())
                    }
                    Text("+\(String(format: "%.0f", engine.hourlyRate(for: type)))/hr")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thinMaterial)
    }
}
