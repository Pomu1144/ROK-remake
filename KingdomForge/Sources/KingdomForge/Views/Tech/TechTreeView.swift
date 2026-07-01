import SwiftUI

struct TechTreeView: View {
    @EnvironmentObject var engine: GameEngine

    var body: some View {
        NavigationStack {
            List {
                if let researching = engine.state.researching,
                   let node = BalanceData.techTree.first(where: { $0.id == researching.techID }) {
                    Section("In Progress") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(node.name).font(.headline)
                            ProgressBar(progress: researchProgress(researching))
                                .frame(height: 6)
                            Text(timeDescription(max(0, researching.completesAt.timeIntervalSinceNow)) + " remaining")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ForEach(1...3, id: \.self) { tier in
                    Section("Tier \(tier)") {
                        ForEach(BalanceData.techTree.filter { $0.tier == tier }) { node in
                            techRow(node)
                        }
                    }
                }
            }
            .navigationTitle("Research")
            .overlay {
                if !engine.hasAcademy() {
                    ContentUnavailableView(
                        "Build an Academy",
                        systemImage: "flask",
                        description: Text("Construct an Academy in your city to unlock research.")
                    )
                }
            }
        }
    }

    private func techRow(_ node: TechNode) -> some View {
        let researched = engine.state.researchedTech.contains(node.id)
        let unmetPrereqs = node.prerequisites.filter { !engine.state.researchedTech.contains($0) }

        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(node.name).font(.subheadline.bold())
                Spacer()
                if researched {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                }
            }
            Text(effectDescription(node.effect))
                .font(.caption)
                .foregroundStyle(.secondary)

            if !researched {
                Text("\(costDescription(node.cost)) | \(timeDescription(node.researchTime))")
                    .font(.caption2)
                if !unmetPrereqs.isEmpty {
                    Text("Requires: \(unmetPrereqs.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
                Button("Research") {
                    engine.startResearch(node.id)
                }
                .buttonStyle(.bordered)
                .disabled(!engine.canResearch(node))
            }
        }
        .padding(.vertical, 4)
    }

    private func effectDescription(_ effect: TechEffect) -> String {
        switch effect {
        case .productionBoost(let resource, let percent):
            return "+\(Int(percent))% \(resource.displayName) production"
        case .combatBoost(let percent):
            return "+\(Int(percent))% combat power"
        case .storageBoost(let percent):
            return "+\(Int(percent))% storage capacity"
        case .unlockTroop(let type):
            return "Unlocks \(type.displayName) training"
        }
    }

    private func researchProgress(_ research: ResearchInProgress) -> Double {
        let total = research.completesAt.timeIntervalSince(research.startedAt)
        guard total > 0 else { return 1 }
        return min(1, max(0, Date().timeIntervalSince(research.startedAt) / total))
    }
}
