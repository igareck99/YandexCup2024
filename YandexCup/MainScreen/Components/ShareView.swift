import SwiftUI


struct ShareGIFView: View {
    var gifURL: URL

    var body: some View {
        Button(action: shareGIF) {
            Text("Share GIF")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    private func shareGIF() {
        guard FileManager.default.fileExists(atPath: gifURL.path) else {
            print("GIF file not found at path: \(gifURL.path)")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [gifURL], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}
