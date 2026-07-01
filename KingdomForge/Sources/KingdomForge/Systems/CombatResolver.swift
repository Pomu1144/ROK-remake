import Foundation

struct CombatResult {
    var win: Bool
    var survivingTroops: [TroopType: Int]
}

enum CombatResolver {
    static func resolve(
        troops: [TroopType: Int],
        hero: Hero,
        combatBoostPercent: Double,
        enemyPower: Double
    ) -> CombatResult {
        let basePower = troops.reduce(0.0) { $0 + Double($1.value) * $1.key.basePower }
        guard basePower > 0 else {
            return CombatResult(win: false, survivingTroops: troops)
        }

        let multiplier = (1 + hero.combatBonusPercent / 100) * (1 + combatBoostPercent / 100)
        let playerPower = basePower * multiplier
        let ratio = playerPower / enemyPower
        let win = ratio >= 1.0

        let casualtyFraction: Double
        if win {
            casualtyFraction = max(0.05, min(0.3, 0.3 - (ratio - 1) * 0.1))
        } else {
            casualtyFraction = max(0.3, min(0.9, 0.9 - ratio * 0.3))
        }

        var survivors: [TroopType: Int] = [:]
        for (type, count) in troops {
            let losses = Int((Double(count) * casualtyFraction).rounded())
            survivors[type] = max(0, count - losses)
        }
        return CombatResult(win: win, survivingTroops: survivors)
    }
}
