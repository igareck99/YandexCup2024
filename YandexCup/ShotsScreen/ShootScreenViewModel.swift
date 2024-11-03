import SwiftUI

protocol ShootScreenViewModelProtocol: ObservableObject {
    
    func onRemoveScreen(_ index: Int?)
    
    func initData(_ lines: [[Line]])
    
    var displayLinies: [[Line]] { get set }
    
    var showAlert: Bool { get set }
    
    var canvasCoordinators: [CanvasView.Coordinator?] { get set }
}


final class ShootScreenViewModel: ObservableObject {
    @Published var displayLinies = [[Line]]()
    @Published var showAlert = false
    @Published var canvasCoordinators = [CanvasView.Coordinator?]()
    let onRemove: (Int) -> Void
    
    init(onRemove: @escaping (Int) -> Void) {
        self.onRemove = onRemove
    }
    
    func initData(_ lines: [[Line]]) {
        canvasCoordinators = Array(repeating: nil, count: lines.count)
        displayLinies = lines
        self.objectWillChange.send()
    }
}

extension ShootScreenViewModel: ShootScreenViewModelProtocol {
    func onRemoveScreen(_ index: Int?) {
        guard let index = index else { return }
        displayLinies.remove(at: index)
        canvasCoordinators.remove(at: index)
        self.objectWillChange.send()
        //lines = displayLinies
    }
}
