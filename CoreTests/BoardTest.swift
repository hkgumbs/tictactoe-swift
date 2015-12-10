import XCTest
import UI
@testable import Core

class BoardTest: XCTestCase {

    func testCanMarkBoard() {
        let board = Grid<Character>(dimmension: 3)
        let newBoard = markBoard(board, position: 0, team: "X")

        XCTAssertEqual(newBoard[0], "X")
    }

    func testCanMarkMarkedBoard() {
        let board = Grid<Character>(dimmension: 3, contents: [1: "O"])
        let newBoard = markBoard(board, position: 0, team: "X")

        XCTAssertEqual(newBoard[0], "X")
        XCTAssertEqual(newBoard[1], "O")
    }

    func testBoardIsNotFull() {
        let board = Grid<Character>(dimmension: 2)

        XCTAssertTrue(board.isEmpty)
        XCTAssertFalse(isBoardFull(board))
    }

    func testBoardIsFull() {
        let board = Grid<Character>(dimmension: 2, contents: [0: "A", 1: "B", 2: "C", 3: "D"])

        XCTAssertFalse(board.isEmpty)
        XCTAssertTrue(isBoardFull(board))
    }

    func testAvailablePositionsWhenEmpty() {
        let board = Grid<Character>(dimmension: 2)

        XCTAssertEqual(availableSpaces(board), [0, 1, 2, 3])
    }

    func testAvailablePositionsWhenNotEmpty() {
        let board = Grid<Character>(dimmension: 2, contents: [1: "$", 2: "#"])

        XCTAssertEqual(availableSpaces(board), [0, 3])
    }

}