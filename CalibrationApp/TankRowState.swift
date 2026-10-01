import Foundation

// Хранит ввод/вывод по каждому танку
struct TankRowState {
    var sounding: String = ""
    var ullage: String = ""
    var volumeInput: String = ""

    var volSoundingResult: String = "~~~"
    var volUllageResult: String = "~~~"
    var resultSoundingLevel: String = "~~~"
    var resultUllageLevel: String = "~~~"
}
