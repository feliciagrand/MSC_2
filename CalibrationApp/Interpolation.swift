import Foundation

// MARK: - Интерполяция по строке (level → volume)
func interpolateInRow(levelCm: Double, row: [Double: Double]) -> Double? {
    guard !row.isEmpty else { return nil }
    let levels = row.keys.sorted()
    guard !levels.isEmpty else { return nil }

    for i in 0..<(levels.count - 1) {
        let l1 = levels[i], l2 = levels[i + 1]
        if l1 <= levelCm && levelCm <= l2 {
            let v1 = row[l1]!, v2 = row[l2]!
            let frac = (levelCm - l1) / (l2 - l1)
            return v1 + frac * (v2 - v1)
        }
    }
    if levelCm < levels[0] { return row[levels[0]] }
    if levelCm > levels[levels.count - 1] { return row[levels[levels.count - 1]] }
    return nil
}

// MARK: - Интерполяция по trim
func interpolateVolume(trim: Double, levelCm: Double, table: CalibrationTable?) -> Double? {
    guard let table = table, !table.isEmpty else { return nil }
    let trims = table.keys.sorted()
    guard !trims.isEmpty else { return nil }

    if trim <= trims[0] { return interpolateInRow(levelCm: levelCm, row: table[trims[0]]!) }
    if trim >= trims[trims.count - 1] { return interpolateInRow(levelCm: levelCm, row: table[trims[trims.count - 1]]!) }

    let floorTrim = trims.last(where: { $0 <= trim })!
    let ceilTrim  = trims.first(where: { $0 >= trim })!

    if floorTrim == ceilTrim {
        return interpolateInRow(levelCm: levelCm, row: table[floorTrim]!)
    }

    guard let volFloor = interpolateInRow(levelCm: levelCm, row: table[floorTrim]!),
          let volCeil  = interpolateInRow(levelCm: levelCm, row: table[ceilTrim]!) else { return nil }

    let frac = (trim - floorTrim) / (ceilTrim - floorTrim)
    return volFloor + frac * (volCeil - volFloor)
}

// MARK: - Обратная интерполяция (volume → level)
func reverseInterpolateLevel(trim: Double, targetVolume: Double, table: CalibrationTable?) -> Double? {
    guard let table = table, !table.isEmpty else { return nil }
    let trims = table.keys.sorted()
    guard !trims.isEmpty else { return nil }

    var row: [Double: Double] = [:]

    if trim <= trims[0] {
        row = table[trims[0]]!
    } else if trim >= trims[trims.count - 1] {
        row = table[trims[trims.count - 1]]!
    } else {
        let floorTrim = trims.last(where: { $0 <= trim })!
        let ceilTrim  = trims.first(where: { $0 >= trim })!

        if floorTrim == ceilTrim {
            row = table[floorTrim]!
        } else {
            let rowFloor = table[floorTrim]!
            let rowCeil  = table[ceilTrim]!
            let frac = (trim - floorTrim) / (ceilTrim - floorTrim)
            let allKeys = Set(rowFloor.keys).union(Set(rowCeil.keys))
            for level in allKeys {
                let v1 = rowFloor[level]
                let v2 = rowCeil[level]
                if let v1 = v1, let v2 = v2 {
                    row[level] = v1 + frac * (v2 - v1)
                } else if let v1 = v1 {
                    row[level] = v1
                } else if let v2 = v2 {
                    row[level] = v2
                }
            }
        }
    }

    guard !row.isEmpty else { return nil }
    let levels = row.keys.sorted()
    let volumes = levels.map { row[$0]! }

    if let minV = volumes.min(), targetVolume <= minV {
        return levels[volumes.firstIndex(of: minV)!]
    }
    if let maxV = volumes.max(), targetVolume >= maxV {
        return levels[volumes.firstIndex(of: maxV)!]
    }

    for i in 0..<(volumes.count - 1) {
        let v1 = volumes[i], v2 = volumes[i + 1]
        if min(v1, v2) <= targetVolume && targetVolume <= max(v1, v2) {
            let l1 = levels[i], l2 = levels[i + 1]
            if v1 == v2 {
                if targetVolume == v1 { return (l1 + l2) / 2 }
                continue
            }
            let frac = (targetVolume - v1) / (v2 - v1)
            return l1 + frac * (l2 - l1)
        }
    }
    return nil
}
