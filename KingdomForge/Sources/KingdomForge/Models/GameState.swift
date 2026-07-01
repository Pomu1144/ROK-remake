import Foundation

struct ResearchInProgress: Codable, Equatable {
    var techID: String
    var startedAt: Date
    var completesAt: Date
}

struct GameState: Codable {
    var playerName: String = "Player"
    var resources: ResourceBundle = ResourceBundle(gold: 500, food: 800, wood: 800, stone: 600)
    var buildings: [PlacedBuilding] = BalanceData.startingBuildings()
    var researchedTech: Set<String> = []
    var researching: ResearchInProgress?
    var troops: [TroopType: Int] = [:]
    var trainingQueue: [TrainingOrder] = []
    var hero: Hero = Hero()
    var worldTiles: [WorldTile] = BalanceData.generateWorldTiles()
    var marches: [March] = []
    var eventLog: [String] = []
    var lastUpdated: Date = Date()

    var cityGridSize: Int = BalanceData.cityGridSize
    var worldGridSize: Int = BalanceData.worldGridSize
}
