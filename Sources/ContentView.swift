import SwiftUI

struct ContentView: View {

    @State private var trimInput: String = ""
    @State private var states: [String: TankRowState] = [:]
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedTank: Tank? = nil

    // Список основных HFO-танков (без HFO Overflow и MGO Stor для основного блока)
    private var mainTanks: [Tank] { tanks }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {

                // Фон как в системных приложениях
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // ── Trim card ───────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Trim")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)

                            HStack(spacing: 12) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(.blue)
                                    .font(.title3)

                                TextField("0.0", text: $trimInput)
                                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.leading)

                                Text("m")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)

                        // ── Tanks list ──────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanks")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 16)

                            VStack(spacing: 0) {
                                ForEach(Array(tanks.enumerated()), id: \.element.id) { index, tank in
                                    NavigationLink(destination: TankDetailView(tank: tank, states: $states)) {
                                        tankListRow(tank: tank)
                                    }
                                    .buttonStyle(.plain)

                                    if index < tanks.count - 1 {
                                        Divider()
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                            .padding(.horizontal, 16)
                        }

                        // Отступ снизу под кнопку Calculate
                        Spacer().frame(height: 100)

                        // Copyright
                        VStack(spacing: 2) {
                            Text("Special for M/V 'MSC Turin III'")
                            Text("™ Copyright © by NeverwiN. All Rights Reserved 2025")
                            Text("Telegram: +507 6861 3586")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    }
                    .padding(.top, 8)
                }

                // ── Floating Calculate button ───────────────────
                Button(action: calculate) {
                    HStack {
                        Image(systemName: "equal.circle.fill")
                        Text("Calculate")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.35), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .navigationTitle("Calibration")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            for tank in tanks {
                                states[tank.name] = TankRowState()
                            }
                            trimInput = ""
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(states.values.allSatisfy { $0.sounding.isEmpty && $0.ullage.isEmpty && $0.volumeInput.isEmpty } && trimInput.isEmpty)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            if states.isEmpty {
                for tank in tanks {
                    states[tank.name] = TankRowState()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Attention"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    // ── Строка списка танков ──────────────────────────────
    @ViewBuilder
    private func tankListRow(tank: Tank) -> some View {
        let st = states[tank.name] ?? TankRowState()

        HStack(spacing: 12) {

            // Иконка
            ZStack {
                Circle()
                    .fill(iconColor(for: tank).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName(for: tank))
                    .foregroundColor(iconColor(for: tank))
                    .font(.system(size: 16, weight: .semibold))
            }

            // Название + подсказка
            VStack(alignment: .leading, spacing: 2) {
                Text(tank.name)
                    .font(.body)
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    statusPill(text: statusText(st: st, tank: tank),
                               color: statusColor(st: st))
                }
            }

            Spacer()

            // Full объём
            Text(String(format: "%.1f m³", tank.volFull))
                .font(.caption)
                .foregroundColor(.secondary)

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }

    // ── Логика вспомогательных данных ─────────────────────

    private func iconName(for tank: Tank) -> String {
        if tank.name.contains("MGO") { return "drop.fill" }
        if tank.name.contains("L HFO") { return "leaf.fill" }
        if tank.name.contains("Settling") { return "hourglass" }
        if tank.name.contains("Service") { return "bolt.fill" }
        if tank.name.contains("Overflow") { return "exclamationmark.triangle.fill" }
        return "fuelpump.fill"
    }

    private func iconColor(for tank: Tank) -> Color {
        if tank.name.contains("MGO") { return .green }
        if tank.name.contains("L HFO") { return .mint }
        if tank.name.contains("Overflow") { return .orange }
        if tank.name.contains("Settling") { return .brown }
        return .blue
    }

    private func statusText(st: TankRowState, tank: Tank) -> String {
        if !st.sounding.isEmpty { return "Sounding \(st.sounding) cm" }
        if !st.ullage.isEmpty { return "Ullage \(st.ullage) cm" }
        if !st.volumeInput.isEmpty { return "Target \(st.volumeInput) m³" }
        return "Not entered"
    }

    private func statusColor(st: TankRowState) -> Color {
        if !st.sounding.isEmpty || !st.ullage.isEmpty || !st.volumeInput.isEmpty {
            return .blue
        }
        return .secondary
    }

    @ViewBuilder
    private func statusPill(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .cornerRadius(6)
    }

    // ── Расчёт ────────────────────────────────────────────
    private func calculate() {
        guard let trim = Double(trimInput.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Please enter a valid trim value (m)."
            showAlert = true
            return
        }

        // Проверка конфликтов Sounding / Ullage
        var conflicts: [String] = []
        for tank in tanks {
            if let st = states[tank.name] {
                let s = st.sounding.trimmingCharacters(in: .whitespaces)
                let u = st.ullage.trimmingCharacters(in: .whitespaces)
                if !s.isEmpty && !u.isEmpty {
                    conflicts.append(tank.name)
                }
            }
        }
        if !conflicts.isEmpty {
            alertMessage = "Specify either Sounding or Ullage (not both) for:\n" + conflicts.joined(separator: "\n")
            showAlert = true
            return
        }

        for tank in tanks {
            var st = states[tank.name] ?? TankRowState()

            // Sounding → Volume
            if let s = Double(st.sounding.replacingOccurrences(of: ",", with: ".")) {
                if let vol = interpolateVolume(trim: trim, levelCm: s, table: tank.tableS) {
                    st.volSoundingResult = String(format: "%.3f", vol)
                } else {
                    st.volSoundingResult = "Out of range"
                }
            } else if !st.sounding.isEmpty {
                st.volSoundingResult = "Invalid"
            } else {
                st.volSoundingResult = "~~~"
            }

            // Ullage → Volume
            if let u = Double(st.ullage.replacingOccurrences(of: ",", with: ".")) {
                if let vol = interpolateVolume(trim: trim, levelCm: u, table: tank.tableU) {
                    st.volUllageResult = String(format: "%.3f", vol)
                } else {
                    st.volUllageResult = "Out of range"
                }
            } else if !st.ullage.isEmpty {
                st.volUllageResult = "Invalid"
            } else {
                st.volUllageResult = "~~~"
            }

            // Volume → Level
            if let targetVol = Double(st.volumeInput.replacingOccurrences(of: ",", with: ".")) {
                if let lvlS = reverseInterpolateLevel(trim: trim, targetVolume: targetVol, table: tank.tableS) {
                    st.resultSoundingLevel = String(format: "%.1f", lvlS)
                } else {
                    st.resultSoundingLevel = tank.tableS == nil ? "No table" : "Out of range"
                }

                if let lvlU = reverseInterpolateLevel(trim: trim, targetVolume: targetVol, table: tank.tableU) {
                    st.resultUllageLevel = String(format: "%.1f", lvlU)
                } else {
                    st.resultUllageLevel = tank.tableU == nil ? "No table" : "Out of range"
                }
            } else if !st.volumeInput.isEmpty {
                st.resultSoundingLevel = "Invalid"
                st.resultUllageLevel = "Invalid"
            } else {
                st.resultSoundingLevel = "~~~"
                st.resultUllageLevel = "~~~"
            }

            states[tank.name] = st
        }
    }
}

// ─────────────────────────────────────────────────────────
// Экран конкретного танка
// ─────────────────────────────────────────────────────────
struct TankDetailView: View {

    let tank: Tank
    @Binding var states: [String: TankRowState]
    @Environment(\.presentationMode) var presentationMode

    private var binding: Binding<TankRowState> {
        Binding<TankRowState>(
            get: { states[tank.name] ?? TankRowState() },
            set: { states[tank.name] = $0 }
        )
    }

    var body: some View {
        Form {
            // ── Sounding ──────────────────────────────
            Section {
                HStack {
                    Image(systemName: "arrow.down.to.line")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("cm", text: binding.sounding)
                        .keyboardType(.decimalPad)
                    if !binding.wrappedValue.sounding.isEmpty {
                        Button {
                            binding.wrappedValue.sounding = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if binding.wrappedValue.volSoundingResult != "~~~" {
                    HStack {
                        Text("Volume")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(binding.wrappedValue.volSoundingResult + " m³")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
            } header: {
                Text("Sounding")
            }

            // ── Ullage ────────────────────────────────
            Section {
                HStack {
                    Image(systemName: "arrow.up.to.line")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("cm", text: binding.ullage)
                        .keyboardType(.decimalPad)
                    if !binding.wrappedValue.ullage.isEmpty {
                        Button {
                            binding.wrappedValue.ullage = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if binding.wrappedValue.volUllageResult != "~~~" {
                    HStack {
                        Text("Volume")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(binding.wrappedValue.volUllageResult + " m³")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
            } header: {
                Text("Ullage")
            }

            // ── Target volume ─────────────────────────
            Section {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    TextField("m³", text: binding.volumeInput)
                        .keyboardType(.decimalPad)
                    if !binding.wrappedValue.volumeInput.isEmpty {
                        Button {
                            binding.wrappedValue.volumeInput = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                HStack {
                    Text("Sounding")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(binding.wrappedValue.resultSoundingLevel == "~~~"
                         ? "—"
                         : binding.wrappedValue.resultSoundingLevel + " cm")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Ullage")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(binding.wrappedValue.resultUllageLevel == "~~~"
                         ? "—"
                         : binding.wrappedValue.resultUllageLevel + " cm")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            } header: {
                Text("Target Volume")
            }

            // ── Info ──────────────────────────────────
            Section {
                HStack {
                    Text("Full volume")
                    Spacer()
                    Text(String(format: "%.3f m³", tank.volFull))
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                HStack {
                    Text("Full height")
                    Spacer()
                    Text(String(format: "%.0f cm", tank.meshFull))
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            } header: {
                Text("Tank Info")
            }
        }
        .navigationTitle(tank.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
