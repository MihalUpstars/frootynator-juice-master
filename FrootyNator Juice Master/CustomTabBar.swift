import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    let icons = [
        ("Juice & Smoothie", "Juice"),
        ("Drinks diary", "Drinks"),
        ("Useful properties of fruits", "Useful"),
        ("Settings", "Settings")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0..<icons.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            if selectedTab == index {
                                Text(icons[index].0)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(.opacity)
                                
                                Circle()
                                    .frame(width: 6, height: 6)
                                    .foregroundColor(.white)
                            } else {
                                Image(icons[index].1)
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.6))
                                    .blur(radius: 0.5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green.opacity(0.9))
                    .frame(height: 70)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 20)

            Color(red: 0.0, green: 0.1, blue: 0.0)
                .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        }
    }
}
