import Foundation
import SwiftUI
import SwiftData

@Model
class RecipeModel: Identifiable {
    var id: UUID
    var name: String
    var imageName: String
    var status: Int
    var chosenColorHex: String
    
    
    var yield: String
    
    var steps: [String]
    var stepTimer: [Double]
    
    var ingredients: [String]
    var userFeedback: String
    var emojiMood: String
    
    var puzzleStateJSON: String
    
    init(name: String, imageName: String, status: Int, chosenColorHex: String, yield: String = "4 Servings", steps: [String] = [], stepTimer: [Double] = [], ingredients: [String] = [], puzzleStateJSON: String = "") {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.status = status
        self.chosenColorHex = chosenColorHex
        self.yield = yield
        self.steps = steps
        self.stepTimer = stepTimer
        self.ingredients = ingredients
        self.userFeedback = ""
        self.emojiMood = ""
        self.puzzleStateJSON = puzzleStateJSON
    }
    
    var col: Color { Color(hex: chosenColorHex) }
}

struct RecipeJSON: Codable {
    let name: String
    let imageName: String
    let status: Int
    let chosenColorHex: String
    let yield: String?
    let steps: [String]
    let stepTimer: [Double]
    let ingredients: [String]
}

