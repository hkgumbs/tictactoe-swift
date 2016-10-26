import XCTest
import Core

class GridTest: XCTestCase {

    func testCreatesEmptyGrid() {
        let grid: Grid<String> = Grid(dimmension: 3)

        XCTAssertTrue(grid.isEmpty)
    }

    func testCreatesGridWithOneCell() {
        let grid = Grid(dimmension: 3, contents: [0: "Cell 0"])

        XCTAssertFalse(grid.isEmpty)
        XCTAssertEqual(grid[0], "Cell 0")
    }

    func testCreatesGridWithTwoCells() {
        let grid = Grid(dimmension: 3, contents: [0: "Cell 0", 8: "Cell 8"])

        XCTAssertFalse(grid.isEmpty)
        XCTAssertEqual(grid[0], "Cell 0")
        XCTAssertEqual(grid[8], "Cell 8")
    }

    func testNonInitializedValuesAreNil() {
        let grid = Grid(dimmension: 3, contents: [1: "Cell 1"])

        XCTAssertEqual(grid[0], nil)
        XCTAssertEqual(grid[1], "Cell 1")
    }

    func testCannotSetValuesOutOfBounds() {
        let contents: [Int: String] = [-1: "Cell -1", 9: "Cell 9"]
        let grid = Grid(dimmension: 3, contents: contents)

        XCTAssertTrue(grid.isEmpty)
        XCTAssertNil(grid[-1])
        XCTAssertNil(grid[9])
    }

    func testContentsAreVisible() {
        let grid = Grid(dimmension: 3, contents: [1: "Cell 1"])

        XCTAssertEqual(grid[1], grid.contents[1])
    }

#if _runtime(_ObjC)
#else
    static var allTests: [(String, (GridTest) -> () throws -> Void)] {
        return [
            ("testCreatesEmptyGrid", testCreatesEmptyGrid),
            ("testCreatesGridWithOneCell", testCreatesGridWithOneCell),
            ("testCreatesGridWithTwoCells", testCreatesGridWithTwoCells),
            ("testNonInitializedValuesAreNil", testNonInitializedValuesAreNil),
            ("testCannotSetValuesOutOfBounds", testCannotSetValuesOutOfBounds),
            ("testContentsAreVisible", testContentsAreVisible)
        ]
    }
#endif

}