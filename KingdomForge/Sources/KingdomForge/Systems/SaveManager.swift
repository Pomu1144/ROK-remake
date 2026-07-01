import Foundation

final class SaveManager {
    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = dir.appendingPathComponent("kingdomforge_save.json")
    }

    func save(_ state: GameState) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("KingdomForge save failed: \(error)")
        }
    }

    func load() -> GameState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(GameState.self, from: data)
    }
}
