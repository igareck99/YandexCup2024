import UIKit


extension UIApplication {
    func hideKeyboard() {
        guard let window = connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?.windows
                .filter({ $0.isKeyWindow }).first else {
            return
        }
        window.endEditing(true)
    }
}
