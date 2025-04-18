import Foundation
import Combine

class DashboardViewModel: BaseViewModelImpl {
    @Published var welcomeMessage: String = ""
    @Published var todoItems: [TodoItem] = []
    @Published var studyStats: StudyStats = StudyStats()
    @Published var nextExamDate: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadDashboardData()
    }
    
    func loadDashboardData() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Set welcome message based on time of day
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 {
                self.welcomeMessage = "Günaydın! Bugün çalışmaya hazır mısın?"
            } else if hour < 18 {
                self.welcomeMessage = "İyi günler! Çalışmalarına devam edelim."
            } else {
                self.welcomeMessage = "İyi akşamlar! Günü verimli geçirdin mi?"
            }
            
            // Sample todo items
            self.todoItems = [
                TodoItem(id: UUID(), title: "TYT Matematik Konuları", isCompleted: false),
                TodoItem(id: UUID(), title: "AYT Fizik Testleri", isCompleted: true),
                TodoItem(id: UUID(), title: "Türkçe Paragraf Çalışması", isCompleted: false),
                TodoItem(id: UUID(), title: "Deneme Sınavı Analizi", isCompleted: false)
            ]
            
            // Sample study stats
            self.studyStats = StudyStats(
                dailyStudyHours: 4.5,
                weeklyStudyHours: 28.5,
                completedTopics: 42,
                totalTopics: 120
            )
            
            // Next YKS exam date (sample)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.nextExamDate = dateFormatter.date(from: "15/06/2026")
            
            self.isLoading = false
        }
    }
    
    func toggleTodoItem(_ id: UUID) {
        if let index = todoItems.firstIndex(where: { $0.id == id }) {
            todoItems[index].isCompleted.toggle()
            // In a real app, you would save this change to a database
        }
    }
    
    func addTodoItem(title: String) {
        let newItem = TodoItem(id: UUID(), title: title, isCompleted: false)
        todoItems.append(newItem)
        // In a real app, you would save this to a database
    }
}

// Models used by the Dashboard
struct TodoItem: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}

struct StudyStats {
    var dailyStudyHours: Double = 0
    var weeklyStudyHours: Double = 0
    var completedTopics: Int = 0
    var totalTopics: Int = 0
    
    var topicCompletionPercentage: Double {
        guard totalTopics > 0 else { return 0 }
        return Double(completedTopics) / Double(totalTopics) * 100
    }
}
