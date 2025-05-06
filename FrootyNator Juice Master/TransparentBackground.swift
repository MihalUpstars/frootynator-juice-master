import SwiftUI

struct TransparentBackground: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = UIColor.clear 
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
