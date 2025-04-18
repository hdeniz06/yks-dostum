import Foundation
import Combine

class SubjectTrackingViewModel: BaseViewModelImpl {
    @Published var subjects: [Subject] = []
    @Published var selectedExamType: ExamType = .tyt
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadSubjects()
    }
    
    func loadSubjects() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate sample subjects
            self.subjects = self.generateSampleSubjects()
            self.isLoading = false
        }
    }
    
    func updateSubjectStatus(subjectId: UUID, topicId: UUID, status: TopicStatus) {
        if let subjectIndex = subjects.firstIndex(where: { $0.id == subjectId }),
           let topicIndex = subjects[subjectIndex].topics.firstIndex(where: { $0.id == topicId }) {
            subjects[subjectIndex].topics[topicIndex].status = status
            
            // Update completion percentage
            updateSubjectCompletionPercentage(subjectIndex: subjectIndex)
        }
    }
    
    private func updateSubjectCompletionPercentage(subjectIndex: Int) {
        let topics = subjects[subjectIndex].topics
        let completedCount = topics.filter { $0.status == .completed }.count
        let totalCount = topics.count
        
        if totalCount > 0 {
            subjects[subjectIndex].completionPercentage = Double(completedCount) / Double(totalCount) * 100
        } else {
            subjects[subjectIndex].completionPercentage = 0
        }
    }
    
    var filteredSubjects: [Subject] {
        var filtered = subjects.filter { $0.examType == selectedExamType }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { subject in
                subject.name.localizedCaseInsensitiveContains(searchText) ||
                subject.topics.contains { topic in
                    topic.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        return filtered
    }
    
    // Helper function to generate sample data
    private func generateSampleSubjects() -> [Subject] {
        // TYT Subjects
        let tytMath = Subject(
            id: UUID(),
            name: "Matematik",
            examType: .tyt,
            topics: [
                Topic(id: UUID(), name: "Temel Kavramlar", status: .completed),
                Topic(id: UUID(), name: "Sayı Basamakları", status: .completed),
                Topic(id: UUID(), name: "Bölme ve Bölünebilme", status: .inProgress),
                Topic(id: UUID(), name: "EBOB-EKOK", status: .notStarted),
                Topic(id: UUID(), name: "Rasyonel Sayılar", status: .notStarted),
                Topic(id: UUID(), name: "Basit Eşitsizlikler", status: .notStarted),
                Topic(id: UUID(), name: "Mutlak Değer", status: .notStarted),
                Topic(id: UUID(), name: "Üslü Sayılar", status: .notStarted),
                Topic(id: UUID(), name: "Köklü Sayılar", status: .notStarted),
                Topic(id: UUID(), name: "Çarpanlara Ayırma", status: .notStarted),
                Topic(id: UUID(), name: "Oran Orantı", status: .notStarted),
                Topic(id: UUID(), name: "Problemler", status: .notStarted)
            ]
        )
        
        let tytTurkish = Subject(
            id: UUID(),
            name: "Türkçe",
            examType: .tyt,
            topics: [
                Topic(id: UUID(), name: "Sözcükte Anlam", status: .completed),
                Topic(id: UUID(), name: "Cümlede Anlam", status: .completed),
                Topic(id: UUID(), name: "Paragrafta Anlam", status: .inProgress),
                Topic(id: UUID(), name: "Dil Bilgisi", status: .notStarted),
                Topic(id: UUID(), name: "Yazım Kuralları", status: .notStarted),
                Topic(id: UUID(), name: "Noktalama İşaretleri", status: .notStarted),
                Topic(id: UUID(), name: "Anlatım Bozuklukları", status: .notStarted)
            ]
        )
        
        let tytPhysics = Subject(
            id: UUID(),
            name: "Fizik",
            examType: .tyt,
            topics: [
                Topic(id: UUID(), name: "Fizik Bilimine Giriş", status: .completed),
                Topic(id: UUID(), name: "Madde ve Özellikleri", status: .inProgress),
                Topic(id: UUID(), name: "Hareket ve Kuvvet", status: .notStarted),
                Topic(id: UUID(), name: "Enerji", status: .notStarted),
                Topic(id: UUID(), name: "Isı ve Sıcaklık", status: .notStarted),
                Topic(id: UUID(), name: "Elektrostatik", status: .notStarted),
                Topic(id: UUID(), name: "Elektrik", status: .notStarted),
                Topic(id: UUID(), name: "Manyetizma", status: .notStarted)
            ]
        )
        
        // AYT Subjects
        let aytMath = Subject(
            id: UUID(),
            name: "Matematik",
            examType: .ayt,
            topics: [
                Topic(id: UUID(), name: "Fonksiyonlar", status: .notStarted),
                Topic(id: UUID(), name: "Polinomlar", status: .notStarted),
                Topic(id: UUID(), name: "İkinci Dereceden Denklemler", status: .notStarted),
                Topic(id: UUID(), name: "Karmaşık Sayılar", status: .notStarted),
                Topic(id: UUID(), name: "Logaritma", status: .notStarted),
                Topic(id: UUID(), name: "Trigonometri", status: .notStarted),
                Topic(id: UUID(), name: "Diziler", status: .notStarted),
                Topic(id: UUID(), name: "Limit ve Süreklilik", status: .notStarted),
                Topic(id: UUID(), name: "Türev", status: .notStarted),
                Topic(id: UUID(), name: "İntegral", status: .notStarted)
            ]
        )
        
        let aytPhysics = Subject(
            id: UUID(),
            name: "Fizik",
            examType: .ayt,
            topics: [
                Topic(id: UUID(), name: "Vektörler", status: .notStarted),
                Topic(id: UUID(), name: "Kuvvet ve Hareket", status: .notStarted),
                Topic(id: UUID(), name: "Enerji ve Momentum", status: .notStarted),
                Topic(id: UUID(), name: "Elektrik ve Manyetizma", status: .notStarted),
                Topic(id: UUID(), name: "Dalgalar", status: .notStarted),
                Topic(id: UUID(), name: "Modern Fizik", status: .notStarted)
            ]
        )
        
        let aytChemistry = Subject(
            id: UUID(),
            name: "Kimya",
            examType: .ayt,
            topics: [
                Topic(id: UUID(), name: "Kimyanın Temel Kanunları", status: .notStarted),
                Topic(id: UUID(), name: "Atom ve Periyodik Sistem", status: .notStarted),
                Topic(id: UUID(), name: "Kimyasal Bağlar", status: .notStarted),
                Topic(id: UUID(), name: "Kimyasal Tepkimeler", status: .notStarted),
                Topic(id: UUID(), name: "Gazlar", status: .notStarted),
                Topic(id: UUID(), name: "Çözeltiler", status: .notStarted),
                Topic(id: UUID(), name: "Kimyasal Denge", status: .notStarted),
                Topic(id: UUID(), name: "Asitler ve Bazlar", status: .notStarted),
                Topic(id: UUID(), name: "İndirgenme-Yükseltgenme", status: .notStarted),
                Topic(id: UUID(), name: "Organik Kimya", status: .notStarted)
            ]
        )
        
        let subjects = [tytMath, tytTurkish, tytPhysics, aytMath, aytPhysics, aytChemistry]
        
        // Calculate completion percentages
        for i in 0..<subjects.count {
            updateSubjectCompletionPercentage(subjectIndex: i)
        }
        
        return subjects
    }
}

// Models used by the Subject Tracking
enum ExamType: String, CaseIterable {
    case tyt = "TYT"
    case ayt = "AYT"
    
    var id: String { self.rawValue }
}

enum TopicStatus: String, CaseIterable {
    case notStarted = "Başlanmadı"
    case inProgress = "Devam Ediyor"
    case completed = "Tamamlandı"
    
    var color: String {
        switch self {
        case .notStarted: return "gray"
        case .inProgress: return "orange"
        case .completed: return "green"
        }
    }
}

struct Subject: Identifiable {
    var id: UUID
    var name: String
    var examType: ExamType
    var topics: [Topic]
    var completionPercentage: Double = 0
}

struct Topic: Identifiable {
    var id: UUID
    var name: String
    var status: TopicStatus
}
