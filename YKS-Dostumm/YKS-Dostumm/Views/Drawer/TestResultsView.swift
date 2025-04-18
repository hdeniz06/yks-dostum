import SwiftUI

struct TestResultsView: View {
    @ObservedObject var viewModel: TestResultsViewModel
    @State private var showingAddTest = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Bar
            HStack {
                ForEach(TestFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        viewModel.selectedFilter = filter
                        viewModel.updateChartData()
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(viewModel.selectedFilter == filter ? .white : .primary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingAddTest = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.blue))
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            ScrollView {
                VStack(spacing: 20) {
                    // Performance Chart
                    if !viewModel.chartData.isEmpty {
                        PerformanceChartView(data: viewModel.chartData)
                    }
                    
                    // Test Results List
                    ForEach(viewModel.filteredTestResults) { result in
                        TestResultCardView(result: result)
                    }
                    
                    if viewModel.filteredTestResults.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("Henüz deneme sonucu yok")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showingAddTest = true
                            }) {
                                Text("Deneme Sonucu Ekle")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    }
                }
                .padding()
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 80, height: 80)
                    )
            }
        }
        .sheet(isPresented: $showingAddTest) {
            AddTestResultView(onAdd: { result in
                viewModel.addTestResult(result)
                showingAddTest = false
            })
        }
    }
}

struct PerformanceChartView: View {
    let data: [SubjectScore]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ders Performansı")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Bar Chart
            VStack(spacing: 12) {
                ForEach(data) { item in
                    HStack {
                        Text(item.subject)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 20)
                                    .opacity(0.2)
                                    .foregroundColor(.gray)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .frame(width: min(CGFloat(item.score / 40) * geometry.size.width, geometry.size.width), height: 20)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                                
                                Text(String(format: "%.1f", item.score))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                            }
                        }
                        .frame(height: 20)
                    }
                }
            }
            
            // Legend
            HStack {
                Text("0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("40")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 80)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TestResultCardView: View {
    let result: TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.name)
                        .font(.headline)
                    
                    Text(result.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(result.examType.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(result.examType == .tyt ? Color.blue.opacity(0.2) : Color.purple.opacity(0.2))
                    )
                    .foregroundColor(result.examType == .tyt ? .blue : .purple)
            }
            
            Divider()
            
            // Score Summary
            HStack(spacing: 20) {
                // Net Score
                VStack {
                    Text(String(format: "%.1f", result.netScore))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Net")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Correct
                VStack {
                    Text("\(result.correctAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("Doğru")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Wrong
                VStack {
                    Text("\(result.wrongAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Text("Yanlış")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Empty
                VStack {
                    Text("\(result.emptyAnswers)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Boş")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Percentage
                VStack {
                    Text(String(format: "%.1f%%", result.scorePercentage))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.purple)
                    
                    Text("Başarı")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Subject Scores
            VStack(alignment: .leading, spacing: 10) {
                Text("Ders Bazlı Sonuçlar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(result.subjectScores) { score in
                        HStack {
                            Text(score.subject)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", score.score))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AddTestResultView: View {
    let onAdd: (TestResult) -> Void
    
    @State private var name: String = ""
    @State private var examType: ExamType = .tyt
    @State private var date: Date = Date()
    @State private var totalQuestions: Int = 120
    @State private var correctAnswers: Int = 0
    @State private var wrongAnswers: Int = 0
    @State private var emptyAnswers: Int = 0
    @State private var subjectScores: [SubjectScore] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    var netScore: Double {
        return Double(correctAnswers) - (Double(wrongAnswers) * 0.25)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Deneme Bilgileri")) {
                    TextField("Deneme Adı", text: $name)
                    
                    Picker("Sınav Türü", selection: $examType) {
                        ForEach(ExamType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Soru Sayıları")) {
                    HStack {
                        Text("Toplam Soru")
                        Spacer()
                        Text("\(totalQuestions)")
                            .foregroundColor(.secondary)
                    }
                    
                    Stepper("Doğru: \(correctAnswers)", value: $correctAnswers, in: 0...totalQuestions)
                        .onChange(of: correctAnswers) { newValue in
                            // Adjust empty answers to ensure total is correct
                            let total = newValue + wrongAnswers
                            if total > totalQuestions {
                                wrongAnswers = totalQuestions - newValue
                            }
                            emptyAnswers = totalQuestions - (newValue + wrongAnswers)
                        }
                    
                    Stepper("Yanlış: \(wrongAnswers)", value: $wrongAnswers, in: 0...totalQuestions)
                        .onChange(of: wrongAnswers) { newValue in
                            // Adjust empty answers to ensure total is correct
                            let total = correctAnswers + newValue
                            if total > totalQuestions {
                                correctAnswers = totalQuestions - newValue
                            }
                            emptyAnswers = totalQuestions - (correctAnswers + newValue)
                        }
                    
                    HStack {
                        Text("Boş")
                        Spacer()
                        Text("\(emptyAnswers)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Net")
                        Spacer()
                        Text(String(format: "%.2f", netScore))
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                
                // For simplicity, we're not implementing the subject scores input in this demo
                // In a real app, you would add a section to input scores for each subject
            }
            .navigationTitle("Deneme Sonucu Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    // Create a new test result
                    let result = TestResult(
                        id: UUID(),
                        name: name.isEmpty ? "Yeni Deneme" : name,
                        examType: examType,
                        date: date,
                        totalQuestions: totalQuestions,
                        correctAnswers: correctAnswers,
                        wrongAnswers: wrongAnswers,
                        emptyAnswers: emptyAnswers,
                        netScore: netScore,
                        subjectScores: [] // In a real app, you would collect these from the user
                    )
                    onAdd(result)
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    TestResultsView(viewModel: TestResultsViewModel())
}
