import SwiftUI

struct HomeView: View {
    @State private var selectedRecipe: Recipe? = nil
    @State private var showDetailView = false
    @State private var isLoading = false
    @State private var showFilterToast = false
    @State private var selectedFilter: String = "All"

    var body: some View {
        ZStack {
            VStack {
      
                HStack {
                    Text("Juice & Smoothie Recipe Catalog")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    NavigationLink(destination: SavedRecipesView()) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    }


                    Button(action: { showFilterToast.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 50)
                .padding(.bottom, 10)

                Text("Category: \(selectedFilter)")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding(.bottom, 5)

                ScrollView {
                    VStack(alignment: .leading) {
                        let filteredRecipes = selectedFilter == "All" ? recipeData : recipeData.filter { $0.category == selectedFilter }

                        ForEach(filteredRecipes) { recipe in
                            RecipeCard(recipe: recipe, onTap: {
                                loadRecipe(recipe)
                            })
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .background(Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea())

            if showFilterToast {
                FilterToast(selectedFilter: $selectedFilter, showToast: $showFilterToast)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
            }

            if isLoading {
                LoadingView()
            }
        }
        .fullScreenCover(isPresented: $showDetailView) {
            if let selectedRecipe = selectedRecipe {
                NavigationView {
                    RecipeDetailView(recipe: selectedRecipe)
                }
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
                print("\(selectedRecipe?.name ?? "nil")")
            }
        }
        
    }
}
