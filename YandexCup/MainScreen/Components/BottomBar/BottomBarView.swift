import SwiftUI

struct BottomBarView: View {
    
    var selectedColor: Color
    @Binding var selectedAction: BottomBarItem?
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    let onSelect: (BottomBarItem) -> Void
    
    var body: some View {
        HStack(alignment: .center,
               spacing: 16) {
            ForEach(BottomBarItem.allCases, id: \.id) { item in
                Button {
                    if selectedAction != item {
                        self.selectedAction = item
                        self.onSelect(item)
                    } else {
                        selectedAction = nil
                    }
                } label: {
                    if item == .color {
                        Circle().frame(width: 28, height: 28, alignment: .center)
                            .foregroundStyle(selectedColor)
                            .overlay(
                                Circle()
                                    .stroke(Color.limebuzz, lineWidth: item == selectedAction ? 2 : 0)
                            )
                    } else {
                        if item == selectedAction {
                            item.activeImage
                        } else {
                            item.image
                                .renderingMode(.template)
                                .foregroundColor(colorScheme == .light ? .red : .white)
                        }
                    }
                }
            }
        }
    }
}
