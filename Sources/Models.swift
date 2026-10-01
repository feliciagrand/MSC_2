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
    Tank(name: "No 3 HFO (Port)",  volFull: 537.730, meshFull: 1290.0, tableS: nil, tableU: nil),
    Tank(name: "No 4 HFO (Port)",  volFull: 627.480, meshFull: 1396.0, tableS: nil, tableU: nil),
    Tank(name: "No 4 HFO (STBD)",  volFull: 627.480, meshFull: 1396.0, tableS: nil, tableU: nil),
    Tank(name: "No 5 HFO (Port)",  volFull: 697.420, meshFull: 1504.0, tableS: nil, tableU: nil),
    Tank(name: "No 5 HFO (STBD)",  volFull: 697.420, meshFull: 1443.0, tableS: nil, tableU: nil),
    Tank(name: "HFO Settling",     volFull: 68.811,  meshFull: 688.6,  tableS: nil, tableU: nil),
    Tank(name: "HFO Service",      volFull: 68.811,  meshFull: 688.0,  tableS: nil, tableU: nil),
    Tank(name: "L HFO Settling",   volFull: 70.687,  meshFull: 688.7,  tableS: nil, tableU: nil),
    Tank(name: "L HFO Service",    volFull: 72.388,  meshFull: 687.5,  tableS: nil, tableU: nil),
    Tank(name: "HFO Overflow",     volFull: 27.099,  meshFull: 250.0,  tableS: nil, tableU: nil),
    Tank(name: "No 3 HFO (STBD)",  volFull: 537.730, meshFull: 1290.0, tableS: nil, tableU: nil),
    Tank(name: "MGO Settling",     volFull: 14.748,  meshFull: 430.0,  tableS: nil, tableU: nil),
    Tank(name: "MGO Service",      volFull: 52.071,  meshFull: 442.0,  tableS: nil, tableU: nil),
    Tank(name: "MGO Stor",         volFull: 92.518,  meshFull: 254.0,  tableS: nil, tableU: nil),
]
