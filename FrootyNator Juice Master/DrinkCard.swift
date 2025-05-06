import SwiftUI

struct DrinkCard: View {
    let drink: Drink
    var onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let data = drink.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 3)
                    )
            } else {
                Image("drink_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 3)
                    )
            }

            HStack {
                Spacer()
                VStack {
                    Button(action: { onTap() }) {
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

            Text(drink.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(10)
        }
        .padding(.bottom, 10)
    }
}
struct Loading2View: View {
    var body: some View {
        VStack {
            ProgressView("Loading drink...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5).ignoresSafeArea())
    }
}
