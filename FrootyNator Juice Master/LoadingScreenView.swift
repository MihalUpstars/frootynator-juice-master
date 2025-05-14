import SwiftUI

struct LoadingScreenView: View {
    @State private var progress: CGFloat = 0.0
    @State private var isLoaded: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
            
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 5)

                    ZStack(alignment: .leading) {
                    
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 10)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .padding(.horizontal, 20)

                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: progress * (UIScreen.main.bounds.width - 40), height: 10)
                            .foregroundColor(Color.green)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 170)

                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            if progress < 1.0 {
                                progress += 0.05
                            } else {
                                timer.invalidate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isLoaded = true
                                }
                            }
                        }
                    }
                }

                NavigationLink(
                    destination: MenuView(),
                    isActive: $isLoaded,
                    label: { EmptyView() }
                )
            }
        }
        .navigationBarHidden(true) 
    }
}

import SwiftUI


struct LoaderViewNator_Juice_Master: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(0..<4) { index in
                RhombusNator_Juice_Master()
                    .fill(Color.red)
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(y: -30)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation
                            .linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                            .delay(0.15 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 80, height: 80)
        .onAppear {
            isAnimating = true
        }
    }
}

struct RhombusNator_Juice_Master: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        path.addLine(to: CGPoint(x: midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: midY))
        path.closeSubpath()
        return path
    }
}

