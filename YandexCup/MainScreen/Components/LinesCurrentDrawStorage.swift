import Combine
import Foundation


final class LinesCurrentDrawStorage: ObservableObject {
    
    @Published var leftLines = [Line]()
    @Published var rightLines = [Line]()
    let leftLinesSubject = PassthroughSubject<[Line],Never>()
    @Published var canPrevious = false
    @Published var canNext = false
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        bindInput()
    }
    
    private func bindInput() {
        $leftLines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canPrevious = !value.isEmpty
            }
            .store(in: &subscriptions)
        $rightLines
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] value in
                self?.canNext = !value.isEmpty
            }
            .store(in: &subscriptions)
    }
    
    func addNew(_ line: Line) {
        leftLines.append(line)
    }
    
    func previous() {
        if !leftLines.isEmpty,
           let removedLine = leftLines.popLast() {
            rightLines.append(removedLine)
        }
        leftLinesSubject.send(leftLines)
    }
    
    func next() {
        if !rightLines.isEmpty,
           let removedLine = rightLines.popLast() {
            leftLines.append(removedLine)
        }
        leftLinesSubject.send(leftLines)
    }
    
    func resetLines() {
        leftLines.removeAll()
        rightLines.removeAll()
    }
}
