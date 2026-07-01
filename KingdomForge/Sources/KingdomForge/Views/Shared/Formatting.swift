import Foundation

func costDescription(_ cost: ResourceBundle) -> String {
    var parts: [String] = []
    if cost.gold > 0 { parts.append("\(Int(cost.gold))g") }
    if cost.food > 0 { parts.append("\(Int(cost.food))f") }
    if cost.wood > 0 { parts.append("\(Int(cost.wood))w") }
    if cost.stone > 0 { parts.append("\(Int(cost.stone))s") }
    return parts.isEmpty ? "Free" : parts.joined(separator: " | ")
}

func timeDescription(_ seconds: TimeInterval) -> String {
    let s = Int(seconds)
    if s < 60 { return "\(s)s" }
    let m = s / 60
    let remS = s % 60
    if m < 60 { return remS > 0 ? "\(m)m \(remS)s" : "\(m)m" }
    let h = m / 60
    let remM = m % 60
    return remM > 0 ? "\(h)h \(remM)m" : "\(h)h"
}
