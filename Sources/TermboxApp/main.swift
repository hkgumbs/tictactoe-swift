import TicTacToe
import Termbox

try Termbox.initialize()

let ui = TermboxUI()
let players = (Human(team: true, ui: ui), Solver(team: false, opponent: true))
let simulation = Simulation(ui: ui, players: players, args: CommandLine.arguments)

simulation.play()

Termbox.shutdown()
