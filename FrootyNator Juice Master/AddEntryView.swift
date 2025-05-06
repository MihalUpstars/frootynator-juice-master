import SwiftUI
import PhotosUI

struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var savedDrinks: [Drink]

    @State private var drinkName = ""
    @State private var ingredients: [String] = []
    @State private var newIngredient = ""
    @State private var recipe = ""
    @State private var flavorRating = 0
    @State private var saturationRating = 0
    @State private var ingredientRating = 0
    @State private var isSaveDisabled = true

    @State private var selectedImageData: Data? = nil
    @State private var showImagePicker = false

    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.0).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
          
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)

                        Spacer()

                        Text("Add entry")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()
                        Spacer().frame(width: 44)
                    }
                    .padding(.top, 50)

                    Button(action: { showImagePicker.toggle() }) {
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 140, height: 140)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImageData: $selectedImageData)
                    }

                    Group {
                        TextField("", text: $drinkName)
                            .modifier(EntryFieldModifier(placeholder: "Name of drink", text: $drinkName))


                        HStack {
                            TextField("", text: $newIngredient)
                                .modifier(EntryFieldModifier(placeholder: "Ingredient", text: $newIngredient))


                            Button(action: {
                                if !newIngredient.isEmpty {
                                    ingredients.append(newIngredient)
                                    newIngredient = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 24))
                            }
                        }

                        if !ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(ingredients, id: \.self) { ingredient in
                                    Text("• \(ingredient)")
                                        .foregroundColor(.white)
                                        .padding(.leading)
                                }
                            }
                        }
                        TextField("", text: $recipe)
                            .modifier(EntryFieldModifier(placeholder: "Recipe", text: $recipe))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Beverage evaluation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        RatingView(title: "Flavor", rating: $flavorRating)
                        RatingView(title: "Saturation", rating: $saturationRating)
                        RatingView(title: "Combination of ingredients", rating: $ingredientRating)
                    }

                    Button(action: saveDrink) {
                        Text("Save")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isSaveDisabled ? Color.white.opacity(0.1) : Color.green)
                            .cornerRadius(20)
                    }
                    .disabled(isSaveDisabled)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
                .padding(.top, 20)
            }
        }
        .onChange(of: drinkName) { _ in checkFields() }
        .onChange(of: recipe) { _ in checkFields() }
    }

    private func checkFields() {
        isSaveDisabled = drinkName.isEmpty || recipe.isEmpty
    }

    private func saveDrink() {
        let newDrink = Drink(
            name: drinkName,
            imageData: selectedImageData,
            ingredients: ingredients,
            benefits: recipe,
            flavorRating: flavorRating,
            saturationRating: saturationRating,
            combinationRating: ingredientRating
        )
        savedDrinks.append(newDrink)
        saveDrinksToUserDefaults()
        dismiss()
    }

    private func saveDrinksToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedDrinks) {
            UserDefaults.standard.set(encoded, forKey: "savedDrinks")
        }
    }
}

struct RatingView: View {
    let title: String
    @Binding var rating: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.white)
                .padding(.horizontal)

            HStack {
                ForEach(1..<6) { star in
                    Image(systemName: rating >= star ? "star.fill" : "star")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                parent.selectedImageData = imageData
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
struct EntryFieldModifier: ViewModifier {
    var placeholder: String
    @Binding var text: String

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.horizontal)
            }

            content
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}
