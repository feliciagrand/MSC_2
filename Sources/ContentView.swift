import SwiftUI

struct ContentView: View {

    @State private var trimInput: String = ""
    @State private var states: [String: TankRowState] = [:]
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 8) {

                    HStack {
                        Text("Trim (m):").frame(width: 100, alignment: .leading)
                        TextField("0.0", text: $trimInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 160)
                            .keyboardType(.decimalPad)
                    }

                    Divider()

                    HStack(spacing: 4) {
                        headerCell("Tank", width: 160)
                        headerCell("Sounding (cm)", width: 110)
                        headerCell("Volume S (m³)", width: 120)
                        headerCell("Ullage (cm)", width: 100)
                        headerCell("Volume U (m³)", width: 120)
                        headerCell("Full (m³)", width: 100)
                        headerCell("Input Vol (m³)", width: 120)
                        headerCell("Sound (cm)", width: 100)
                        headerCell("Ullage (cm)", width: 100)
                        headerCell("Full (cm)", width: 90)
                    }

                    ForEach(tanks) { tank in
                        tankRow(tank)
                        if tank.name == "HFO Overflow" {
                            Divider().padding(.vertical, 4)
                        }
                    }

                    Divider().padding(.top, 8)

                    Button(action: calculate) {
                        Text("Calculate")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: 500)

                    VStack(spacing: 2) {
                        Text("Special for M/V 'MSC Turin III'")
                        Text("™Copyright © by NeverwiN. All Rights Reserved 2025")
                        Text("Telegram: +507 6861 3586")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationTitle("Calibration Calculator")
            .navigationBarTitleDisplayMode(.inline)
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
            Alert(title: Text("Warning"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    @ViewBuilder
    private func headerCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(width: width)
    }

    @ViewBuilder
    private func tankRow(_ tank: Tank) -> some View {
        let binding = Binding<TankRowState>(
            get: { states[tank.name] ?? TankRowState() },
            set: { states[tank.name] = $0 }
        )

        HStack(spacing: 4) {
            Text(tank.name)
                .font(.system(size: 12))
                .frame(width: 160, alignment: .leading)

            TextField("cm", text: binding.sounding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 110)

            Text(binding.wrappedValue.volSoundingResult)
                .font(.system(size: 12))
                .frame(width: 120)
                .foregroundColor(.blue)

            TextField("cm", text: binding.ullage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 100)

            Text(binding.wrappedValue.volUllageResult)
                .font(.system(size: 12))
                .frame(width: 120)
                .foregroundColor(.blue)

            Text(String(format: "%.3f", tank.volFull))
                .font(.system(size: 12))
                .foregroundColor(.green)
                .frame(width: 100)

            TextField("m³", text: binding.volumeInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 120)

            Text(binding.wrappedValue.resultSoundingLevel)
                .font(.system(size: 12))
                .frame(width: 100)
                .foregroundColor(.orange)

            Text(binding.wrappedValue.resultUllageLevel)
                .font(.system(size: 12))
                .frame(width: 100)
                .foregroundColor(.orange)

            Text(tank.meshFull > 0 ? String(format: "%.0f", tank.meshFull) : "~~~")
                .font(.system(size: 12))
                .foregroundColor(.green)
                .frame(width: 90)
        }
    }

    private func calculate() {
        guard let trim = Double(trimInput.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Please enter a valid trim value (m)!"
            showAlert = true
            return
        }

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
            alertMessage = "Specify either Sounding or Ullage (not both) for tanks:\n" + conflicts.joined(separator: "\n")
            showAlert = true
            return
        }

        for tank in tanks {
            var st = states[tank.name] ?? TankRowState()

            if let s = Double(st.sounding.replacingOccurrences(of: ",", with: ".")) {
                if let vol = interpolateVolume(trim: trim, levelCm: s, table: tank.tableS) {
                    st.volSoundingResult = String(format: "%.3f", vol)
                } else {
                    st.volSoundingResult = "Out of range"
                }
            } else if !st.sounding.isEmpty {
                st.volSoundingResult = "Invalid input"
            } else {
                st.volSoundingResult = "~~~"
            }

            if let u = Double(st.ullage.replacingOccurrences(of: ",", with: ".")) {
                if let vol = interpolateVolume(trim: trim, levelCm: u, table: tank.tableU) {
                    st.volUllageResult = String(format: "%.3f", vol)
                } else {
                    st.volUllageResult = "Out of range"
                }
            } else if !st.ullage.isEmpty {
                st.volUllageResult = "Invalid input"
            } else {
                st.volUllageResult = "~~~"
            }

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
