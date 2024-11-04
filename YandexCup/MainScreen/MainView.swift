import SwiftUI
import Combine

struct MainView<ViewModel: MainViewModelProtocol>: View {

    @StateObject var viewModel: ViewModel
    @State private var drawing = true
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var thickness: Double = 10.0
    @State private var currentAlert: CurrentAlert?
    @State private var showMenu = false
    @State private var isShowingAlert = false
    @State private var text = ""

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isHiddenForPlaying {
                    playingTopView
                } else {
                    topView
                }
                ZStack(alignment: .bottom) {
                    Image("paper-background")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    CanvasView(color: $viewModel.color, lineWidth: $viewModel.lineWidth, tool: $viewModel.currentBottomItem, coordinator: $viewModel.canvasCoordinator,
                               isDrawing: $viewModel.isDrawing, onLineAdded: { line in
                        viewModel.linesStorage.addNew(line)
                    })
                    .cornerRadius(20)
                    switch viewModel.currentBottomItem {
                    case .pencil, .brush, .eraser, .none:
                        EmptyView()
                    case .instruments:
                        InstrumentsView { value in
                            viewModel.drawRect(value)
                            
                        }
                    case .color:
                        PalleteMiniView(selectedColor: $viewModel.color, onChooseColor: {
                            viewModel.currentBottomItem = nil
                        })
                    case .ruler:
                        GradientSliderRepresentable(selectedWidth: $viewModel.lineWidth)
                            .padding(.bottom, 12)
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, 16)
                BottomBarView(selectedColor: viewModel.color, selectedAction: $viewModel.currentBottomItem,
                              onSelect: { _ in
                })
                .frame(height: 32)
                .padding(.top, 22)
                .opacity(viewModel.isHiddenForPlaying ? 0 : 1)
            }
            .onTapGesture {
                isShowingAlert = false
                UIApplication.shared.hideKeyboard()
            }
            .alert(item: $currentAlert, content: { value in
                switch value {
                case .removeScreen:
                    Alert(
                        title: Text("Вы уверены что хотите удалить кадр?"),
                        primaryButton: .cancel(
                            Text("Подтвердить"),
                            action: {
                                if viewModel.canvasCoordinator?.lines == viewModel.canvasStorage.last {
                                    viewModel.canvasStorage.removeLast()
                                }
                                viewModel.canvasCoordinator?.clearCanvas()
                                if !viewModel.canvasStorage.isEmpty {
                                    viewModel.canvasCoordinator?.lines = viewModel.canvasStorage.popLast() ?? []
                                    viewModel.canvasCoordinator?.redrawCanvas()
                                }
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("Отмена"),
                            action: { }
                        )
                    )
                case .restartAnimation:
                    Alert(
                        title: Text("Начать показ сначала?"),
                        primaryButton: .cancel(
                            Text("Подтвердить"),
                            action: {
                                viewModel.restartPlaying()
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("Отмена"),
                            action: { }
                        )
                    )
                }
            })
            .textFieldAlert(isShowing: $isShowingAlert, text: $text, title: "Введите количество элементов")
            .background {
                colorScheme == .dark ? Color.black : .white
            }
            .onChange(of: isShowingAlert) { newValue in
                if newValue == false && self.text != "" {
                    viewModel.generateSomeScreens(text)
                    text = ""
                    UIApplication.shared.hideKeyboard()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var playingTopView: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Spacer()
                Button {
                    viewModel.stopPresentation()
                } label: {
                    Image("pause-active")
                        .renderingMode(.template)
                        .foregroundColor(getColor(viewModel.isPauseActive))
                }.disabled(!viewModel.isPauseActive)
                Button {
                    viewModel.startPlaying()
                } label: {
                    Image("play-active")
                        .renderingMode(.template)
                        .foregroundColor(getColor(viewModel.isPlayActive))
                }.disabled(!viewModel.isPlayActive)
            }
        }
    }
    
    private var topView: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Button {
                    viewModel.linesStorage.previous()
                } label: {
                    Image("right-arrow-active")
                        .renderingMode(.template)
                        .foregroundColor(getColor(viewModel.canNext))
                }.disabled(viewModel.canPrevious)
                Button {
                    viewModel.linesStorage.next()
                } label: {
                    Image("left-arrow-active")
                        .renderingMode(.template)
                        .foregroundColor(getColor(viewModel.canNext))
                }.disabled(!viewModel.canNext)
            }
            Spacer()
            HStack(spacing: 16) {
                Button {
                    if let lines = viewModel.canvasCoordinator?.lines {
                        viewModel.canvasStorage.append(lines)
                    }
                    viewModel.linesStorage.resetLines()
                    viewModel.canvasesCoordinator.append(viewModel.canvasCoordinator)
                } label: {
                    Image("copy")
                        .renderingMode(.template)
                        .foregroundColor(getColor(!(viewModel.canvasCoordinator?.lines ?? []).isEmpty))
                }.disabled((viewModel.canvasCoordinator?.lines ?? []).isEmpty)
                Button {
                    self.currentAlert = .removeScreen
                    viewModel.linesStorage.resetLines()
                } label: {
                    Image("trash")
                        .renderingMode(.template)
                        .foregroundColor(getColor(!(viewModel.canvasCoordinator?.lines ?? []).isEmpty))
                }.disabled((viewModel.canvasCoordinator?.lines ?? []).isEmpty)
                Menu {
                    if !(viewModel.canvasCoordinator?.lines ?? []).isEmpty {
                        Button {
                            if let lines = viewModel.canvasCoordinator?.lines {
                                viewModel.canvasStorage.append(lines)
                            }
                            viewModel.canvasesCoordinator.append(viewModel.canvasCoordinator)
                            viewModel.canvasCoordinator?.clearCanvas()
                            viewModel.linesStorage.resetLines()
                        } label: {
                            Label {
                                Text("Создать новый рисунок")
                            } icon: {
                                Image("add-doc")
                                    .renderingMode(.template)
                                    .foregroundColor(getColor(!(viewModel.canvasCoordinator?.lines ?? []).isEmpty))
                            }
                        }
                    }
                    if !viewModel.canvasStorage.isEmpty {
                        Button {
                            viewModel.generateGif({ _ in
                            })
                        } label: {
                            Label("Создать Gif", systemImage: "folder.badge.plus")
                        }
                    }
                    Button {
                        self.isShowingAlert = true
                    } label: {
                        Label("Сгененрировать  кадры", systemImage: "person.3.sequence")
                    }
                } label: {
                    Image("add-doc")
                        .renderingMode(.template)
                        .foregroundColor(getColor(true))
                }
                NavigationLink(
                    destination: LazyView(ShootScreenAssembly.build(viewModel.canvasStorage, onRemove: { index in
                        viewModel.removeShoot(index)
                    }, onRemoveAll: {
                        viewModel.canvasStorage.removeAll()
                        viewModel.canvasCoordinator?.clearCanvas()
                    })),
                    label: {
                        Image("layers")
                            .renderingMode(.template)
                            .foregroundColor(getColor((!viewModel.canvasStorage.isEmpty)))
                    }).disabled(viewModel.canvasStorage.isEmpty)
            }
            Spacer()
            HStack(spacing: 8) {
                Image("pause-inactive")
                    .renderingMode(.template)
                    .foregroundColor(getColor(viewModel.isPauseActive))
                Button {
                    viewModel.startPlaying()
                } label: {
                    Image("play-active")
                        .renderingMode(.template)
                        .foregroundColor(getColor(viewModel.isPlayActive))
                }.disabled(!viewModel.isPlayActive)
            }
        }
    }
}


struct TextFieldAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(isShowing)
                VStack {
                    Text(self.title)
                    TextField(self.title, text: self.$text)
                        .keyboardType(.numberPad)
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isShowing.toggle()
                            }
                        }) {
                            Text("Ввод")
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                UIApplication.shared.hideKeyboard()
                                self.isShowing.toggle()
                            }
                        }) {
                            Text("Отмена")
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .frame(
                    width: deviceSize.size.width*0.75,
                    height: deviceSize.size.height*0.3
                )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}


extension View {

    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title)
    }

}
