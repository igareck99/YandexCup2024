import SwiftUI

struct GradientSliderRepresentable: UIViewRepresentable {
    @Binding var selectedWidth: CGFloat

    func makeUIView(context: Context) -> GradientSlider {
        let sliderView = GradientSlider()
        sliderView.widthChanged = { width in
            DispatchQueue.main.async {
                self.selectedWidth = width
            }
        }
        return sliderView
    }

    func updateUIView(_ uiView: GradientSlider, context: Context) {
        uiView.selectedWidth = selectedWidth
    }
}
