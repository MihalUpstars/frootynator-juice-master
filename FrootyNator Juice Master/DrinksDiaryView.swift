import SwiftUI

struct DrinksDiaryView: View {
    @State private var savedDrinks: [Drink] = []
    @State private var showAddEntry = false
    @State private var selectedDrink: Drink? = nil
    @State private var showDetailView = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea()

            VStack {
                Text("Drinks diary")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                ScrollView {
                    VStack(spacing: 15) {
                        if savedDrinks.isEmpty {
                            VStack {
                                Image("empty_favorites")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)

                                Text("There are no entries here yet")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            }
                        } else {
                            ForEach(savedDrinks) { drink in
                                DrinkCard(drink: drink, onTap: {
                                    loadDrink(drink)
                                })
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Button(action: { showAddEntry.toggle() }) {
                    Text("Add entry")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }

            if isLoading {
                Loading2View()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadDrinks()
        }
        .fullScreenCover(isPresented: $showAddEntry) {
            AddEntryView(savedDrinks: $savedDrinks)
        }
        .fullScreenCover(isPresented: $showDetailView) {
            if let drink = selectedDrink {
                DrinkDetailView(savedDrinks: $savedDrinks, drink: drink)
            }
        }
    }

    private func loadDrink(_ drink: Drink) {
        isLoading = true
        selectedDrink = nil
        showDetailView = false

        DispatchQueue.global(qos: .userInitiated).async {
            sleep(1)

            DispatchQueue.main.async {
                selectedDrink = drink
                isLoading = false
                showDetailView = true
            }
        }
    }

    private func loadDrinks() {
        if let data = UserDefaults.standard.data(forKey: "savedDrinks") {
            if let decoded = try? JSONDecoder().decode([Drink].self, from: data) {
                savedDrinks = decoded
            }
        }
    }
}


