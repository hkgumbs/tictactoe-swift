public class Human<UI: UserInterface>: Player {

    public let team: UI.Mark
    private let ui: UI

    public init(team: UI.Mark, ui: UI) {
        self.team = team
        self.ui = ui
    }

    public func evaluate(board: Board<UI.Mark>, move: @escaping (Int) -> Void) {
        ui.prompt(board: board) {
            if board.availableSpaces().contains($0) {
                move($0)
            } else {
                self.evaluate(board: board, move: move)
            }
        }
    }

}
