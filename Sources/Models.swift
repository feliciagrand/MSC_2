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
    // ───── Группа A: 12 машинных танков ─────
    Tank(name: "M/E L.O. SUMP.T.(S)",              volFull: 94.85,   meshFull: 230, tableS: yashi_data_1,  tableU: nil),
    Tank(name: "M/E HYD. CON. OIL. TANK(C)",       volFull: 14.81,   meshFull: 240, tableS: yashi_data_2,  tableU: nil),
    Tank(name: "BILGE T.(S)",                      volFull: 177.76,  meshFull: 330, tableS: yashi_data_3,  tableU: nil),
    Tank(name: "OILY BILGE T.(P)",                 volFull: 117.34,  meshFull: 320, tableS: yashi_data_4,  tableU: nil),
    Tank(name: "L.O. SLUDGE T.(P)",                volFull: 20.56,   meshFull: 140, tableS: yashi_data_5,  tableU: nil),
    Tank(name: "WASTE F.O.T.(P)",                  volFull: 33.76,   meshFull: 135, tableS: yashi_data_6,  tableU: nil),
    Tank(name: "F.O. DRAIN T.(P)",                 volFull: 13.19,   meshFull: 300, tableS: yashi_data_7,  tableU: nil),
    Tank(name: "S/T L.O. SUMP.T.(C)³",             volFull: 8.74,    meshFull: 115, tableS: yashi_data_8,  tableU: nil),
    Tank(name: "H.F.O. OVERFLOW T.(P)(AFT)",       volFull: 83.67,   meshFull: 295, tableS: yashi_data_9,  tableU: nil),
    Tank(name: "M.G.O. OVERFLOW T.(C)",            volFull: 78.61,   meshFull: 295, tableS: yashi_data_10, tableU: nil),
    Tank(name: "M/E SCAV. AIR BOX DRAIN T.(P)",    volFull: 1.96,    meshFull: 130, tableS: yashi_data_11, tableU: nil),
    Tank(name: "M/E AIR CLR. DRAIN T.(S)",         volFull: 46.97,   meshFull: 300, tableS: yashi_data_12, tableU: nil),

    // ───── Группа B: 4 танка с расширенным диапазоном (sounding в см) ─────
    Tank(name: "Alkali",   volFull: 243.47,  meshFull: 1037, tableS: yashi_Alkali,   tableU: nil),
    Tank(name: "Sludge",   volFull: 62.53,   meshFull: 432,  tableS: yashi_Sludge,   tableU: nil),
    Tank(name: "Hold (P)", volFull: 1128.61, meshFull: 1555, tableS: yashi_Hold_P,   tableU: nil),
    Tank(name: "Hold (S)", volFull: 1309.55, meshFull: 1555, tableS: yashi_Hold_S,   tableU: nil),
]
