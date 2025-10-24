import SwiftUI
import Charts
import UIKit

// MARK: - MODELE

struct Medication: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var dosePerKg: Double
    var unit: String = "ml/kg"
    var timesPerDay: Int
    var hoursInterval: Int
}

struct DoseCalculation: Identifiable, Codable {
    var id = UUID()
    var medicationName: String
    var weight: Double
    var weightUnit: String
    var calculatedDose: String
    var timesPerDay: Int
    var hoursInterval: Int
    var timestamp: Date
    var temperature: Double?
    var tempUnit: String?
    var childId: UUID?
    
    // Harmonogram
    func nextDoseTime() -> Date {
        Calendar.current.date(byAdding: .hour, value: hoursInterval, to: timestamp) ?? timestamp
    }
    func dailySchedule() -> [Date] {
        var schedule: [Date] = [timestamp]
        for i in 1..<timesPerDay {
            if let nextTime = Calendar.current.date(byAdding: .hour, value: i * hoursInterval, to: timestamp) {
                schedule.append(nextTime)
            }
        }
        return schedule
    }
}

struct ChildProfile: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var birthDate: Date
    var weightKg: Double
}

struct TemperatureEntry: Identifiable, Codable {
    var id = UUID()
    var childId: UUID
    var date: Date
    var valueC: Double
}

// MARK: - MODEL

final class CalculatorModel: ObservableObject {
    // Pełna lista leków (Twoja)
    @Published var medications: [Medication] = [
        Medication(name: "APAP dla dzieci FORTE (200mg/5ml)",  dosePerKg: 0.375,  timesPerDay: 4, hoursInterval: 6),   // 15/40
        Medication(name: "Calpol (120mg/5ml)",                  dosePerKg: 0.625,  timesPerDay: 4, hoursInterval: 6),   // 15/24
        Medication(name: "Calpol 6 Plus (250mg/5ml)",           dosePerKg: 0.300,  timesPerDay: 4, hoursInterval: 6),   // 15/50
        Medication(name: "Panadol dla dzieci (120mg/5ml)",      dosePerKg: 0.625,  timesPerDay: 4, hoursInterval: 6),   // 15/24
        Medication(name: "Paracetamol Aflofarm (120mg/5ml)",    dosePerKg: 0.625,  timesPerDay: 4, hoursInterval: 6),   // 15/24
        Medication(name: "Paracetamol Galena (120mg/5ml)",      dosePerKg: 0.625,  timesPerDay: 4, hoursInterval: 6),   // 15/24
        Medication(name: "Paracetamol Hasco (120mg/5ml)",       dosePerKg: 0.625,  timesPerDay: 4, hoursInterval: 6),   // 15/24
        Medication(name: "Paracetamol Hasco FORTE (240mg/5ml)", dosePerKg: 0.3125, timesPerDay: 4, hoursInterval: 6),   // 15/48
        Medication(name: "Pedicetamol (100mg/ml)",              dosePerKg: 0.150,  timesPerDay: 4, hoursInterval: 6),   // 15/100
        Medication(name: "Infacetamol (100mg/ml)",              dosePerKg: 0.150,  timesPerDay: 4, hoursInterval: 6),   // 15/100

        // --- IBUPROFEN 100 mg/5 ml (20 mg/ml) → 10/20 = 0.50 ml/kg ---
        Medication(name: "Babyfen (100mg/5ml)",                 dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Brufen (100mg/5ml)",                  dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Bufenik (100mg/5ml)",                 dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibum (100mg/5ml)",                    dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibufen dla dzieci (100mg/5ml)",       dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibunid dla dzieci (100mg/5ml)",       dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibuprom dla Dzieci (100mg/5ml)",      dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Kidofen (100mg/5ml)",                 dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "MIG dla dzieci (100mg/5ml)",          dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Milifen (100mg/5ml)",                 dosePerKg: 0.5,    timesPerDay: 3, hoursInterval: 8),

        // --- IBUPROFEN 200 mg/5 ml (40 mg/ml) → 10/40 = 0.25 ml/kg ---
        Medication(name: "Axoprofen Forte (200mg/5ml)",         dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Brufen Forte (200mg/5ml)",            dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Bufenik Forte (200mg/5ml)",           dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibum Forte (200mg/5ml)",              dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibum Forte Pure (200mg/5ml)",         dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibufen dla dzieci Forte (200mg/5ml)", dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibunid dla dzieci Forte (200mg/5ml)", dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibuprom dla Dzieci Forte (200mg/5ml)",dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Ibutact (200mg/5ml)",                 dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "MIG dla dzieci Forte (200mg/5ml)",    dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Nurofen dla dzieci Forte (200mg/5ml)",dosePerKg: 0.25,   timesPerDay: 3, hoursInterval: 8),
        Medication(name: "Nurofen dla dzieci JUNIOR (200mg/5ml)",dosePerKg: 0.25,  timesPerDay: 3, hoursInterval: 8),
    ]
    
    // Dane kalkulatora
    @Published var selectedMedicationIndex: Int?
    @Published var weight: String = ""
    @Published var selectedUnit: WeightUnit = .kg
    @Published var calculatedDose: String = ""
    @Published var temperature: String = ""
    @Published var temperatureUnit: String = "°C"
    @Published var showSchedule: Bool = false
    @Published var currentCalculation: DoseCalculation?
    
    // Dzieci + wybór
    @Published var children: [ChildProfile] = [] { didSet { saveChildren() } }
    @Published var selectedChildIndex: Int?
    
    // Historia + temperatury (utrwalane)
    @Published var history: [DoseCalculation] = [] { didSet { saveHistory() } }
    @Published var temperatures: [TemperatureEntry] = [] { didSet { saveTemperatures() } }
    
    enum WeightUnit: String, CaseIterable, Identifiable { case kg = "kg"; case lb = "lb"; var id: String { rawValue } }
    
    // Persistence
    private let historyKey = "dose_history_v1"
    private let childrenKey = "children_v1"
    private let tempsKey = "temps_v1"
    private var isLoading = false
    
    init() {
        isLoading = true
        loadChildren()
        loadHistory()
        loadTemperatures()
        isLoading = false
        // ⬇️ Sortuj leki alfabetycznie przy starcie
        sortMedications()
    }
    
    // ⬇️ Sortowanie leków po nazwie (z zachowaniem wyboru)
    func sortMedications(preserveSelection: Bool = true) {
        let selectedId = selectedMedicationIndex.flatMap { idx in
            medications.indices.contains(idx) ? medications[idx].id : nil
        }
        medications.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        if preserveSelection, let id = selectedId {
            selectedMedicationIndex = medications.firstIndex(where: { $0.id == id })
        }
    }
    
    var selectedMedication: Medication? {
        guard let index = selectedMedicationIndex, medications.indices.contains(index) else { return nil }
        return medications[index]
    }
    
    var currentChildHistory: [DoseCalculation] {
        guard let idx = selectedChildIndex, children.indices.contains(idx) else { return history }
        let id = children[idx].id
        return history.filter { $0.childId == id }
    }
    
    func calculateDose() {
        guard let medication = selectedMedication else { calculatedDose = "Proszę wybrać lek"; return }
        
        // Preferuj wagę z profilu dziecka
        if let i = selectedChildIndex, children.indices.contains(i) {
            applyCalculation(with: medication, effectiveWeightKg: children[i].weightKg)
            return
        }
        
        // Inaczej – z pola „Waga”
        guard let weightValue = Double(weight), weightValue > 0 else {
            calculatedDose = "Proszę wprowadzić prawidłową wagę"
            return
        }
        let weightInKg = selectedUnit == .lb ? weightValue * 0.45359237 : weightValue
        applyCalculation(with: medication, effectiveWeightKg: weightInKg)
    }
    
    private func applyCalculation(with medication: Medication, effectiveWeightKg: Double) {
        let dose = effectiveWeightKg * medication.dosePerKg
        calculatedDose = String(format: "%@ %.2f ml", medication.name, dose)
        
        let childId = (selectedChildIndex != nil && children.indices.contains(selectedChildIndex!)) ? children[selectedChildIndex!].id : nil
        
        let calc = DoseCalculation(
            medicationName: medication.name,
            weight: effectiveWeightKg,
            weightUnit: "kg",
            calculatedDose: String(format: "%.2f ml", dose),
            timesPerDay: medication.timesPerDay,
            hoursInterval: medication.hoursInterval,
            timestamp: Date(),
            temperature: Double(temperature),
            tempUnit: "°C",
            childId: childId
        )
        
        currentCalculation = calc
        history.insert(calc, at: 0)
        showSchedule = true
        
        // zapis temperatury dla dziecka (jeśli podano)
        if let t = Double(temperature), let id = childId {
            temperatures.append(TemperatureEntry(childId: id, date: Date(), valueC: t))
        }
    }
    
    // MARK: - Persistence
    private func saveHistory() {
        guard !isLoading else { return }
        do { let data = try JSONEncoder().encode(history); UserDefaults.standard.set(data, forKey: historyKey) }
        catch { print("❌ saveHistory:", error) }
    }
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        do { history = try JSONDecoder().decode([DoseCalculation].self, from: data) }
        catch { print("❌ loadHistory:", error) }
    }
    
    func clearHistory(for childId: UUID? = nil) {
        if let id = childId { history.removeAll { $0.childId == id } }
        else { history.removeAll() }
        saveHistory()
    }
    
    private func saveChildren() {
        guard !isLoading else { return }
        do { let data = try JSONEncoder().encode(children); UserDefaults.standard.set(data, forKey: childrenKey) }
        catch { print("❌ saveChildren:", error) }
    }
    private func loadChildren() {
        guard let data = UserDefaults.standard.data(forKey: childrenKey) else { return }
        do { children = try JSONDecoder().decode([ChildProfile].self, from: data) }
        catch { print("❌ loadChildren:", error) }
    }
    
    private func saveTemperatures() {
        guard !isLoading else { return }
        do { let data = try JSONEncoder().encode(temperatures); UserDefaults.standard.set(data, forKey: tempsKey) }
        catch { print("❌ saveTemperatures:", error) }
    }
    private func loadTemperatures() {
        guard let data = UserDefaults.standard.data(forKey: tempsKey) else { return }
        do { temperatures = try JSONDecoder().decode([TemperatureEntry].self, from: data) }
        catch { print("❌ loadTemperatures:", error) }
    }
    
    func tempsForCurrentChild() -> [TemperatureEntry] {
        guard let idx = selectedChildIndex, children.indices.contains(idx) else { return [] }
        let id = children[idx].id
        return temperatures
            .filter { $0.childId == id }
            .sorted { $0.date < $1.date }
    }
}

// MARK: - HELPERS (global)

func hideKeyboard() {
#if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
}
func formatDate(_ date: Date) -> String {
    let df = DateFormatter(); df.dateStyle = .short; df.timeStyle = .short
    return df.string(from: date)
}
func formatTime(_ date: Date) -> String {
    let df = DateFormatter(); df.dateFormat = "HH:mm"
    return df.string(from: date)
}

// PDF eksport wykresu (A4)
func exportTemperaturePDF(entries: [TemperatureEntry], title: String) -> URL? {
    let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 @72dpi
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("temperatura-\(UUID().uuidString.prefix(6)).pdf")
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
    do {
        try renderer.writePDF(to: url) { ctx in
            ctx.beginPage()
            
            // Tytuł
            let p = NSMutableParagraphStyle(); p.alignment = .center
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18), .paragraphStyle: p]
            (title as NSString).draw(in: CGRect(x: 40, y: 30, width: pageRect.width-80, height: 24), withAttributes: titleAttrs)
            
            // Ramka wykresu
            let plot = CGRect(x: 40, y: 80, width: pageRect.width-80, height: 600)
            UIColor.black.setStroke(); UIBezierPath(rect: plot).stroke()
            
            guard !entries.isEmpty else { return }
            let minT = (entries.map{$0.valueC}.min() ?? 35.0) - 0.2
            let maxT = (entries.map{$0.valueC}.max() ?? 40.0) + 0.2
            let times = entries.map{ $0.date.timeIntervalSince1970 }
            let minX = times.min() ?? Date().timeIntervalSince1970
            let maxX = times.max() ?? (minX + 1)
            
            func point(_ e: TemperatureEntry) -> CGPoint {
                let xr = CGFloat((e.date.timeIntervalSince1970 - minX) / (maxX - minX))
                let yr = CGFloat((e.valueC - minT) / (maxT - minT))
                return CGPoint(x: plot.minX + xr * plot.width, y: plot.maxY - yr * plot.height)
            }
            
            // Linia
            let path = UIBezierPath(); path.lineWidth = 1.5
            for (i, e) in entries.enumerated() {
                let pt = point(e)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            UIColor.systemBlue.setStroke(); path.stroke()
            
            // Punkty
            for e in entries {
                let pt = point(e)
                let dot = UIBezierPath(ovalIn: CGRect(x: pt.x-2.5, y: pt.y-2.5, width: 5, height: 5))
                UIColor.systemBlue.setFill(); dot.fill()
            }
            
            // Podpis osi
            let sub = NSMutableParagraphStyle(); sub.alignment = .left
            let subAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .paragraphStyle: sub]
            ("Temperatura (°C)" as NSString).draw(in: CGRect(x: 40, y: 50, width: 200, height: 20), withAttributes: subAttrs)
        }
        return url
    } catch {
        print("❌ PDF error: \(error)")
        return nil
    }
}

// MARK: - GŁÓWNY WIDOK

struct ContentView: View {
    @StateObject private var model = CalculatorModel()
    
    // Disclaimer
    @AppStorage("disclaimerAccepted") private var disclaimerAccepted = false
    @State private var showDisclaimer = false
    
    // Dodawanie leków
    @State private var showingAddMedication = false
    @State private var newMedicationName = ""
    @State private var newMedicationDose = ""
    @State private var newMedicationTimesPerDay = 3
    @State private var newMedicationHoursInterval = 8
    
    // Eksport PDF (share)
    @State private var lastPDFURL: URL?
    @State private var showShare = false
    
    var body: some View {
        NavigationView {
            Form {
                // Dziecko
                Section(header: Text("Dziecko")) {
                    NavigationLink(destination: ChildrenView(model: model)) {
                        if let i = model.selectedChildIndex, model.children.indices.contains(i) {
                            let ch = model.children[i]
                            Text("\(ch.name) • \(String(format: "%.1f", ch.weightKg)) kg")
                        } else {
                            Text("Wybierz dziecko").foregroundColor(.gray)
                        }
                    }
                    Button("Użyj wagi dziecka") {
                        if let i = model.selectedChildIndex, model.children.indices.contains(i) {
                            model.weight = String(format: "%.1f", model.children[i].weightKg)
                            model.selectedUnit = .kg
                        }
                    }
                    .disabled(!(model.selectedChildIndex != nil && model.children.indices.contains(model.selectedChildIndex!)))
                }
                
                // Wybór leku
                Section(header: Text("Wybór leku")) {
                    NavigationLink(destination: MedicationSelectionView(model: model)) {
                        if let med = model.selectedMedication {
                            Text(med.name)
                        } else {
                            Text("Wybierz lek").foregroundColor(.gray)
                        }
                    }
                    if let selectedMed = model.selectedMedication {
                        HStack { Text("maksymalna dawka:"); Spacer(); Text("\(selectedMed.dosePerKg, specifier: "%.2f") \(selectedMed.unit)").foregroundColor(.gray) }
                        HStack { Text("Ilość dawek na dobę:"); Spacer(); Text("\(selectedMed.timesPerDay)").foregroundColor(.gray) }
                        HStack { Text("Co ile godzin:"); Spacer(); Text("\(selectedMed.hoursInterval) h)").foregroundColor(.gray) }
                    }
                }
                
                // Informacje o pacjencie
                Section(header: Text("Informacje o pacjencie")) {
                    HStack {
                        TextField("Waga", text: $model.weight).keyboardType(.decimalPad)
                        Picker("Jednostka", selection: $model.selectedUnit) {
                            ForEach(CalculatorModel.WeightUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 110)
                    }
                    TextField("Temperatura (°C)", text: $model.temperature).keyboardType(.decimalPad)
                }
                
                // Akcja
                Section {
                    Button {
                        guard disclaimerAccepted else {
                            showDisclaimer = true
                            return
                        }
                        model.calculateDose()
                        hideKeyboard()
                    } label: {
                        Text("Oblicz dawkę")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                
                // Wynik + harmonogram
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
                                if let t = calculation.temperature {
                                    Text(String(format: "Temperatura: %.1f °C", t))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                Text("Harmonogram dawkowania:")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                ForEach(calculation.dailySchedule(), id: \.self) { time in
                                    HStack {
                                        Text(formatTime(time)).foregroundColor(.primary)
                                        if time == calculation.timestamp {
                                            Text("(teraz)").foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                // Historia (per dziecko)
                if !model.currentChildHistory.isEmpty {
                    Section(header: Text("Historia obliczeń")) {
                        ForEach(model.currentChildHistory) { calculation in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(calculation.medicationName).font(.headline)
                                HStack {
                                    Text("\(calculation.weight, specifier: "%.1f") \(calculation.weightUnit)")
                                    Spacer()
                                    Text(calculation.calculatedDose)
                                }
                                if let t = calculation.temperature {
                                    Text(String(format: "Temp: %.1f °C", t))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text("\(calculation.timesPerDay) x dziennie, co \(calculation.hoursInterval) godzin")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(formatDate(calculation.timestamp)).font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("Następna dawka: \(formatTime(calculation.nextDoseTime()))")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        Button(role: .destructive) {
                            if let i = model.selectedChildIndex, model.children.indices.contains(i) {
                                model.clearHistory(for: model.children[i].id)
                            } else { model.clearHistory() }
                        } label: { Text("Wyczyść historię") }
                    }
                }
                
                // 🔻 OSTATNIA SEKCJA – WYKRES TEMPERATURY + PDF
                Section(header: Text("Temperatura – wykres")) {
                    let entries = model.tempsForCurrentChild()
                    if entries.isEmpty {
                        Text("Brak danych temperatury.")
                            .foregroundColor(.secondary)
                    } else {
                        Chart(entries) { e in
                            LineMark(x: .value("Data", e.date), y: .value("°C", e.valueC))
                            PointMark(x: .value("Data", e.date), y: .value("°C", e.valueC))
                        }
                        .frame(height: 220)
                        .padding(.vertical, 4)
                        
                        Button("Eksportuj wykres do PDF") {
                            if let url = exportTemperaturePDF(entries: entries,
                                                              title: "Temperatura – \(currentChildName())") {
                                lastPDFURL = url
                                showShare = true
                            }
                        }
                        if let url = lastPDFURL {
                            ShareLink(item: url) { Text("Udostępnij PDF") }
                        }
                    }
                }
            }
            .navigationTitle("Kalkulator dawek")
            .toolbar {
                // Info (disclaimer)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showDisclaimer = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("Informacje i ostrzeżenie")
                }
                // Dodaj lek
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddMedication = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if !disclaimerAccepted { showDisclaimer = true }
            }
            .sheet(isPresented: $showDisclaimer) {
                DisclaimerView {
                    disclaimerAccepted = true
                    showDisclaimer = false
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                addMedicationView
            }
        }
    }
    
    private func currentChildName() -> String {
        if let i = model.selectedChildIndex, model.children.indices.contains(i) {
            return model.children[i].name
        }
        return "Dziecko"
    }
    
    // Dodawanie leku
    var addMedicationView: some View {
        NavigationView {
            Form {
                Section(header: Text("Nowy lek")) {
                    TextField("Nazwa leku", text: $newMedicationName)
                    HStack {
                        TextField("Dawka na kg", text: $newMedicationDose).keyboardType(.decimalPad)
                        Text("ml/kg")
                    }
                }
                Section(header: Text("Dawkowanie")) {
                    Stepper(value: $newMedicationTimesPerDay, in: 1...12) {
                        HStack { Text("Ilość dawek na dobę:"); Spacer(); Text("\(newMedicationTimesPerDay)") }
                    }
                    Stepper(value: $newMedicationHoursInterval, in: 1...24) {
                        HStack { Text("Co ile godzin:"); Spacer(); Text("\(newMedicationHoursInterval) h") }
                    }
                }
                Section {
                    Button {
                        if let dose = Double(newMedicationDose), !newMedicationName.isEmpty {
                            model.medications.append(Medication(
                                name: newMedicationName,
                                dosePerKg: dose,
                                timesPerDay: newMedicationTimesPerDay,
                                hoursInterval: newMedicationHoursInterval
                            ))
                            // ⬇️ Sortuj po dodaniu
                            model.sortMedications()
                            newMedicationName = ""
                            newMedicationDose = ""
                            showingAddMedication = false
                        }
                    } label: {
                        Text("Dodaj lek")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(newMedicationName.isEmpty || newMedicationDose.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(newMedicationName.isEmpty || newMedicationDose.isEmpty)
                }
            }
            .navigationTitle("Dodaj lek")
            .navigationBarItems(trailing: Button("Anuluj") { showingAddMedication = false })
        }
    }
}

// MARK: - Wybór leku

struct MedicationSelectionView: View {
    @ObservedObject var model: CalculatorModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(Array(model.medications.enumerated()), id: \.element.id) { index, medication in
                Button {
                    model.selectedMedicationIndex = index
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(medication.name)
                            Text("\(medication.dosePerKg, specifier: "%.3f") \(medication.unit), \(medication.timesPerDay)x/dzień")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if model.selectedMedicationIndex == index {
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Wybierz lek")
    }
}

// MARK: - Zarządzanie dziećmi (dodawanie + EDYCJA)

struct ChildrenView: View {
    @ObservedObject var model: CalculatorModel
    
    @State private var name = ""
    @State private var birth = Date()
    @State private var weight = ""
    
    @State private var isEditing = false
    @State private var editIndex: Int? = nil
    
    var body: some View {
        Form {
            // Dodaj
            Section(header: Text("Dodaj dziecko")) {
                TextField("Imię", text: $name)
                DatePicker("Data urodzenia", selection: $birth, displayedComponents: .date)
                TextField("Waga (kg)", text: $weight).keyboardType(.decimalPad)
                Button("Dodaj") {
                    if let w = Double(weight), !name.isEmpty {
                        model.children.append(ChildProfile(name: name, birthDate: birth, weightKg: w))
                        name = ""; weight = ""; birth = Date()
                    }
                }
                .disabled(name.isEmpty || Double(weight) == nil)
            }
            
            // Lista
            Section(header: Text("Dzieci")) {
                ForEach(Array(model.children.enumerated()), id: \.element.id) { idx, ch in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(ch.name).font(.headline)
                            Text("\(String(format: "%.1f", ch.weightKg)) kg").foregroundColor(.secondary)
                        }
                        Spacer()
                        if model.selectedChildIndex == idx { Image(systemName: "checkmark") }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { model.selectedChildIndex = idx }
                    .contextMenu {
                        Button("Ustaw jako aktywne") { model.selectedChildIndex = idx }
                        Button("Edytuj") { beginEdit(index: idx, child: ch) }
                        Button(role: .destructive) {
                            let id = ch.id
                            model.children.removeAll { $0.id == id }
                            model.clearHistory(for: id)
                            model.temperatures.removeAll { $0.childId == id }
                        } label: { Text("Usuń dziecko") }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            beginEdit(index: idx, child: ch)
                        } label: {
                            Label("Edytuj", systemImage: "pencil")
                        }.tint(.blue)
                        Button(role: .destructive) {
                            let id = ch.id
                            model.children.removeAll { $0.id == id }
                            model.clearHistory(for: id)
                            model.temperatures.removeAll { $0.childId == id }
                        } label: { Label("Usuń", systemImage: "trash") }
                    }
                }
            }
        }
        .navigationTitle("Dzieci")
        .sheet(isPresented: $isEditing) {
            NavigationView {
                Form {
                    Section(header: Text("Edytuj dziecko")) {
                        TextField("Imię", text: $name)
                        DatePicker("Data urodzenia", selection: $birth, displayedComponents: .date)
                        TextField("Waga (kg)", text: $weight).keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Edycja")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Anuluj") { isEditing = false; editIndex = nil }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Zapisz") {
                            guard let idx = editIndex,
                                  model.children.indices.contains(idx),
                                  let w = Double(weight)
                            else { isEditing = false; editIndex = nil; return }
                            model.children[idx].name = name
                            model.children[idx].birthDate = birth
                            model.children[idx].weightKg = w
                            isEditing = false
                            editIndex = nil
                        }
                        .disabled(name.isEmpty || Double(weight) == nil)
                    }
                }
            }
        }
    }
    
    private func beginEdit(index: Int, child: ChildProfile) {
        editIndex = index
        name = child.name
        birth = child.birthDate
        weight = String(format: "%.1f", child.weightKg)
        isEditing = true
    }
}

// MARK: - Disclaimer (pop-up)

struct DisclaimerView: View {
    var onAccept: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ważne ostrzeżenie")
                        .font(.title2).bold()
                    
                    Text("""
Ta aplikacja ma wyłącznie charakter informacyjny i **nie zastępuje** porady lekarza, farmaceuty ani informacji z ulotki/opisu leku. Wyniki są orientacyjne i oparte na danych podanych przez Ciebie – mogą być **nieodpowiednie** m.in. przy chorobach współistniejących, alergiach, wcześniactwie, u niemowląt, w interakcjach lek–lek itp.

**Zawsze** weryfikuj dawkowanie z lekarzem lub zgodnie z receptą/ulotką. W razie wątpliwości skontaktuj się z lekarzem lub farmaceutą. W sytuacjach nagłych dzwoń 112/999.

Korzystasz z aplikacji na własną odpowiedzialność.
""")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Przypomnienia:").font(.headline)
                        Text("• Nie łącz samodzielnie leków bez konsultacji.")
                        Text("• Zwracaj uwagę na stężenia (mg/ml, mg/5 ml).")
                        Text("• Nie przekraczaj dobowych dawek maksymalnych z ulotki/recepty.")
                        Text("• Dla dzieci – kieruj się zaleceniami pediatry.")
                    }
                }
                .padding()
            }
            .navigationTitle("Ostrzeżenie")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Rozumiem") { onAccept() }
                }
            }
        }
    }
}

// MARK: - PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
