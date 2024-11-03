import SwiftUI

struct CustomSlider: View {
    @Binding var value: CGFloat
    @State var width1:CGFloat = 30
    var totalWidth = UIScreen.main.bounds.width - 85
    
    var body: some View {
            HStack(spacing: 5 ) {
                ZStack(alignment: .leading ) {
                    Rectangle()
                        .fill(Color.black.opacity(0.20))
                        .frame(width:totalWidth, height: 6)
                    Rectangle()
                        .fill(Color.teal)
                        .frame(width: self.width1,height: 6)
                    Circle()
                        .fill(Color.teal)
                        .frame(width: 18,height: 18)
                        .offset(x:self.width1)
                        .gesture(
                            DragGesture()
                                .onChanged( { (value) in
                                    if value.location.x <= totalWidth-10 && value.location.x >= 0{
                                        self.width1 = value.location.x
                                    }


                                }))
                }
                    
                }.padding(.top,25)
            .onChange(of: width1) { newValue in
                DispatchQueue.main.async {
                    self.value = newValue > 300.0 ? 30 : (newValue / 10)
                    print("sklaskqwksakl  \(self.value)")
                }
            }
    }
}
