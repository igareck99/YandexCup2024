import SwiftUI

enum ShootScreenAssembly {
    
    static func build(_ lines: [[Line]],
                      onRemove: @escaping (Int) -> Void,
                      onRemoveAll: @escaping () -> Void) -> some View {
        print("Inited")
        let vm = ShootScreenViewModel(lines: lines, onRemove: onRemove,
                                      onRemoveAll: onRemoveAll)
        let view = ShootScreenView(viewModel: vm)
        return view
    }
}
