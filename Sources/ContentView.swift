import SwiftUI

struct ContentView: View {

    @State private var trimInput: String = ""
    @State private var states: [String: TankRowState] = [:]
    @State private var showResetConfirm = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // ───────── ЗАКРЕПЛЁННАЯ ШАПКА ─────────
                VStack(spacing: 8) {

                    ZStack {
                        Text("MSC Yashi B")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        HStack {
                            Spacer()
                            Button {
                                showResetConfirm = true
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .accessibilityLabel("Reset")
                        }
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.blue)
                            .font(.subheadline)

                        Text("TRIM")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("0.0", text: $trimInput)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.center)
                            .frame(width: 90)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(8)
                            .onChange(of: trimInput) { _ in recalculateAll() }

                        Text("m")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(Color(.systemBackground))
                .overlay(
                    Divider(), alignment: .bottom
                )

                // ───────── КОНТЕНТ ─────────
                ScrollView {
                    VStack(spacing: 16) {

                        ForEach(tanks) { tank in
                            tankCard(tank)
                        }

                        VStack(spacing: 2) {
                            Text("Special for M/V 'MSC Yashi B'")
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
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            if states.isEmpty {
                for tank in tanks {
                    states[tank.name] = TankRowState()
                }
            }
        }
        .alert("Reset all values?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation {
                    trimInput = ""
                    for tank in tanks {
                        states[tank.name] = TankRowState()
                    }
                }
            }
        }
    }

    // MARK: - Карточка танка

    @ViewBuilder
    private func tankCard(_ tank: Tank) -> some View {
        let binding = Binding<TankRowState>(
            get: { states[tank.name] ?? TankRowState() },
            set: { states[tank.name] = $0 }
        )

        VStack(alignment: .leading, spacing: 12) {

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

            // Sounding → m³
            rowBlock(
                title: "Sounding",
                unit: "cm",
                inputPlaceholder: "cm",
                text: binding.sounding,
                result: binding.wrappedValue.volSoundingResult,
                resultUnit: "m³",
                accent: .blue
            )

            // Процент заполнения (только для Alkali / Sludge / Hold)
            if showsPercent(for: tank) {
                percentBlock(percent: binding.wrappedValue.percentSounding)
            }

            // Ullage → m³
            rowBlock(
                title: "Ullage",
                unit: "cm",
                inputPlaceholder: "cm",
                text: binding.ullage,
                result: binding.wrappedValue.volUllageResult,
                resultUnit: "m³",
                accent: .blue
            )

            // Target Volume
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
                HStack {
                    TextField(inputPlaceholder, text: text)
                        .keyboardType(.numbersAndPunctuation)
                        .onChange(of: text.wrappedValue) { _ in recalculateAll() }
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(8)

                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)

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

    // MARK: - Блок процента

    @ViewBuilder
    private func percentBlock(percent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PERCENT FULL")
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.caption)
                    .foregroundColor(.purple)

                Text(percent)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.10))
            .cornerRadius(8)
        }
    }

    // MARK: - Блок Target Volume

    @ViewBuilder
    private func targetBlock(binding: Binding<TankRowState>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TARGET VOLUME")
                .font(.caption2)
                .foregroundColor(.secondary)

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
        if tank.name.contains("MGO") || tank.name.contains("M.G.O") { return "drop.fill" }
        if tank.name.contains("Alkali") { return "drop.triangle.fill" }
        if tank.name.contains("Sludge") { return "trash.fill" }
        if tank.name.contains("Hold") { return "shippingbox.fill" }
        if tank.name.contains("BILGE") { return "drop.fill" }
        if tank.name.contains("OVERFLOW") { return "exclamationmark.triangle.fill" }
        return "fuelpump.fill"
    }

    private func iconColor(for tank: Tank) -> Color {
        if tank.name.contains("M.G.O") || tank.name.contains("MGO") { return .green }
        if tank.name.contains("Alkali") { return .purple }
        if tank.name.contains("Sludge") { return .brown }
        if tank.name.contains("Hold") { return .indigo }
        if tank.name.contains("OVERFLOW") { return .orange }
        return .blue
    }

    // Какие танки показывают процент
    private func showsPercent(for tank: Tank) -> Bool {
        let names: Set<String> = ["Alkali", "Sludge", "Hold (P)", "Hold (S)"]
        return names.contains(tank.name)
    }

    // MARK: - Автоматический пересчёт

    private func recalculateAll() {
        guard let trim = Double(trimInput.replacingOccurrences(of: ",", with: ".")) else {
            for tank in tanks {
                var st = states[tank.name] ?? TankRowState()
                st.volSoundingResult = "~~~"
                st.volUllageResult = "~~~"
                st.percentSounding = "~~~"
                st.resultSoundingLevel = "~~~"
                st.resultUllageLevel = "~~~"
                states[tank.name] = st
            }
            return
        }

        for tank in tanks {
            var st = states[tank.name] ?? TankRowState()

            // Sounding → Volume + %
            if let s = Double(st.sounding.replacingOccurrences(of: ",", with: ".")) {
                if let vol = interpolateVolume(trim: trim, levelCm: s, table: tank.tableS) {
                    st.volSoundingResult = String(format: "%.3f", vol)
                    if tank.volFull > 0 {
                        let pct = (vol / tank.volFull) * 100.0
                        st.percentSounding = String(format: "%.2f%%", pct)
                    } else {
                        st.percentSounding = "—"
                    }
                } else {
                    st.volSoundingResult = tank.tableS == nil ? "—" : "Out of range"
                    st.percentSounding = "—"
                }
            } else if !st.sounding.isEmpty {
                st.volSoundingResult = "Invalid"
                st.percentSounding = "Invalid"
            } else {
                st.volSoundingResult = "~~~"
                st.percentSounding = "~~~"
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

            // Volume → Level
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
