import SwiftUI
import Combine

struct MainView<ViewModel: MainViewModelProtocol>: View {

    @StateObject var viewModel: ViewModel
    @State private var drawing = true
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var thickness: Double = 10.0
    @State private var currentAlert: CurrentAlert?
    @State private var showMenu = false

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
            .background {
                colorScheme == .dark ? Color.black : .white
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var playingTopView: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Spacer()
                Button {
                    currentAlert = .restartAnimation
                } label: {
                    Image(systemName: "arrowshape.zigzag.right")
                        .resizable()
                        .frame(width: 22, height: 22, alignment: .center)
                        .tint(colorScheme == .dark ? .white : .black)
                }
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
                    Button {
                        if viewModel.canvasStorage.isEmpty {
                            return
                        }
                        viewModel.generateGif({ _ in
                        })
                    } label: {
                        Label("Создать Gif", systemImage: "folder.badge.plus")
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
