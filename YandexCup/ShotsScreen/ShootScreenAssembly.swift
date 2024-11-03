import SwiftUI

enum ShootScreenAssembly {
    
    static func build(_ lines: Binding<[[Line]]>,
                      onRemove: @escaping (Int) -> Void) -> some View {
        print("Inited")
        let vm = ShootScreenViewModel(onRemove: onRemove)
        let view = ShootScreenView(viewModel: vm, lines: lines)
        return view
    }
}
