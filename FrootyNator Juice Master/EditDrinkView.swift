import SwiftUI

struct EditDrinkView: View {
    @Binding var savedDrinks: [Drink]
    var drink: Drink
    @Environment(\.dismiss) var dismiss

    @State private var drinkName: String
    @State private var ingredients: [String]
    @State private var newIngredient = ""
    @State private var benefits: String
    @State private var flavorRating: Int
    @State private var saturationRating: Int
    @State private var combinationRating: Int

    init(savedDrinks: Binding<[Drink]>, drink: Drink) {
        self._savedDrinks = savedDrinks
        self.drink = drink
        _drinkName = State(initialValue: drink.name)
        _ingredients = State(initialValue: drink.ingredients)
        _benefits = State(initialValue: drink.benefits)
        _flavorRating = State(initialValue: drink.flavorRating)
        _saturationRating = State(initialValue: drink.saturationRating)
        _combinationRating = State(initialValue: drink.combinationRating)
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Text("Edit entry")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                .padding(.bottom, 10)

                TextField("Name of drink", text: $drinkName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                HStack {
                    TextField("Ingredient", text: $newIngredient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        if !newIngredient.isEmpty {
                            ingredients.append(newIngredient)
                            newIngredient = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                if !ingredients.isEmpty {
                    VStack(alignment: .leading) {
                        ForEach(ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                    }
                }

                TextField("Health Benefits", text: $benefits)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Beverage evaluation")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                RatingView(title: "Flavor", rating: $flavorRating)
                RatingView(title: "Saturation", rating: $saturationRating)
                RatingView(title: "Combination of ingredients", rating: $combinationRating)

                Button(action: saveChanges) {
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
            }
        }
        .background(Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea())
    }

    private func saveChanges() {
        if let index = savedDrinks.firstIndex(where: { $0.id == drink.id }) {
            savedDrinks[index] = Drink(
                name: drinkName,
                imageData: drink.imageData,
                ingredients: ingredients,
                benefits: benefits,
                flavorRating: flavorRating,
                saturationRating: saturationRating,
                combinationRating: combinationRating
            )
            saveDrinksToUserDefaults()
        }
        dismiss()
    }

    private func saveDrinksToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedDrinks) {
            UserDefaults.standard.set(encoded, forKey: "savedDrinks")
        }
    }
}
