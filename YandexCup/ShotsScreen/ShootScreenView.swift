import SwiftUI

// MARK: - ShootScreenView

struct ShootScreenView<ViewModel: ShootScreenViewModelProtocol>: View {
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @State private var currentindex: Int?
    @State private var currentAlert: ShootScreenAlertItem?
    
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
                        }.padding(.horizontal, 8)
                        Text("Кадр под номером \(value + 1)")
                        HStack(alignment: .center, spacing: 16) {
                            Button {
                                currentindex = value
                                currentAlert = .removeShoot
                            } label: {
                                Image("trash")
                                    .renderingMode(.template)
                                    .foregroundColor(getColor(true))
                            }
                        }
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            viewModel.canvasCoordinators[value]?.lines = viewModel.displayLinies[value]
                            viewModel.canvasCoordinators[value]?.redrawCanvas()
                        }
                    }
                    .onChange(of: viewModel.canvasCoordinators) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            viewModel.canvasCoordinators[value]?.lines = viewModel.displayLinies[value]
                            viewModel.canvasCoordinators[value]?.redrawCanvas()
                        }
                    }
                }
            }
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
                        .foregroundColor(getColor(true))
                        .frame(width: 24, height: 24)
                }
            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                        .resizable()
//                        .renderingMode(.template)
//                        .foregroundColor(getColor(true))
//                        .frame(width: 20, height: 24)
//                }
//            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    currentAlert = .removeAll
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(getColor(true))
                        .frame(width: 24, height: 24)
                }
            }
        })
        
        .alert(item: $currentAlert, content: { value in
            switch value {
            case .removeAll:
                Alert(
                    title: Text("Удалить все кадры"),
                    primaryButton: .destructive(
                        Text("Подтвердить"),
                        action: {
                            viewModel.removeAll()
                            dismiss()
                        }
                    ),
                    secondaryButton: .cancel(
                        Text("Отмена"),
                        action: { }
                    )
                )
            case .removeShoot:
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
        })
        .background {
            colorScheme == .dark ? Color.black : .white
        }
    }
}
