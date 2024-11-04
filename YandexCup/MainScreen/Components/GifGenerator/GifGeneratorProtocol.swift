import Foundation


protocol GifGeneratorProtocol {
    
    func gifCall(_ lines: [[Line]], delay: Double, completion: @escaping (Data?) -> Void)
}
