import SwiftUI

// MARK: - ShootScreenViewModel

final class ShootScreenViewModel: ObservableObject {
    var lines: [[Line]]
    @Published var canvasCoordinators = [CanvasView.Coordinator?]()
    var displayLinies = [[Line]]()
    let onRemove: (Int) -> Void
    let onRemoveAll: () -> Void
    
    init(lines: [[Line]],
        onRemove: @escaping (Int) -> Void,
         onRemoveAll: @escaping () -> Void) {
        self.lines = lines
        self.onRemove = onRemove
        self.onRemoveAll = onRemoveAll
        self.initData()
    }
    
    func initData() {
        canvasCoordinators = Array(repeating: nil, count: lines.count)
        displayLinies = lines
        self.objectWillChange.send()
    }
}

extension ShootScreenViewModel: ShootScreenViewModelProtocol {
    func onRemoveScreen(_ index: Int?) {
        guard let index = index else { return }
        lines.remove(at: index)
        displayLinies = lines
        canvasCoordinators.remove(at: index)
        onRemove(index)
        self.objectWillChange.send()
    }
    
    func removeAll() {
        onRemoveAll()
        displayLinies.removeAll()
        canvasCoordinators.removeAll()
        self.objectWillChange.send()
    }
}
