import SwiftUI

struct UsefulFruitsView: View {
    let fruits = [
        Fruit(name: "Apple", image: "Apple"),
        Fruit(name: "Orange", image: "Orange"),
        Fruit(name: "Banana", image: "Banana"),
        Fruit(name: "Strawberry", image: "Strawberry"),
        Fruit(name: "Mango", image: "Mango"),
        Fruit(name: "Pineapple", image: "Pineapple"),
        Fruit(name: "Kiwi", image: "Kiwi")
    ]
    
    let combinations = [
        ("Apple + Orange", ["Apple", "Orange"], "This combination provides a double dose of vitamin C and fiber, which is beneficial for immunity and digestion."),
        ("Banana + Strawberry", ["Banana", "Strawberry"], "This pairing is rich in potassium and antioxidants, supporting heart and skin health."),
        ("Mango + Pineapple", ["Mango", "Pineapple"], "A tropical duo rich in vitamins A and C, which boosts immunity and improves skin health."),
        ("Strawberry + Kiwi", ["Strawberry", "Kiwi"], "This mix is rich in vitamin C and antioxidants, helping to combat fatigue and strengthen immunity."),
        ("Pineapple + Kiwi", ["Pineapple", "Kiwi"], "This combination is packed with vitamin C and bromelain, which aids digestion and boosts immunity."),
        ("Mango + Banana", ["Mango", "Banana"], "This combination is packed with vitamin C and bromelain, which aids digestion and boosts immunity.")
    ]
    
    @State private var selectedFruit: Fruit? = nil
    @State private var showDetailView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Useful properties\nof fruits")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(fruits) { fruit in
                        Button(action: {
                            selectedFruit = fruit
                            showDetailView.toggle()
                        }) {
                            FruitCard(name: fruit.name, image: fruit.image)
                        }
                    }
                }
                .padding(.horizontal, 15)
                
                Text("Tips for Combining Fruits for Maximum Benefits")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                
                VStack(spacing: 10) {
                    ForEach(combinations, id: \.0) { title, images, description in
                        FruitCombinationCard(title: title, images: images, description: description)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .navigationBarHidden(true)
        .background(Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea())
        .fullScreenCover(item: $selectedFruit) { fruit in
            FruitDetailView(fruit: fruit)
        }
    }
}

struct FruitCard: View {
    let name: String
    let image: String
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 5)
            }
            .frame(width: 150, height: 150)
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 1))
            
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.green)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)

        }
    }
}

struct FruitCombinationCard: View {
    let title: String
    let images: [String]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                ForEach(images, id: \.self) { image in
                    Image(image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.green.opacity(0.3))
        .cornerRadius(10)
    }
}

struct Fruit: Identifiable {
    let id = UUID()
    let name: String
    let image: String
}
