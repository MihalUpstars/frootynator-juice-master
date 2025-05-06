import SwiftUI

struct SavedRecipesView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("savedRecipes") private var savedRecipesData: String = ""

    @State private var selectedRecipe: Recipe? = nil
    @State private var showDetailView = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea()

            VStack(spacing: 0) {
          
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

                    Text("Favorites")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Spacer()
                        .frame(width: 44)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.05, green: 0.2, blue: 0.05))

                let recipes = getSavedRecipes()

                if recipes.isEmpty {
             
                    VStack {
                        Image("empty_favorites")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)

                        Text("There are no entries here yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(recipes) { recipe in
                                RecipeCard(recipe: recipe, onTap: {
                                    loadRecipe(recipe)
                                })
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }

            if isLoading {
                LoadingView()
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showDetailView) {
            if let selectedRecipe = selectedRecipe {
                RecipeDetailView(recipe: selectedRecipe)
            }
        }
    }

    private func loadRecipe(_ recipe: Recipe) {
        isLoading = true
        selectedRecipe = nil
        showDetailView = false

        DispatchQueue.global(qos: .userInitiated).async {
            sleep(1)

            DispatchQueue.main.async {
                selectedRecipe = recipe
                isLoading = false
                showDetailView = true
            }
        }
    }

    private func getSavedRecipes() -> [Recipe] {
        guard let data = savedRecipesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }
        return decoded
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    var onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green, lineWidth: 4)
                )

            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(10)

            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        onTap() 
                    }) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(10)

                    Spacer()
                }
            }
        }
        .padding(.bottom, 10)
    }
}
