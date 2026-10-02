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
    Tank(name: "No 3 HFO (Port)",  volFull: 537.730, meshFull: 1290.0, tableS: data_No_3_P_S, tableU: data_No_3_P_U),
    Tank(name: "No 4 HFO (Port)",  volFull: 627.480, meshFull: 1396.0, tableS: data_No_4_P_S, tableU: data_No_4_P_U),
    Tank(name: "No 4 HFO (STBD)",  volFull: 627.480, meshFull: 1396.0, tableS: data_No_4_S_S, tableU: data_No_4_S_U),
    Tank(name: "No 5 HFO (Port)",  volFull: 697.420, meshFull: 1504.0, tableS: data_No_5_P_S, tableU: data_No_5_P_U),
    Tank(name: "No 5 HFO (STBD)",  volFull: 697.420, meshFull: 1443.0, tableS: data_No_5_S_S, tableU: data_No_5_S_U),
    Tank(name: "HFO Settling",  volFull: 68.811, meshFull: 688.6, tableS: data_5_S, tableU: data_5_U),
    Tank(name: "HFO Service",  volFull: 68.811, meshFull: 688.0, tableS: data_4_S, tableU: data_4_U),
    Tank(name: "L HFO Settling",  volFull: 70.687, meshFull: 688.7, tableS: data_7_S, tableU: data_7_U),
    Tank(name: "L HFO Service",  volFull: 72.388, meshFull: 687.5, tableS: data_6_S, tableU: data_6_U),
    Tank(name: "HFO Overflow",  volFull: 27.099, meshFull: 250.0, tableS: data_8, tableU: nil),
    Tank(name: "No 3 HFO (STBD)",  volFull: 537.730, meshFull: 1290.0, tableS: data_No_3_S_S, tableU: data_No_3_S_U),
    Tank(name: "MGO Settling",  volFull: 14.748, meshFull: 430.0, tableS: data_2, tableU: nil),
    Tank(name: "MGO Service",  volFull: 52.071, meshFull: 442.0, tableS: data_1, tableU: nil),
    Tank(name: "MGO Stor",  volFull: 92.518, meshFull: 254.0, tableS: data_3, tableU: nil),
]
