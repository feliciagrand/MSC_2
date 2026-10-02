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
    Tank(name: "№ 3 HFO (Port)",  volFull: 537.730, meshFull: 1290.0, tableS: data_No_3_P_S, tableU: data_No_3_P_U),
    Tank(name: "№ 4 HFO (Port)",  volFull: 627.480, meshFull: 1396.0, tableS: data_No_4_P_S, tableU: data_No_4_P_U),
]
