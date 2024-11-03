import SwiftUI

// MARK: - ShootScreenView

struct ShootScreenView<ViewModel: ShootScreenViewModelProtocol>: View {
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @Binding var lines: [[Line]]
    @State private var currentindex: Int?
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(viewModel.displayLinies.indices, id:\.self) { value in
                    VStack(alignment: .center, spacing: 8) {
                        ZStack(alignment: .bottom) {
                            Image("paper-background")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            CanvasView(color: .constant(.red), lineWidth: .constant(1), tool: .constant(.pencil), coordinator: $viewModel.canvasCoordinators[value],
                                       isDrawing: .constant(false), onLineAdded: { _ in })
                            .cornerRadius(20)
                            .simultaneousGesture(DragGesture())
                            .contentShape(Rectangle())
                        }.padding(.horizontal, 8)
                        Text("Кадр под номером \(value)")
                        HStack(alignment: .center, spacing: 16) {
                            Button {
                                currentindex = value
                                viewModel.showAlert = true
                            } label: {
                                Image("trash")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.initData(self.lines)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                viewModel.canvasCoordinators[value]?.lines = viewModel.displayLinies[value]
//                viewModel.canvasCoordinators[value]!.redrawCanvas()
//            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(colorScheme == .dark ? .white : .red)
                        .frame(width: 24, height: 24)
                }

            }
        })
        .alert(
            isPresented: $viewModel.showAlert
        ) {
            Alert(
                title: Text("Удалить кадр?"),
                primaryButton: .destructive(
                    Text("Подтвердить"),
                    action: {
                        viewModel.onRemoveScreen(currentindex)
                    }
                ),
                secondaryButton: .cancel(
                    Text("Отмена"),
                    action: { }
                )
            )
        }
        .background {
            colorScheme == .dark ? Color.black : .white
        }
    }
}
