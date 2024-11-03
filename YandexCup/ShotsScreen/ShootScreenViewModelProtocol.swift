import Foundation


protocol ShootScreenViewModelProtocol: ObservableObject {
    
    func onRemoveScreen(_ index: Int?)
    
    var displayLinies: [[Line]] { get set }
    
    func removeAll()
    
    var canvasCoordinators: [CanvasView.Coordinator?] { get set }
}
