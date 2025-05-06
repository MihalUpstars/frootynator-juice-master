import SwiftUI

struct DrinkDetailView: View {
    @Binding var savedDrinks: [Drink] 
    var drink: Drink
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topLeading) {
                    if let data = drink.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(20)
                    } else {
                        Image("drink_placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(20)
                    }

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 15)
                        .padding(.top, 15)

                        Spacer()

                        Button(action: { deleteDrink() }) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 15)
                    }
                    .padding(.top, 10)
                }

                Text(drink.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 10)

                Text("Ingredients")
                    .font(.headline)
                    .foregroundColor(.gray)

                ForEach(drink.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .foregroundColor(.white)
                }

                Text("Health Benefits")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)

                Text(drink.benefits)
                    .foregroundColor(.white)

                Text("Beverage evaluation")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)

                RatingView(title: "Flavor", rating: .constant(drink.flavorRating))
                RatingView(title: "Saturation", rating: .constant(drink.saturationRating))
                RatingView(title: "Combination of ingredients", rating: .constant(drink.combinationRating))
            }
            .padding()
        }
        .background(Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea())
    }

    private func deleteDrink() {
        if let index = savedDrinks.firstIndex(where: { $0.id == drink.id }) {
            savedDrinks.remove(at: index)
            saveDrinksToUserDefaults()
        }
        dismiss()
    }

    private func editDrink() {
        print("\(drink.name)")
    }

    private func saveDrinksToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedDrinks) {
            UserDefaults.standard.set(encoded, forKey: "savedDrinks")
        }
    }
}
