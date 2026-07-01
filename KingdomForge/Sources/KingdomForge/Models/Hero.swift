import Foundation

struct Hero: Codable, Equatable {
    var name: String = "Commander"
    var level: Int = 1
    var xp: Double = 0

    var xpToNextLevel: Double {
        100 * Double(level) * pow(1.15, Double(level - 1))
    }

    /// Percentage multiplier applied to combat power, +3% per level beyond 1.
    var combatBonusPercent: Double {
        Double(level - 1) * 3
    }

    @discardableResult
    mutating func gainXP(_ amount: Double) -> Bool {
        xp += amount
        var leveledUp = false
        while xp >= xpToNextLevel {
            xp -= xpToNextLevel
            level += 1
            leveledUp = true
        }
        return leveledUp
    }
}
