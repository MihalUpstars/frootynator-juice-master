import SwiftUI

struct Drink: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageData: Data?
    let ingredients: [String]  
    let benefits: String
    let flavorRating: Int
    let saturationRating: Int
    let combinationRating: Int

    init(name: String, imageData: Data?, ingredients: [String], benefits: String, flavorRating: Int, saturationRating: Int, combinationRating: Int) {
        self.id = UUID()
        self.name = name
        self.imageData = imageData
        self.ingredients = ingredients
        self.benefits = benefits
        self.flavorRating = flavorRating
        self.saturationRating = saturationRating
        self.combinationRating = combinationRating
    }
}
