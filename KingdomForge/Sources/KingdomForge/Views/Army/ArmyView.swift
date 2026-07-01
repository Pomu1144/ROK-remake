import SwiftUI

struct ArmyView: View {
    @EnvironmentObject var engine: GameEngine
    @State private var trainingType: TroopType = .infantry
    @State private var trainingQuantity: Int = 1

    var body: some View {
        NavigationStack {
            List {
                Section("Hero") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(engine.state.hero.name).font(.title3.bold())
                        Text("Level \(engine.state.hero.level)")
                        ProgressBar(progress: engine.state.hero.xp / engine.state.hero.xpToNextLevel)
                            .frame(height: 6)
                        Text("Combat bonus: +\(String(format: "%.0f", engine.state.hero.combatBonusPercent))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Troops") {
                    ForEach(TroopType.allCases) { type in
                        HStack {
                            Image(systemName: type.symbolName)
                            Text(type.displayName)
                            Spacer()
                            Text("\(engine.state.troops[type] ?? 0)").bold()
                        }
                    }
                }

                Section("Train Troops") {
                    Picker("Type", selection: $trainingType) {
                        ForEach(TroopType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    Stepper("Quantity: \(trainingQuantity)", value: $trainingQuantity, in: 1...100)
                    let cost = trainingType.trainCost * Double(trainingQuantity)
                    Text(costDescription(cost)).font(.caption).foregroundStyle(.secondary)
                    Button("Queue Training") {
                        engine.queueTraining(trainingType, quantity: trainingQuantity)
                    }
                    .disabled(!engine.canTrain(trainingType) || !engine.state.resources.canAfford(cost))
                    if !engine.canTrain(trainingType) {
                        Text(unavailableReason(trainingType))
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }

                if !engine.state.trainingQueue.isEmpty {
                    Section("Training Queue") {
                        ForEach(engine.state.trainingQueue) { order in
                            HStack {
                                Text("\(order.quantity)x \(order.troopType.displayName)")
                                Spacer()
                                Text(timeDescription(max(0, order.completesAt.timeIntervalSinceNow)))
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Army")
        }
    }

    private func unavailableReason(_ type: TroopType) -> String {
        switch type {
        case .infantry:
            return "Requires Barracks level \(type.requiredBarracksLevel)"
        case .archer:
            return "Requires Barracks level \(type.requiredBarracksLevel) and Archery research"
        case .cavalry:
            return "Requires Barracks level \(type.requiredBarracksLevel) and Horsemanship research"
        }
    }
}
