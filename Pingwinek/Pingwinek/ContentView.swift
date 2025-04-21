import SwiftUI

struct Medication: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var dosePerKg: Double
    var unit: String = "ml/kg"
    var timesPerDay: Int
    var hoursInterval: Int
}

struct DoseCalculation: Identifiable {
    var id = UUID()
    var medicationName: String
    var weight: Double
    var weightUnit: String
    var calculatedDose: String
    var timesPerDay: Int
    var hoursInterval: Int
    var timestamp: Date
    
    // Funkcja do obliczania czasu następnej dawki
    func nextDoseTime() -> Date {
        return Calendar.current.date(byAdding: .hour, value: hoursInterval, to: timestamp) ?? timestamp
    }
    
    // Funkcja do obliczania wszystkich dawek na dziś
    func dailySchedule() -> [Date] {
        var schedule: [Date] = []
        let currentDate = timestamp
        
        // Dodaj pierwszą dawkę (teraz)
        schedule.append(currentDate)
        
        // Dodaj kolejne dawki w odstępach co hoursInterval godzin
        for i in 1..<timesPerDay {
            if let nextTime = Calendar.current.date(byAdding: .hour, value: i * hoursInterval, to: currentDate) {
                schedule.append(nextTime)
            }
        }
        
        return schedule
    }
}

class CalculatorModel: ObservableObject {
    @Published var medications: [Medication] = [
        Medication(name: "Paracetamol 100mg/5ml", dosePerKg: 0.375, timesPerDay: 4, hoursInterval: 6),
        Medication(name: "Paracetamol 200mg/5ml", dosePerKg: 0.375, timesPerDay: 4, hoursInterval: 6),
        Medication(name: "Ibuprofen 200mg/5ml", dosePerKg: 10.0, timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibuprofen 100mg/5ml", dosePerKg: 10.0, timesPerDay: 3, hoursInterval: 8)
    ]
    
    @Published var selectedMedicationIndex: Int?
    @Published var weight: String = ""
    @Published var selectedUnit: WeightUnit = .kg
    @Published var calculatedDose: String = ""
    @Published var history: [DoseCalculation] = []
    @Published var showSchedule: Bool = false
    @Published var currentCalculation: DoseCalculation?
    
    enum WeightUnit: String, CaseIterable, Identifiable {
        case kg = "kg"
        case lb = "lb"
        
        var id: String { self.rawValue }
    }
    
    var selectedMedication: Medication? {
        guard let index = selectedMedicationIndex, index >= 0, index < medications.count else {
            return nil
        }
        return medications[index]
    }
    
    func calculateDose() {
        guard let medication = selectedMedication else {
            calculatedDose = "Proszę wybrać lek"
            return
        }
        
        guard let weightValue = Double(weight), weightValue > 0 else {
            calculatedDose = "Proszę wprowadzić prawidłową wagę"
            return
        }
        
        // Konwersja wagi na kg jeśli potrzeba
        let weightInKg = selectedUnit == .lb ? weightValue * 0.45359237 : weightValue
        
        // Obliczenie dawki
        let dose = weightInKg * medication.dosePerKg
        
        // Formatowanie wyniku
        calculatedDose = String(format: "%@ %.2f ml", medication.name, dose)
        
        // Utwórz nowe obliczenie
        let calculation = DoseCalculation(
            medicationName: medication.name,
            weight: weightValue,
            weightUnit: selectedUnit.rawValue,
            calculatedDose: String(format: "%.2f mg", dose),
            timesPerDay: medication.timesPerDay,
            hoursInterval: medication.hoursInterval,
            timestamp: Date()
        )
        
        // Ustaw bieżące obliczenie
        currentCalculation = calculation
        
        // Dodanie do historii
        history.insert(calculation, at: 0)
        
        // Pokaż harmonogram
        showSchedule = true
    }
}

struct ContentView: View {
    @StateObject private var model = CalculatorModel()
    @State private var showingAddMedication = false
    @State private var newMedicationName = ""
    @State private var newMedicationDose = ""
    @State private var newMedicationTimesPerDay = 3
    @State private var newMedicationHoursInterval = 8
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Wybór leku")) {
                    NavigationLink(destination: MedicationSelectionView(model: model)) {
                        if let med = model.selectedMedication {
                            Text(med.name)
                        } else {
                            Text("Wybierz lek")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let selectedMed = model.selectedMedication {
                        HStack {
                            Text("maksymalna dawka:")
                            Spacer()
                            Text("\(selectedMed.dosePerKg, specifier: "%.2f") \(selectedMed.unit)")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Ilość dawek na dobę:")
                            Spacer()
                            Text("\(selectedMed.timesPerDay)")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Co ile godzin:")
                            Spacer()
                            Text("\(selectedMed.hoursInterval) h")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Informacje o pacjencie")) {
                    HStack {
                        TextField("Waga", text: $model.weight)
                            .keyboardType(.decimalPad)
                        
                        Picker("Jednostka", selection: $model.selectedUnit) {
                            ForEach(CalculatorModel.WeightUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 100)
                    }
                }
                
                Section {
                    Button(action: {
                        model.calculateDose()
                        hideKeyboard()
                    }) {
                        Text("Oblicz dawkę")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if !model.calculatedDose.isEmpty {
                    Section(header: Text("Zalecana dawka")) {
                        Text(model.calculatedDose)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                        if let med = model.selectedMedication {
                            Text("\(med.timesPerDay) x dziennie, co \(med.hoursInterval) godzin")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.secondary)
                        }
                        
                        if let calculation = model.currentCalculation {
                            VStack(spacing: 10) {
                                Text("Harmonogram dawkowania:")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                ForEach(calculation.dailySchedule(), id: \.self) { time in
                                    HStack {
                                        Text(formatTime(time))
                                            .foregroundColor(.primary)
                                        
                                        if time == calculation.timestamp {
                                            Text("(teraz)")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                if !model.history.isEmpty {
                    Section(header: Text("Historia obliczeń")) {
                        ForEach(model.history) { calculation in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(calculation.medicationName)
                                    .font(.headline)
                                
                                HStack {
                                    Text("\(calculation.weight, specifier: "%.1f") \(calculation.weightUnit)")
                                    Spacer()
                                    Text(calculation.calculatedDose)
                                }
                                
                                Text("\(calculation.timesPerDay) x dziennie, co \(calculation.hoursInterval) godzin")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(formatDate(calculation.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("Następna dawka: \(formatTime(calculation.nextDoseTime()))")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Kalkulator dawek")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddMedication = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                addMedicationView
            }
        }
    }
    
    var addMedicationView: some View {
        NavigationView {
            Form {
                Section(header: Text("Nowy lek")) {
                    TextField("Nazwa leku", text: $newMedicationName)
                    
                    HStack {
                        TextField("Dawka na kg", text: $newMedicationDose)
                            .keyboardType(.decimalPad)
                        Text("mg/kg")
                    }
                }
                
                Section(header: Text("Dawkowanie")) {
                    Stepper(value: $newMedicationTimesPerDay, in: 1...12) {
                        HStack {
                            Text("Ilość dawek na dobę:")
                            Spacer()
                            Text("\(newMedicationTimesPerDay)")
                        }
                    }
                    
                    Stepper(value: $newMedicationHoursInterval, in: 1...24) {
                        HStack {
                            Text("Co ile godzin:")
                            Spacer()
                            Text("\(newMedicationHoursInterval) h")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        if let dose = Double(newMedicationDose), !newMedicationName.isEmpty {
                            model.medications.append(Medication(name: newMedicationName,
                                                             dosePerKg: dose,
                                                             timesPerDay: newMedicationTimesPerDay,
                                                             hoursInterval: newMedicationHoursInterval))
                            newMedicationName = ""
                            newMedicationDose = ""
                            showingAddMedication = false
                        }
                    }) {
                        Text("Dodaj lek")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(newMedicationName.isEmpty || newMedicationDose.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(newMedicationName.isEmpty || newMedicationDose.isEmpty)
                }
            }
            .navigationTitle("Dodaj lek")
            .navigationBarItems(trailing: Button("Anuluj") {
                showingAddMedication = false
            })
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct MedicationSelectionView: View {
    @ObservedObject var model: CalculatorModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(Array(model.medications.enumerated()), id: \.element.id) { index, medication in
                Button(action: {
                    model.selectedMedicationIndex = index
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(medication.name)
                            Text("\(medication.dosePerKg, specifier: "%.2f") \(medication.unit), \(medication.timesPerDay)x/dzień")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if model.selectedMedicationIndex == index {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Wybierz lek")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
