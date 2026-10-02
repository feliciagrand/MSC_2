import SwiftUI

struct ContentView: View {

    @State private var trimInput: String = ""
    @State private var states: [String: TankRowState] = [:]

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {

                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // ── Trim ─────────────────────────────
                        trimCard

                        // ── Tanks ────────────────────────────
                        ForEach(tanks) { tank in
                            tankCard(tank)
                        }

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
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("MSC Turin III")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            trimInput = ""
                            for tank in tanks {
                                states[tank.name] = TankRowState()
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
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
    }

    // MARK: - Trim card

    @ViewBuilder
    private var trimCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TRIM")
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.blue)
                    .font(.title3)

                TextField("0.0", text: $trimInput)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .onChange(of: trimInput) { _ in recalculateAll() }

                Text("m")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
        }
    }

    // MARK: - Tank card

    @ViewBuilder
    private func tankCard(_ tank: Tank) -> some View {
        let binding = Binding<TankRowState>(
            get: { states[tank.name] ?? TankRowState() },
            set: { states[tank.name] = $0 }
        )

        VStack(alignment: .leading, spacing: 12) {

            // Название танка + полный объём
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(iconColor(for: tank).opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: iconName(for: tank))
                        .foregroundColor(iconColor(for: tank))
                        .font(.system(size: 14, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(tank.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(String(format: "Full: %.3f m³ · %.0f cm", tank.volFull, tank.meshFull))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // ── Sounding ──────────────────────────────
            rowBlock(
                title: "Sounding",
                unit: "cm",
                inputPlaceholder: "cm",
                text: binding.sounding,
                result: binding.wrappedValue.volSoundingResult,
                resultUnit: "m³",
                accent: .blue
            )

            // ── Ullage ────────────────────────────────
            rowBlock(
                title: "Ullage",
                unit: "cm",
                inputPlaceholder: "cm",
                text: binding.ullage,
                result: binding.wrappedValue.volUllageResult,
                resultUnit: "m³",
                accent: .blue
            )

            // ── Target Volume ─────────────────────────
            targetBlock(binding: binding)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Блок Sounding / Ullage

    @ViewBuilder
    private func rowBlock(
        title: String,
        unit: String,
        inputPlaceholder: String,
        text: Binding<String>,
        result: String,
        resultUnit: String,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                // Ввод
                HStack {
                    TextField(inputPlaceholder, text: text)
                        .keyboardType(.decimalPad)
                        .onChange(of: text.wrappedValue) { _ in recalculateAll() }
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(8)

                // Стрелка
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                // Результат
                HStack {
                    Text(result)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Text(resultUnit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(accent.opacity(0.10))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Блок Target Volume

    @ViewBuilder
    private func targetBlock(binding: Binding<TankRowState>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TARGET VOLUME")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Ввод объёма
            HStack {
                TextField("m³", text: binding.volumeInput)
                    .keyboardType(.decimalPad)
                    .font(.system(.body, design: .rounded))
                    .onChange(of: binding.wrappedValue.volumeInput) { _ in recalculateAll() }
                Text("m³")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(8)

            // Результат — Sounding
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.to.line")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 16)
                Text("Sounding")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text(binding.wrappedValue.resultSoundingLevel)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("cm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(8)

            // Результат — Ullage
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.to.line")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 16)
                Text("Ullage")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text(binding.wrappedValue.resultUllageLevel)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("cm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(8)
        }
    }

    // MARK: - Иконки

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

    // MARK: - Автоматический пересчёт

    private func recalculateAll() {
        guard let trim = Double(trimInput.replacingOccurrences(of: ",", with: ".")) else {
            // Нет валидного trim — очищаем результаты
            for tank in tanks {
                var st = states[tank.name] ?? TankRowState()
                st.volSoundingResult = "~~~"
                st.volUllageResult = "~~~"
                st.resultSoundingLevel = "~~~"
                st.resultUllageLevel = "~~~"
                states[tank.name] = st
            }
            return
        }

        for tank in tanks {
            var st = states[tank.name] ?? TankRowState()

            // Sounding → Volume
            if let s = Double(st.sounding.replacingOccurrences(of: ",", with: ".")) {
                if let vol = interpolateVolume(trim: trim, levelCm: s, table: tank.tableS) {
                    st.volSoundingResult = String(format: "%.3f", vol)
                } else {
                    st.volSoundingResult = tank.tableS == nil ? "—" : "Out of range"
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
                    st.volUllageResult = tank.tableU == nil ? "—" : "Out of range"
                }
            } else if !st.ullage.isEmpty {
                st.volUllageResult = "Invalid"
            } else {
                st.volUllageResult = "~~~"
            }

            // Volume → Level (обратный пересчёт)
            if let targetVol = Double(st.volumeInput.replacingOccurrences(of: ",", with: ".")) {
                if let lvlS = reverseInterpolateLevel(trim: trim, targetVolume: targetVol, table: tank.tableS) {
                    st.resultSoundingLevel = String(format: "%.1f", lvlS)
                } else {
                    st.resultSoundingLevel = "—"
                }

                if let lvlU = reverseInterpolateLevel(trim: trim, targetVolume: targetVol, table: tank.tableU) {
                    st.resultUllageLevel = String(format: "%.1f", lvlU)
                } else {
                    st.resultUllageLevel = "—"
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
