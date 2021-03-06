import TicTacToe

class StubPlayer: Player {

    let team: String
    var moves: [Int]

    init(team: String, moves: [Int] = []) {
        self.team = team
        self.moves = moves
    }

    func evaluate(board: Board<String>, move: @escaping (Int) -> Void) {
        moves.popLast().map(move)
    }

}
