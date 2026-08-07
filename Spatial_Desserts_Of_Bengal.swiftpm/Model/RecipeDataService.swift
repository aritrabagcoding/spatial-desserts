import Foundation

struct RecipeDataService {
    static func loadRecipes() async -> [RecipeModel] {
        return await Task.detached(priority: .userInitiated) {
            
            if let url = Bundle.main.url(forResource: "recipes", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode([RecipeJSON].self, from: data)
                    print("Loaded recipes from JSON file.")
                    return decoded.map {
                        RecipeModel(name: $0.name, imageName: $0.imageName, status: $0.status, chosenColorHex: $0.chosenColorHex, yield: $0.yield ?? "4 Servings", steps: $0.steps, stepTimer: $0.stepTimer, ingredients: $0.ingredients)
                    }
                } catch {
                    print("Warning: JSON File load failed (\(error)). Using Fallback.")
                }
            }
            
            return loadFallback()
        }.value
    }
    
    static func loadFallback() -> [RecipeModel] {
        guard let data = fallbackJSON.data(using: .utf8) else { return [] }
        do {
            let decoded = try JSONDecoder().decode([RecipeJSON].self, from: data)
            return decoded.map {
                RecipeModel(name: $0.name, imageName: $0.imageName, status: $0.status, chosenColorHex: $0.chosenColorHex, yield: $0.yield ?? "4 Servings", steps: $0.steps, stepTimer: $0.stepTimer, ingredients: $0.ingredients)
            }
        } catch {
            return []
        }
    }
    
    static let fallbackJSON = """
    [
        {
            "name": "Rosogolla",
            "imageName": "food1",
            "status": 0,
            "chosenColorHex": "FFFFFF",
            "yield": "12 Pieces",
            "steps": [
                "Bring the full cream milk to a rolling boil in a heavy-bottomed pan to ensure even heat distribution. Once boiling, remove from heat and stir in the lemon juice gradually until the milk fully curdles.",
                "Pour the curdled milk into a muslin cloth to drain the whey completely. Rinse the chenna under cold running water to remove the lemon flavor, then hang it for 30 minutes to remove excess moisture.",
                "Take the drained chenna on a large plate and knead it with the heel of your palm for 10 minutes. The texture should transform from crumbly to completely smooth and releasing a little fat.",
                "Divide the smooth chenna dough into 12 equal portions. Roll each portion gently between your palms to form perfectly round, crack-free balls that will expand during cooking.",
                "In a wide pot, combine the sugar and water. Bring it to a boil over high heat until the sugar dissolves completely, creating a thin, light syrup suitable for sponginess.",
                "Gently drop the chenna balls into the boiling syrup one by one. Cover the pot with a tight lid and cook on medium-high heat for 15 minutes without opening.",
                "Turn off the heat and let the Rosogollas rest in the syrup. They will stabilize and absorb the sweetness as they cool down to room temperature."
            ],
            "stepTimer": [600, 1800, 600, 300, 300, 900, 3600],
            "ingredients": [
                "1L Full Cream Milk",
                "2 tbsp Lemon Juice",
                "1.5 cups Sugar",
                "4 cups Water",
                "3 Green Cardamoms"
            ]
        },
        {
            "name": "Mishti Doi",
            "imageName": "food2",
            "status": 0,
            "chosenColorHex": "D2691E",
            "yield": "5 Clay Pots",
            "steps": [
                "Pour the milk into a heavy pan and boil it on medium heat. Continue to simmer and stir frequently until the milk reduces to half its original volume, becoming thick and creamy.",
                "In a separate non-stick pan, melt the date palm jaggery (Nolen Gur) with a splash of water. Cook it gently until it turns into a smooth, dark liquid caramel syrup.",
                "Pour the liquid jaggery into the reduced milk and whisk continuously. Ensure they combine perfectly into a lovely caramel-colored mixture, then let it cool to lukewarm temperature.",
                "In a small bowl, whisk the hung curd until it is completely smooth and lump-free. Add this culture to the lukewarm milk mixture and blend well.",
                "Pour the mixture into earthen clay pots (kulhads), which absorb excess moisture. Cover them with foil and keep in a warm, dry place for 8 hours to set.",
                "Once the yogurt has set firmly, transfer the pots to the refrigerator. Serve chilled for the best traditional taste and texture."
            ],
            "stepTimer": [1800, 300, 600, 300, 28800, 7200],
            "ingredients": [
                "1L Full Cream Milk",
                "3/4 cup Nolen Gur",
                "2 tbsp Hung Curd",
                "1 tsp Water",
                "5 Earthen Clay Pots"
            ]
        },
        {
            "name": "Sandesh",
            "imageName": "food3",
            "status": 0,
            "chosenColorHex": "FFFDD0",
            "yield": "12 Pieces",
            "steps": [
                "Take the fresh chenna and knead it on a flat surface until it is extremely smooth. The texture should feel like soft butter with no grains remaining.",
                "Mix the powdered sugar and crushed cardamom seeds into the chenna. Knead again to ensure the sugar is evenly distributed throughout the dough.",
                "Transfer the mixture to a non-stick pan on very low heat. Cook while stirring constantly to prevent sticking, until the mixture starts coming together as a soft dough.",
                "Remove from heat immediately when the mixture leaves the sides of the pan but is still moist. Overcooking will make the Sandesh dry and crumbly.",
                "Allow the mixture to cool slightly until it is comfortable to touch. Grease your hands with a little ghee and shape the dough into round balls or press into molds.",
                "Garnish each Sandesh with sliced pistachios and saffron strands. Let them set at room temperature or chill in the fridge before serving."
            ],
            "stepTimer": [600, 300, 480, 0, 600, 0],
            "ingredients": [
                "300g Fresh Chenna",
                "1/3 cup Powdered Sugar",
                "1/4 tsp Cardamom Powder",
                "1 tbsp Sliced Pistachios",
                "1 pinch Saffron"
            ]
        },
        {
            "name": "Pantua",
            "imageName": "food4",
            "status": 0,
            "chosenColorHex": "8B4513",
            "yield": "10 Pieces",
            "steps": [
                "In a large mixing bowl, mash the fresh chenna until it is free of lumps. Add the khoya, all-purpose flour, and baking soda to the bowl.",
                "Knead all the ingredients together gently to form a soft, smooth dough. Be careful not to over-knead, as this can make the Pantuas tough.",
                "Divide the dough into 10 equal parts and roll them into smooth balls. Ensure there are absolutely no cracks on the surface, or they will split while frying.",
                "Heat the ghee in a deep frying pan on medium-low heat. Fry the balls slowly, turning them frequently, until they turn a deep, rich golden-brown color.",
                "While frying, prepare a sugar syrup of one-string consistency. Drop the hot fried Pantuas directly into the warm syrup and let them soak for at least 2 hours."
            ],
            "stepTimer": [300, 300, 600, 900, 7200],
            "ingredients": [
                "200g Fresh Chenna",
                "2 tbsp Khoya",
                "1 tbsp Maida",
                "1 pinch Baking Soda",
                "Ghee or Oil",
                "2 cups Sugar Syrup"
            ]
        },
        {
            "name": "Langcha",
            "imageName": "food5",
            "status": 0,
            "chosenColorHex": "A0522D",
            "yield": "8 Large Logs",
            "steps": [
                "Crumble the paneer and khoya together in a bowl. Add the flour, baking powder, and cardamom powder, mixing until well combined.",
                "Knead the mixture gently to form a smooth dough. If it feels too dry, add a teaspoon of milk to reach the right consistency.",
                "Divide the dough into 8 portions. Roll each portion between your palms to create long, cylindrical shapes with rounded ends, ensuring smooth surfaces.",
                "Heat oil in a deep kadhai on medium heat. Fry the cylinders carefully, rolling them in the oil for even browning, until they become dark brown and firm.",
                "Remove the fried Langchas and drain excess oil. Immediately submerge them in the warm rose-flavored sugar syrup and let them soak for 3 hours."
            ],
            "stepTimer": [300, 300, 600, 900, 10800],
            "ingredients": [
                "250g Fresh Chenna",
                "100g Khoya (Mawa)",
                "Maida",
                "Baking Soda",
                "Cardamom Powder",
                "Rose Water"
            ]
        },
        {
            "name": "Chomchom",
            "imageName": "food6",
            "status": 0,
            "chosenColorHex": "FAF0E6",
            "yield": "10 Pieces",
            "steps": [
                "Prepare the Chenna by curdling milk and draining the whey. Knead the chenna until it is light, airy, and completely smooth.",
                "Shape the chenna into oval-shaped logs. These should be slightly flattened and uniform in size to ensure they cook evenly.",
                "Boil sugar and water to make a light syrup. Gently slide the oval logs into the boiling syrup and cook covered for 20 minutes.",
                "Remove the cooked Chomchoms and let them cool completely. In a separate pan, cook the Mawa with a little sugar to make the stuffing.",
                "Slice each Chomchom horizontally halfway through. Stuff generously with the sweetened Mawa and roll the entire sweet in desiccated coconut."
            ],
            "stepTimer": [600, 300, 1200, 900, 600],
            "ingredients": [
                "1L Full Cream Milk",
                "1 cup Sugar",
                "1/2 cup Mawa",
                "1/2 cup Desiccated Coconut",
                "Pistachios"
            ]
        },
        {
            "name": "Jilipi",
            "imageName": "food7",
            "status": 0,
            "chosenColorHex": "FFA500",
            "yield": "18 Spirals",
            "steps": [
                "In a large bowl, mix the all-purpose flour and cornflour. Add the sour yogurt and enough water to make a thick, smooth batter similar to pancake batter.",
                "Cover the batter and let it ferment in a warm place for 12-24 hours. This fermentation gives the Jilipi its characteristic sour tang.",
                "Prepare a thick sugar syrup with saffron strands and keep it warm. Pour the fermented batter into a squeeze bottle or piping cloth.",
                "Heat ghee in a flat pan. Pipe the batter into the hot oil in concentric circles to form spiral shapes, frying until they are crisp and golden.",
                "Remove the crispy Jilipis from the oil and dip them immediately into the warm syrup for 60 seconds, then remove to keep them crisp."
            ],
            "stepTimer": [600, 43200, 600, 900, 300],
            "ingredients": [
                "1 cup Maida",
                "1 tbsp Cornflour",
                "1/2 cup Sour Yogurt",
                "Ghee",
                "2 cups Sugar Syrup"
            ]
        },
        {
            "name": "Mihidana",
            "imageName": "food8",
            "status": 0,
            "chosenColorHex": "FFD700",
            "yield": "500g Bowl",
            "steps": [
                "Make a smooth, thin batter using besan (gram flour), water, and a pinch of saffron food color. The consistency should be pourable but not watery.",
                "Heat a generous amount of ghee in a deep frying pan. Hold a perforated ladle (jhhanjri) over the hot ghee.",
                "Pour the batter through the ladle, tapping it gently so that tiny droplets of batter fall into the hot ghee. Fry these droplets for just 30-40 seconds.",
                "Remove the fried droplets using a fine strainer to drain the excess ghee. Immediately transfer them into warm sugar syrup.",
                "Let the Mihidana soak in the syrup for a few minutes to absorb the sweetness, then drain any excess syrup and serve warm."
            ],
            "stepTimer": [300, 300, 300, 120, 300],
            "ingredients": [
                "1 cup Gram Flour",
                "Saffron Food Color",
                "1.5 cups Sugar",
                "Pure Ghee",
                "1/2 cup Water"
            ]
        },
        {
            "name": "Moa",
            "imageName": "food9",
            "status": 0,
            "chosenColorHex": "F5F5DC",
            "yield": "10 Large Balls",
            "steps": [
                "Dry roast the Khoi (puffed rice) in a pan for a few minutes to ensure it is crisp. Be careful not to burn it; remove and set aside.",
                "In a heavy pan, boil the Nolen Gur (date palm jaggery) until it thickens and becomes sticky. It should reach the soft-ball stage.",
                "Remove the jaggery from heat and immediately add the roasted Khoi and crumbled Khoya. Mix gently but quickly to coat the rice evenly.",
                "Allow the mixture to cool slightly. While it is still warm and sticky, grease your hands with ghee and shape the mixture into large round balls.",
                "Press a cashew nut and a few raisins into the top of each Moa while shaping. Let them cool completely to room temperature to firm up."
            ],
            "stepTimer": [300, 600, 120, 600, 300],
            "ingredients": [
                "100g Khoi",
                "1 cup Liquid Jaggery",
                "50g Khoya (crumbled)",
                "1 tbsp Ghee",
                "Cashews & Raisins"
            ]
        },
        {
            "name": "Ras Malai",
            "imageName": "food10",
            "status": 0,
            "chosenColorHex": "FFFACD",
            "yield": "12 Discs",
            "steps": [
                "Prepare soft chenna from the first liter of milk. Knead it until smooth and shape into small, flattened discs instead of round balls.",
                "Boil the discs in a light sugar syrup for 10 minutes. Remove them and immediately drop into a bowl of ice water to stop cooking and retain shape.",
                "In a wide pan, boil the second liter of milk. Simmer and stir continuously until it reduces to a thick, creamy consistency (Rabri).",
                "Add sugar, saffron strands, and cardamom powder to the thickened milk. Gently squeeze the water out of the chenna discs and add them to the milk.",
                "Simmer the discs in the milk for 5 minutes to absorb the flavors. Chill the Ras Malai in the refrigerator for at least 4 hours before serving."
            ],
            "stepTimer": [900, 600, 1800, 300, 14400],
            "ingredients": [
                "1L Milk",
                "1L Full Cream Milk",
                "1 cup Sugar",
                "1 pinch Saffron Strands",
                "Almonds & Pistachios"
            ]
        }
    ]
    """
}

