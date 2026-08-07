import SwiftUI
import SwiftData

struct DataSeeder {
    static func gen() async -> [RecipeModel] {
        let recipes = await RecipeDataService.loadRecipes()
        if !recipes.isEmpty {
            return recipes
        }
        
        return [
            RecipeModel(name: "Demo Dish", imageName: "food1", status: 1, chosenColorHex: "FFFFFF",
                        steps: ["Boil Water.", "Add Magic.", "Serve."],
                        stepTimer: [60, 0, 0],
                        ingredients: ["Water", "Magic"])
        ]
    }
}

