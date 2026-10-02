import Foundation

typealias CalibrationTable = [Double: [Double: Double]]

struct Tank: Identifiable {
    let id = UUID()
    let name: String
    let volFull: Double
    let meshFull: Double
    let tableS: CalibrationTable?
    let tableU: CalibrationTable?
}

let tanks: [Tank] = [
    Tank(name: "MGO Service",  volFull: 52.071, meshFull: 442.0, tableS: mgo_service, tableU: nil),
    Tank(name: "MGO Settling",  volFull: 14.748, meshFull: 430.0, tableS: mgo_settling, tableU: nil),
]
