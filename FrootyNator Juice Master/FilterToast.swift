import SwiftUI

struct FilterToast: View {
    @Binding var selectedFilter: String
    @Binding var showToast: Bool

    let filterOptions = ["All", "Detox", "Energy", "Immune-Boosting", "Refreshing"]

    var body: some View {
        VStack(spacing: 0) {
            Text("Filter")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 15)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filterOptions, id: \.self) { filter in
                        HStack {
                            Text(filter)
                                .font(.system(size: 16))
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: selectedFilter == filter ? "circle.inset.filled" : "circle")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    selectedFilter = filter
                                }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxHeight: 160)

            Button(action: {
                showToast = false
            }) {
                Text("Apply")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
        }
        .background(Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea())
        .frame(width: 350, height: 280) 
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
