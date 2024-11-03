import SwiftUI

struct PalleteMiniView: View {

    @Binding var selectedColor: Color
    let onChooseColor: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 16) {
                ZStack(alignment: .center) {
                    Image("palette")
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                        .frame(width: 32, height: 32)
                        .opacity(0.02)
                        .allowsHitTesting(true)
                }
                ForEach([Color.white, Color.green, Color.red, Color.blue], id: \.self) { value in
                    Button {
                        selectedColor = value
                        onChooseColor()
                    } label: {
                        makeCircle(value)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 4).foregroundStyle(Color.gray)
            }
        }
    }
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.fixed(32))]) {
            }
        }
    }
    
    private func makeCircle(_ color: Color) -> some View {
        return Circle().frame(width: 32, height: 32, alignment: .center)
            .foregroundStyle(color)
    }
}
