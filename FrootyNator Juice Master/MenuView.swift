import SwiftUI

struct MenuView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case 0: HomeView()
                    case 1: DrinksDiaryView()
                    case 2: UsefulFruitsView()
                    case 3: SettingsView()
                    default: HomeView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                .frame(maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}


struct ScreenView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}

