import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async -> T) async -> [T] {
            var values = [T]()
            for element in self {
                let value = await transform(element)
                values.append(value)
            }
            return values
        }
}
