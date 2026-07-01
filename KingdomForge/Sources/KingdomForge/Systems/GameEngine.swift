import Foundation
import Combine

/// Central game loop and mutation point for all player actions.
/// SwiftUI views read `state` and call the action methods below;
/// they never mutate `GameState` directly.
final class GameEngine: ObservableObject {
    @Published private(set) var state: GameState

    private let saveManager = SaveManager()
    private var timerCancellable: AnyCancellable?
    private var ticksSinceSave = 0

    init() {
        if let loaded = saveManager.load() {
            self.state = loaded
        } else {
            self.state = GameState()
        }
        catchUp(to: Date())
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.catchUp(to: date)
            }
    }

    func persistNow() {
        saveManager.save(state)
    }

    // MARK: - Tick / catch-up

    private func catchUp(to now: Date) {
        let elapsed = now.timeIntervalSince(state.lastUpdated)
        guard elapsed > 0 else { return }
        let cappedElapsed = min(elapsed, 8 * 3600) // cap offline progress at 8 hours

        applyProduction(elapsed: cappedElapsed)
        resolveBuildingCompletions(now: now)
        resolveResearchCompletion(now: now)
        resolveTrainingCompletions(now: now)
        resolveMarches(now: now)

        state.lastUpdated = now

        ticksSinceSave += 1
        if ticksSinceSave >= 5 {
            ticksSinceSave = 0
            saveManager.save(state)
        }
    }

    private func applyProduction(elapsed: TimeInterval) {
        let hours = elapsed / 3600.0
        var gained = ResourceBundle()
        for building in state.buildings {
            guard let resource = building.type.producesResource, !building.isUpgrading else { continue }
            let rate = building.type.productionPerHour(level: building.level) * (1 + productionBoostPercent(for: resource) / 100)
            gained[resource] += rate * hours
        }
        state.resources = state.resources + gained
        state.resources.capAt(storageCap())
    }

    private func resolveBuildingCompletions(now: Date) {
        for i in state.buildings.indices {
            if let completesAt = state.buildings[i].upgradeCompletesAt, completesAt <= now {
                state.buildings[i].level += 1
                state.buildings[i].upgradeCompletesAt = nil
                state.buildings[i].upgradeStartedAt = nil
                log("\(state.buildings[i].type.displayName) upgraded to level \(state.buildings[i].level)")
            }
        }
    }

    private func resolveResearchCompletion(now: Date) {
        guard let researching = state.researching, researching.completesAt <= now else { return }
        state.researchedTech.insert(researching.techID)
        if let node = BalanceData.techTree.first(where: { $0.id == researching.techID }) {
            log("Research complete: \(node.name)")
        }
        state.researching = nil
    }

    private func resolveTrainingCompletions(now: Date) {
        var remaining: [TrainingOrder] = []
        for order in state.trainingQueue {
            if order.completesAt <= now {
                state.troops[order.troopType, default: 0] += order.quantity
                log("Training complete: \(order.quantity) \(order.troopType.displayName)")
            } else {
                remaining.append(order)
            }
        }
        state.trainingQueue = remaining
    }

    private func resolveMarches(now: Date) {
        for i in state.marches.indices {
            var march = state.marches[i]
            switch march.phase {
            case .outbound:
                if march.arrivesAt <= now {
                    performMarchAction(&march)
                    march.phase = .returning
                }
            case .acting:
                march.phase = .returning
            case .returning:
                if march.returnsAt <= now {
                    completeMarch(&march)
                }
            }
            state.marches[i] = march
        }
        state.marches.removeAll { $0.resolved }
    }

    private func performMarchAction(_ march: inout March) {
        guard let index = state.worldTiles.firstIndex(where: { $0.position == march.destination }) else { return }
        let tile = state.worldTiles[index]

        switch (march.kind, tile.kind) {
        case (.gather, .resourceNode(let resource, let richness)):
            let amount = 200.0 * Double(richness)
            march.rewards[resource] = amount
            march.resultSummary = "Gathered \(Int(amount)) \(resource.displayName)"

        case (.attack, .barbarianCamp(let power, let tier)):
            let result = CombatResolver.resolve(
                troops: march.troops,
                hero: state.hero,
                combatBoostPercent: combatBoostPercent(),
                enemyPower: power
            )
            march.troops = result.survivingTroops
            march.rewards = result.win
                ? ResourceBundle(gold: 50.0 * Double(tier), food: 50.0 * Double(tier), wood: 50.0 * Double(tier), stone: 50.0 * Double(tier))
                : ResourceBundle()
            let xpGain = result.win ? 30.0 * Double(tier) : 10.0 * Double(tier)
            let leveledUp = state.hero.gainXP(xpGain)
            let summary = result.win ? "Victory! Camp defeated." : "Defeat. Troops retreated."
            march.resultSummary = summary
            log(summary + (leveledUp ? " Hero leveled up!" : ""))
            if result.win {
                state.worldTiles[index].kind = .empty
            }

        default:
            march.resultSummary = "Nothing found."
        }
    }

    private func completeMarch(_ march: inout March) {
        state.resources = state.resources + march.rewards
        state.resources.capAt(storageCap())
        for (type, count) in march.troops {
            state.troops[type, default: 0] += count
        }
        if let summary = march.resultSummary {
            log("March returned: \(summary)")
        }
        march.resolved = true
    }

    private func log(_ message: String) {
        state.eventLog.insert(message, at: 0)
        if state.eventLog.count > 50 { state.eventLog.removeLast() }
    }

    // MARK: - Derived values

    func productionBoostPercent(for resource: ResourceType) -> Double {
        state.researchedTech.reduce(0.0) { total, techID in
            guard let node = BalanceData.techTree.first(where: { $0.id == techID }),
                  case let .productionBoost(res, pct) = node.effect, res == resource else { return total }
            return total + pct
        }
    }

    func storageBoostPercent() -> Double {
        state.researchedTech.reduce(0.0) { total, techID in
            guard let node = BalanceData.techTree.first(where: { $0.id == techID }),
                  case let .storageBoost(pct) = node.effect else { return total }
            return total + pct
        }
    }

    func combatBoostPercent() -> Double {
        state.researchedTech.reduce(0.0) { total, techID in
            guard let node = BalanceData.techTree.first(where: { $0.id == techID }),
                  case let .combatBoost(pct) = node.effect else { return total }
            return total + pct
        }
    }

    func storageCap() -> Double {
        1000.0 * Double(currentTownHallLevel()) * (1 + storageBoostPercent() / 100)
    }

    func hourlyRate(for resource: ResourceType) -> Double {
        var total = 0.0
        for b in state.buildings where b.type.producesResource == resource && !b.isUpgrading {
            total += b.type.productionPerHour(level: b.level)
        }
        return total * (1 + productionBoostPercent(for: resource) / 100)
    }

    func currentTownHallLevel() -> Int {
        state.buildings.first(where: { $0.type == .townHall })?.level ?? 1
    }

    func hasAcademy() -> Bool {
        state.buildings.contains { $0.type == .academy && !$0.isUpgrading }
    }

    func maxBarracksLevel() -> Int {
        state.buildings.filter { $0.type == .barracks && !$0.isUpgrading }.map(\.level).max() ?? 0
    }

    func homePosition() -> GridPosition {
        GridPosition(x: state.worldGridSize / 2, y: state.worldGridSize / 2)
    }

    // MARK: - Player actions

    func placeBuilding(type: BuildingType, at position: GridPosition) {
        guard type != .townHall else { return }
        guard state.buildings.first(where: { $0.position == position }) == nil else { return }
        guard currentTownHallLevel() >= type.minTownHallLevel else { return }
        let cost = type.baseCost(level: 1)
        guard state.resources.canAfford(cost) else { return }

        state.resources = state.resources - cost
        let now = Date()
        let building = PlacedBuilding(
            type: type, level: 0, position: position,
            upgradeStartedAt: now, upgradeCompletesAt: now.addingTimeInterval(type.buildTime(level: 1))
        )
        state.buildings.append(building)
        log("Construction started: \(type.displayName)")
    }

    func upgradeBuilding(id: UUID) {
        guard let idx = state.buildings.firstIndex(where: { $0.id == id }) else { return }
        var building = state.buildings[idx]
        guard !building.isUpgrading, building.level < building.type.maxLevel else { return }

        let targetLevel = building.level + 1
        let cost = building.type.baseCost(level: targetLevel)
        guard state.resources.canAfford(cost) else { return }

        state.resources = state.resources - cost
        let now = Date()
        building.upgradeStartedAt = now
        building.upgradeCompletesAt = now.addingTimeInterval(building.type.buildTime(level: targetLevel))
        state.buildings[idx] = building
        log("Upgrading \(building.type.displayName) to level \(targetLevel)")
    }

    func canResearch(_ node: TechNode) -> Bool {
        guard !state.researchedTech.contains(node.id) else { return false }
        guard state.researching == nil else { return false }
        guard hasAcademy() else { return false }
        guard node.prerequisites.allSatisfy({ state.researchedTech.contains($0) }) else { return false }
        guard state.resources.canAfford(node.cost) else { return false }
        return true
    }

    func startResearch(_ techID: String) {
        guard let node = BalanceData.techTree.first(where: { $0.id == techID }), canResearch(node) else { return }
        state.resources = state.resources - node.cost
        let now = Date()
        state.researching = ResearchInProgress(techID: techID, startedAt: now, completesAt: now.addingTimeInterval(node.researchTime))
        log("Research started: \(node.name)")
    }

    func canTrain(_ type: TroopType) -> Bool {
        guard maxBarracksLevel() >= type.requiredBarracksLevel else { return false }
        switch type {
        case .infantry: return true
        case .archer: return state.researchedTech.contains("archery")
        case .cavalry: return state.researchedTech.contains("horsemanship")
        }
    }

    func queueTraining(_ type: TroopType, quantity: Int) {
        guard quantity > 0, canTrain(type) else { return }
        let cost = type.trainCost * Double(quantity)
        guard state.resources.canAfford(cost) else { return }

        state.resources = state.resources - cost
        let now = Date()
        let duration = type.trainTime * Double(quantity)
        let startAt = state.trainingQueue.last?.completesAt ?? now
        let order = TrainingOrder(troopType: type, quantity: quantity, startedAt: startAt, completesAt: startAt.addingTimeInterval(duration))
        state.trainingQueue.append(order)
        log("Queued training: \(quantity) \(type.displayName)")
    }

    func sendMarch(to destination: GridPosition, kind: MarchKind, troops: [TroopType: Int]) {
        let sending = troops.filter { $0.value > 0 }
        guard !sending.isEmpty else { return }
        for (type, count) in sending {
            guard (state.troops[type] ?? 0) >= count else { return }
        }
        guard let tile = state.worldTiles.first(where: { $0.position == destination }) else { return }

        let home = homePosition()
        let distance = max(abs(destination.x - home.x), abs(destination.y - home.y))
        let travelTime = TimeInterval(distance) * 20.0
        let actionDuration: TimeInterval
        switch tile.kind {
        case .resourceNode: actionDuration = 30
        case .barbarianCamp: actionDuration = 5
        default: actionDuration = 5
        }

        let now = Date()
        let arrivesAt = now.addingTimeInterval(travelTime)
        let returnsAt = arrivesAt.addingTimeInterval(actionDuration + travelTime)

        for (type, count) in sending {
            state.troops[type, default: 0] -= count
        }

        let march = March(
            kind: kind, origin: home, destination: destination, troops: sending,
            departedAt: now, arrivesAt: arrivesAt, actionDuration: actionDuration, returnsAt: returnsAt
        )
        state.marches.append(march)
        log("March deployed to (\(destination.x), \(destination.y))")
    }
}
