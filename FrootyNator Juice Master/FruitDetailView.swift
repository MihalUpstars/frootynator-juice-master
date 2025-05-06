import SwiftUI

struct FruitDetailView: View {
    let fruit: Fruit
    @Environment(\.dismiss) var dismiss
    @State private var isFavorite = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topLeading) {
                    Image(fruit.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .cornerRadius(20)
                    
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

             
                    }
                }

                Text(fruit.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Vitamins")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("A, C, K")
                        .foregroundColor(.white)

                    Text("Minerals")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)

                    Text("Potassium, Magnesium") 
                        .foregroundColor(.white)

                    Text("Health Benefits")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)

                    Text("• Supports heart health")
                        .foregroundColor(.white)
                    Text("• Helps control blood sugar levels")
                        .foregroundColor(.white)
                    Text("• Improves digestion due to fiber")
                        .foregroundColor(.white)

                    Text("Effects on the body")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)

                    Text("Eating apples regularly helps to lower cholesterol and improve digestion.")
                        .foregroundColor(.white)
                }
                .padding(.top, 5)
            }
            .padding()
        }
        .background(Color(red: 0.05, green: 0.2, blue: 0.05).ignoresSafeArea())
    }
}
