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
