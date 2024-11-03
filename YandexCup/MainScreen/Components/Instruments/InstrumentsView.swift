import SwiftUI

struct InstrumentsView: View {
    
    let onSelect: (InstrumentsItem) -> Void
   
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 16) {
                ForEach(InstrumentsItem.allCases, id: \.self) { value in
                    Button {
                        onSelect(value)
                    } label: {
                        value.image
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
}
