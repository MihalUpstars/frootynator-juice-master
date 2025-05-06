import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @AppStorage("savedRecipes") private var savedRecipesData: String = ""

    var body: some View {
        ScrollView {
            VStack {
                Image(recipe.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                    .cornerRadius(20)

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Button(action: { toggleFavorite(recipe) }) {
                        Image(systemName: isRecipeSaved(recipe) ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isRecipeSaved(recipe) ? .red : .green)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 50)

                Text(recipe.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Ingredients")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)

                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .foregroundColor(.white)
                }

                Text("Health Benefits")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)

                ForEach(recipe.benefits, id: \.self) { benefit in
                    Text("• \(benefit)")
                        .foregroundColor(.white)
                }

                Text("Preparation Method")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)

                ForEach(Array(recipe.steps.enumerated()), id: \.0) { index, step in
                    Text("\(index + 1). \(step)")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(   Color(red: 0.0, green: 0.1, blue: 0.0))
            .cornerRadius(20)
        }
        .background(   Color(red: 0.0, green: 0.1, blue: 0.0))
    }

    private func toggleFavorite(_ recipe: Recipe) {
        var savedList = getSavedRecipes()

        if let index = savedList.firstIndex(where: { $0.id == recipe.id }) {
            savedList.remove(at: index)
        } else {
            savedList.append(recipe)
        }

        saveRecipes(savedList)
    }

    private func isRecipeSaved(_ recipe: Recipe) -> Bool {
        getSavedRecipes().contains { $0.id == recipe.id }
    }

    private func getSavedRecipes() -> [Recipe] {
        guard let data = savedRecipesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveRecipes(_ recipes: [Recipe]) {
        if let encoded = try? JSONEncoder().encode(recipes) {
            savedRecipesData = String(data: encoded, encoding: .utf8) ?? ""
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading recipe...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5).ignoresSafeArea())
    }
}

struct Recipe: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageName: String
    let category: String
    let ingredients: [String]
    let benefits: [String]
    let steps: [String]

    init(id: UUID = UUID(), name: String, imageName: String, category: String, ingredients: [String], benefits: [String], steps: [String]) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.category = category
        self.ingredients = ingredients
        self.benefits = benefits
        self.steps = steps
    }
}

let recipeData: [Recipe] = [
    Recipe(
        name: "Detox Smoothie \"Green Cleanse\"",
        imageName: "detox_smoothie",
        category: "Detox",
        ingredients: [
            "Spinach (1 cup)",
            "Apple (1 piece)",
            "Cucumber (1/2 piece)",
            "Lemon (1/4 piece)",
            "Ginger (1 cm)",
            "Water (100 ml)"
        ],
        benefits: [
            "Spinach is rich in iron and antioxidants.",
            "Cucumber hydrates and detoxifies.",
            "Ginger improves digestion."
        ],
        steps: [
            "Chop the apple, cucumber, and ginger.",
            "Add all ingredients to a blender.",
            "Blend until smooth.",
            "Serve chilled."
        ]
    ),

    Recipe(
        name: "Berry Mix Immunostimulating Smoothie",
        imageName: "berry_mix_smoothie",
        category: "Immune-Boosting",
        ingredients: [
            "Strawberries (100 g)",
            "Blueberries (50 g)",
            "Banana (1)",
            "Yogurt (100 ml)",
            "Honey (1 tsp)"
        ],
        benefits: [
            "Berries are rich in antioxidants.",
            "Banana provides energy.",
            "Yogurt improves digestion."
        ],
        steps: [
            "Slice the banana.",
            "Add all ingredients to a blender.",
            "Blend until smooth.",
            "Serve immediately."
        ]
    ),

    Recipe(
        name: "Energizing Smoothie \"Peachy Delight\"",
        imageName: "peachy_delight_smoothie",
        category: "Energy",
        ingredients: [
            "Peach (1)",
            "Banana (1)",
            "Greek yogurt (100 g)",
            "Almond milk (150 ml)",
            "Honey (1 tsp)"
        ],
        benefits: [
            "Peaches are rich in vitamins A and C.",
            "Bananas provide quick energy and potassium.",
            "Greek yogurt is high in protein and supports gut health."
        ],
        steps: [
            "Slice the peach and banana.",
            "Combine all ingredients in a blender.",
            "Blend until creamy and smooth.",
            "Serve immediately, optionally garnished with peach slices."
        ]
    ),

    Recipe(
        name: "Energy Juice \"Citrus Charge\"",
        imageName: "citrus_charge_juice",
        category: "Energy",
        ingredients: [
            "Orange (2 pieces)",
            "Carrots (1 piece)",
            "Ginger (1 cm)",
            "Honey (1 tsp)"
        ],
        benefits: [
            "Orange is rich in vitamin C.",
            "Carrots improve vision and immunity.",
            "Ginger gives vigor."
        ],
        steps: [
            "Squeeze juice from oranges and carrots.",
            "Add grated ginger and honey.",
            "Stir and serve fresh."
        ]
    ),

    Recipe(
        name: "Refreshing Juice \"Cucumber Mint Cooler\"",
        imageName: "cucumber_mint_cooler",
        category: "Refreshing",
        ingredients: [
            "Cucumber (1)",
            "Lemon (1/2)",
            "Fresh mint leaves (a handful)",
            "Water (100 ml)"
        ],
        benefits: [
            "Cucumber hydrates and is low in calories.",
            "Lemon is rich in vitamin C and aids digestion.",
            "Mint provides a refreshing flavor and helps with digestion."
        ],
        steps: [
            "Chop the cucumber and squeeze the juice from the lemon.",
            "Blend cucumber, lemon juice, mint leaves, and water until smooth.",
            "Strain the mixture and serve chilled."
        ]
    ),

    Recipe(
        name: "Refreshing Juice \"Watermelon Breeze\"",
        imageName: "watermelon_breeze",
        category: "Refreshing",
        ingredients: [
            "Watermelon (300 g)",
            "Lime (1/2)",
            "Mint (a few leaves)"
        ],
        benefits: [
            "Watermelon hydrates and is rich in vitamins.",
            "Lime adds freshness.",
            "Mint soothes and refreshes."
        ],
        steps: [
            "Chop the watermelon and remove seeds.",
            "Juice the lime.",
            "Blend watermelon, lime juice, and mint.",
            "Strain and serve chilled."
        ]
    ),
    Recipe(
           name: "Refreshing Juice \"Cucumber Mint Cooler\"",
           imageName: "cucumber_mint_cooler",
           category: "Refreshing",
           ingredients: [
               "Cucumber (1)",
               "Lemon (1/2)",
               "Fresh mint leaves (a handful)",
               "Water (100 ml)"
           ],
           benefits: [
               "Cucumber hydrates and is low in calories.",
               "Lemon is rich in vitamin C and aids digestion.",
               "Mint provides a refreshing flavor and helps with digestion."
           ],
           steps: [
               "Chop the cucumber and squeeze the juice from the lemon.",
               "Blend cucumber, lemon juice, mint leaves, and water until smooth.",
               "Strain the mixture and serve chilled."
           ]
       )
]
