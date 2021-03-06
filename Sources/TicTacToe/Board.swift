public struct Board<Mark: Hashable>: Collection, Equatable {

    public let startIndex = 0
    public let endIndex: Int
    public let dimmension: Int
    public let isEmpty: Bool
    private let contents: [Int: Mark]

    var isFull: Bool {
        return count == flatMap { $0 }.count
    }

    public init(dimmension: Int, contents: [Int: Mark] = Dictionary()) {
        var contents = contents
        let endIndex = dimmension * dimmension

        contents.bound(startingWith: startIndex, endingWith: endIndex)

        self.endIndex = endIndex
        self.dimmension = dimmension
        self.contents = contents
        self.isEmpty = contents.isEmpty
    }

    public subscript(index: Int) -> Mark? {
        return contents[index]
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    func availableSpaces() -> [Int] {
        return enumerated()
            .filter { $0.element == nil }
            .map { $0.offset }
    }

    func marked(at position: Int, with team: Mark) -> Board<Mark> {
        var contents = self.contents
        contents[position] = team
        return Board(dimmension: dimmension, contents: contents)
    }

    public static func == <Mark>(lhs: Board<Mark>, rhs: Board<Mark>) -> Bool {
        return lhs.dimmension == rhs.dimmension && lhs.contents == rhs.contents
    }

}

private extension Dictionary where Key: Integer {

    mutating func bound(startingWith start: Key, endingWith end: Key) {
        self.keys
            .filter { $0 >= end || $0 < start }
            .forEach { self.removeValue(forKey: $0) }
    }

}
