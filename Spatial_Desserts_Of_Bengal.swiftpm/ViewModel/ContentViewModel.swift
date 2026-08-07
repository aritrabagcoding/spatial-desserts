import SwiftUI
import Observation

@MainActor
@Observable
class ContentViewModel {
    var mode: Int = 0
    var selectedRecipe: RecipeModel?
}

