import Foundation
import SwiftUI
import Combine

protocol MainViewModelProtocol: ObservableObject {
    var canPrevious: Bool { get }
    var canNext: Bool { get }
    var color: Color { get set }
    var isDrawing: Bool { get set }
    var currentBottomItem: BottomBarItem? { get set }
    var canvasStorage: [[Line]] { get set }
    var isPlayActive: Bool { get set }
    var showInstruments: Bool { get set }
    var isHiddenForPlaying: Bool { get }
    var isPauseActive: Bool { get set }
    var lineWidth: CGFloat { get set }
    func startPlaying()
    func restartPlaying()
    func stopPresentation()
    func drawRect(_ value: InstrumentsItem)
    var canvasCoordinator: CanvasView.Coordinator? { get set }
    var canvasesCoordinator: [CanvasView.Coordinator?] { get set }
    var linesStorage: LinesCurrentDrawStorage { get }
    func removeShoot(_ index: Int)
}

final class MainViewModel {
    
    @Published var canPrevious = false
    @Published var canNext = false
    @Published var color: Color = .flameburst
    @Published var isDrawing: Bool = true
    @Published var currentBottomItem: BottomBarItem? = .pencil
    @Published var canvasStorage = [[Line]]()
    @Published var isPlayActive = false
    @Published var isPauseActive = false
    @Published var showInstruments = false
    @Published var isHiddenForPlaying = false
    @Published var lineWidth: CGFloat = 5.0
    @Published var canvasesCoordinator: [CanvasView.Coordinator?] = []
    @Published var canvasCoordinator: CanvasView.Coordinator? = nil
    @ObservedObject var linesStorage: LinesCurrentDrawStorage = LinesCurrentDrawStorage()
    private var selectedShoot: Int?
    private var subscriptions = Set<AnyCancellable>()
    private let queue = OperationQueue()
    
    init() {
        self.bindInput()
    }
    
    private func bindInput() {
        $canvasStorage
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }
                if value.count > Int.max {
                    canvasStorage.removeLast()
                    debugPrint("Превышено максимальное количество рисуноков")
                }
                self.isPlayActive = !value.isEmpty
            }
            .store(in: &subscriptions)
        $currentBottomItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .pencil:
                    self.isDrawing = true
                    self.showInstruments = false
                case .brush:
                    self.isDrawing = true
                    self.showInstruments = false
                case .eraser:
                    self.isDrawing = false
                    self.showInstruments = false
                case .instruments:
                    self.isDrawing = false
                    self.showInstruments.toggle()
                case .color:
                    self.isDrawing = false
                case .ruler:
                    self.isDrawing = false
                case .none:
                    self.showInstruments = false
                }
            }
            .store(in: &subscriptions)
        linesStorage.leftLinesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lines in
                guard let self = self else { return }
                if self.canvasCoordinator?.lines != lines {
                    self.canvasCoordinator?.lines = lines
                    self.canvasCoordinator?.redrawCanvas()
                }
            }
            .store(in: &subscriptions)
        linesStorage.$canNext
            .receive(on: DispatchQueue.main)
            .assign(to: \.canNext, on: self)
            .store(in: &subscriptions)
        linesStorage.$canPrevious
            .receive(on: DispatchQueue.main)
            .assign(to: \.canNext, on: self)
            .store(in: &subscriptions)

    }
}

extension MainViewModel: MainViewModelProtocol {
    
    
    func startPlaying() {
        self.queue.cancelAllOperations()
        self.isDrawing = false
        withAnimation(.spring(duration: 0.5)) {
            self.isHiddenForPlaying = true
        }
        self.isPlayActive = false
        self.isPauseActive = true
        if let lines = self.canvasCoordinator?.lines,
           lines != self.canvasStorage.last,
           !lines.isEmpty {
            canvasStorage.append(lines)
        }
        queue.isSuspended = true
        var images = Set<UIImage>()
        self.canvasStorage.forEach { value in
            let operation = BlockOperation {
                guard !self.queue.isSuspended else { return }
                if value != self.canvasStorage.first {
                    Thread.sleep(forTimeInterval: 1 / 20)
                }
                OperationQueue.main.addOperation {
                    guard !self.queue.isSuspended else { return }
                    self.canvasCoordinator?.lines = value
                    self.canvasCoordinator?.redrawCanvas()
                    if let image = self.canvasCoordinator?.canvas.image {
                        images.insert(image)
                    }
                    guard !self.queue.isSuspended else { return }
                    if value == self.canvasStorage.last {
                        Task { @MainActor in
                            self.startPlaying()
                            
                            if let gifData = GifGenerator().createGIF(from: Array(images), frameDelay: 0.1) {
                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let gifURL = documentsDirectory.appendingPathComponent("animated.gif")
                                
                                do {
                                    try gifData.write(to: gifURL)
                                    print("GIF создан и сохранен по пути: \(gifURL)")
                                } catch {
                                    print("Ошибка при сохранении GIF: \(error)")
                                }
                            }

                            print("skaskas  \(images.count)")
                        }
                    }
                }
            }
            queue.addOperation(operation)
        }
        queue.maxConcurrentOperationCount = 1
        queue.isSuspended = false
    }
    func restartPlaying() {
        self.isPauseActive = true
        self.isPlayActive = false
        queue.isSuspended = true
        queue.cancelAllOperations()
        startPlaying()
    }
    
    func stopPresentation() {
        withAnimation(.linear) {
            queue.isSuspended = true
            queue.cancelAllOperations()
            isHiddenForPlaying = false
            isPauseActive = false
            isPlayActive = true
            canvasCoordinator?.clearCanvas()
            isDrawing = true
            self.canvasCoordinator?.lines = self.canvasStorage.last ?? []
            canvasCoordinator?.redrawCanvas()
        }
    }
    
    func drawRect(_ value: InstrumentsItem) {
        switch value {
        case .triangle:
            canvasCoordinator?.addTriangle()
        case .circle:
            canvasCoordinator?.addCircle()
        }
        currentBottomItem = nil
    }
    
    func removeShoot(_ index: Int) {
        canvasStorage.remove(at: index)
    }
    
    func selectShoot(_ index: Int) {
        selectedShoot = index
    }
}
