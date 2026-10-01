import Foundation

// Все таблицы калибровки проекта.
// Формат: [trim_m: [level_cm: volume_m3]]

// ─── No 3 HFO Port ──────────────────────────────
let data_No_3_P_S: CalibrationTable = [
    0.0:  [0: 0.0, 100: 41.5, 200: 83.0, /* ... */ 1290: 537.730],
    0.5:  [0: 0.0, 100: 41.7, 200: 83.4, /* ... */ 1290: 537.730],
    1.0:  [0: 0.0, 100: 41.9, 200: 83.8, /* ... */ 1290: 537.730],
    -0.5: [0: 0.0, 100: 41.3, 200: 82.6, /* ... */ 1290: 537.730],
]

let data_No_3_P_U: CalibrationTable = [
    0.0:  [0: 537.730, 100: 496.2, /* ... */ 1290: 0.0],
    0.5:  [0: 537.730, 100: 496.0, /* ... */ 1290: 0.0],
    1.0:  [0: 537.730, 100: 495.8, /* ... */ 1290: 0.0],
    -0.5: [0: 537.730, 100: 496.4, /* ... */ 1290: 0.0],
]

// ─── No 4 HFO Port ──────────────────────────────
let data_No_4_P_S: CalibrationTable = [ /* ... */ ]
let data_No_4_P_U: CalibrationTable = [ /* ... */ ]

// ─── HFO Settling ───────────────────────────────
let data_5_S: CalibrationTable = [ /* ... */ ]
let data_5_U: CalibrationTable = [ /* ... */ ]

// ─── HFO Service ────────────────────────────────
let data_4_S: CalibrationTable = [ /* ... */ ]
let data_4_U: CalibrationTable = [ /* ... */ ]

// ─── L HFO Settling ─────────────────────────────
let data_7_S: CalibrationTable = [ /* ... */ ]
let data_7_U: CalibrationTable = [ /* ... */ ]

// ─── L HFO Service ──────────────────────────────
let data_6_S: CalibrationTable = [ /* ... */ ]
let data_6_U: CalibrationTable = [ /* ... */ ]

// ─── HFO Overflow ───────────────────────────────
let data_8: CalibrationTable = [ /* ... */ ]

// ─── No 3 HFO STBD ──────────────────────────────
let data_No_3_S_S: CalibrationTable = [ /* ... */ ]
let data_No_3_S_U: CalibrationTable = [ /* ... */ ]

// ─── MGO Settling ───────────────────────────────
let data_2: CalibrationTable = [ /* ... */ ]

// ─── MGO Service ────────────────────────────────
let data_1: CalibrationTable = [ /* ... */ ]

// ─── MGO Stor ───────────────────────────────────
let data_3: CalibrationTable = [ /* ... */ ]
