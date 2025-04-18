import Foundation
import Combine

class TestResultsViewModel: BaseViewModelImpl {
    @Published var testResults: [TestResult] = []
    @Published var selectedFilter: TestFilter = .all
    @Published var chartData: [SubjectScore] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadTestResults()
    }
    
    func loadTestResults() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate sample test results
            self.testResults = self.generateSampleTestResults()
            self.updateChartData()
            self.isLoading = false
        }
    }
    
    func updateChartData() {
        // Calculate average scores for each subject across all tests
        var subjectScores: [String: [Double]] = [:]
        
        for result in filteredTestResults {
            for score in result.subjectScores {
                if subjectScores[score.subject] == nil {
                    subjectScores[score.subject] = []
                }
                subjectScores[score.subject]?.append(score.score)
            }
        }
        
        // Convert to array of SubjectScore with average values
        chartData = subjectScores.map { subject, scores in
            let average = scores.reduce(0, +) / Double(scores.count)
            return SubjectScore(subject: subject, score: average)
        }.sorted { $0.subject < $1.subject }
    }
    
    var filteredTestResults: [TestResult] {
        switch selectedFilter {
        case .all:
            return testResults
        case .tyt:
            return testResults.filter { $0.examType == .tyt }
        case .ayt:
            return testResults.filter { $0.examType == .ayt }
        }
    }
    
    func addTestResult(_ result: TestResult) {
        testResults.append(result)
        testResults.sort { $0.date > $1.date } // Sort by date, newest first
        updateChartData()
    }
    
    // Helper function to generate sample data
    private func generateSampleTestResults() -> [TestResult] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        // TYT Test Results
        let tytTest1 = TestResult(
            id: UUID(),
            name: "TYT Deneme 1",
            examType: .tyt,
            date: dateFormatter.date(from: "10/04/2025")!,
            totalQuestions: 120,
            correctAnswers: 85,
            wrongAnswers: 25,
            emptyAnswers: 10,
            netScore: 78.75,
            subjectScores: [
                SubjectScore(subject: "Türkçe", score: 32.5),
                SubjectScore(subject: "Matematik", score: 25.0),
                SubjectScore(subject: "Fizik", score: 7.5),
                SubjectScore(subject: "Kimya", score: 6.25),
                SubjectScore(subject: "Biyoloji", score: 5.0),
                SubjectScore(subject: "Tarih", score: 2.5)
            ]
        )
        
        let tytTest2 = TestResult(
            id: UUID(),
            name: "TYT Deneme 2",
            examType: .tyt,
            date: dateFormatter.date(from: "25/03/2025")!,
            totalQuestions: 120,
            correctAnswers: 80,
            wrongAnswers: 30,
            emptyAnswers: 10,
            netScore: 72.5,
            subjectScores: [
                SubjectScore(subject: "Türkçe", score: 30.0),
                SubjectScore(subject: "Matematik", score: 22.5),
                SubjectScore(subject: "Fizik", score: 7.5),
                SubjectScore(subject: "Kimya", score: 5.0),
                SubjectScore(subject: "Biyoloji", score: 5.0),
                SubjectScore(subject: "Tarih", score: 2.5)
            ]
        )
        
        // AYT Test Results
        let aytTest1 = TestResult(
            id: UUID(),
            name: "AYT Deneme 1",
            examType: .ayt,
            date: dateFormatter.date(from: "05/04/2025")!,
            totalQuestions: 160,
            correctAnswers: 95,
            wrongAnswers: 45,
            emptyAnswers: 20,
            netScore: 83.75,
            subjectScores: [
                SubjectScore(subject: "Matematik", score: 30.0),
                SubjectScore(subject: "Fizik", score: 12.5),
                SubjectScore(subject: "Kimya", score: 10.0),
                SubjectScore(subject: "Biyoloji", score: 7.5),
                SubjectScore(subject: "Edebiyat", score: 15.0),
                SubjectScore(subject: "Tarih", score: 5.0),
                SubjectScore(subject: "Coğrafya", score: 3.75)
            ]
        )
        
        let aytTest2 = TestResult(
            id: UUID(),
            name: "AYT Deneme 2",
            examType: .ayt,
            date: dateFormatter.date(from: "20/03/2025")!,
            totalQuestions: 160,
            correctAnswers: 90,
            wrongAnswers: 50,
            emptyAnswers: 20,
            netScore: 77.5,
            subjectScores: [
                SubjectScore(subject: "Matematik", score: 27.5),
                SubjectScore(subject: "Fizik", score: 10.0),
                SubjectScore(subject: "Kimya", score: 10.0),
                SubjectScore(subject: "Biyoloji", score: 7.5),
                SubjectScore(subject: "Edebiyat", score: 12.5),
                SubjectScore(subject: "Tarih", score: 5.0),
                SubjectScore(subject: "Coğrafya", score: 5.0)
            ]
        )
        
        return [tytTest1, tytTest2, aytTest1, aytTest2].sorted { $0.date > $1.date }
    }
}

// Models used by the Test Results
enum TestFilter: String, CaseIterable {
    case all = "Tümü"
    case tyt = "TYT"
    case ayt = "AYT"
    
    var id: String { self.rawValue }
}

struct TestResult: Identifiable {
    var id: UUID
    var name: String
    var examType: ExamType
    var date: Date
    var totalQuestions: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    var emptyAnswers: Int
    var netScore: Double
    var subjectScores: [SubjectScore]
    
    var scorePercentage: Double {
        return (netScore / Double(totalQuestions)) * 100
    }
}

struct SubjectScore: Identifiable {
    var id = UUID()
    var subject: String
    var score: Double
}
