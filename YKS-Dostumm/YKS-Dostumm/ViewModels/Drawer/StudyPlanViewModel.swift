import Foundation
import Combine

class StudyPlanViewModel: BaseViewModelImpl {
    @Published var studyPlan: [StudyDay] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedWeek: [Date] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        generateWeekDates()
        loadStudyPlan()
    }
    
    func generateWeekDates() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        
        selectedWeek = (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startDate)!
        }
    }
    
    func moveToNextWeek() {
        let calendar = Calendar.current
        if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
            selectedDate = nextWeek
            generateWeekDates()
            loadStudyPlan()
        }
    }
    
    func moveToPreviousWeek() {
        let calendar = Calendar.current
        if let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
            selectedDate = previousWeek
            generateWeekDates()
            loadStudyPlan()
        }
    }
    
    func loadStudyPlan() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate sample study plan for the selected week
            self.studyPlan = self.generateSampleStudyPlan()
            self.isLoading = false
        }
    }
    
    func addStudyTask(date: Date, task: StudyTask) {
        if let index = studyPlan.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            studyPlan[index].tasks.append(task)
        } else {
            let newDay = StudyDay(date: date, tasks: [task])
            studyPlan.append(newDay)
        }
        // In a real app, you would save this to a database
    }
    
    func toggleTaskCompletion(dayIndex: Int, taskIndex: Int) {
        guard dayIndex < studyPlan.count, taskIndex < studyPlan[dayIndex].tasks.count else { return }
        
        studyPlan[dayIndex].tasks[taskIndex].isCompleted.toggle()
        // In a real app, you would save this change to a database
    }
    
    // Helper function to generate sample data
    private func generateSampleStudyPlan() -> [StudyDay] {
        let subjects = ["Matematik", "Fizik", "Kimya", "Biyoloji", "Türkçe", "Edebiyat", "Tarih", "Coğrafya"]
        let taskTypes = ["Konu Tekrarı", "Test Çözümü", "Deneme Sınavı", "Soru Çözümü", "Video İzleme"]
        
        return selectedWeek.map { date in
            let tasksCount = Int.random(in: 2...5)
            let tasks = (0..<tasksCount).map { _ in
                let subject = subjects.randomElement()!
                let taskType = taskTypes.randomElement()!
                let duration = Double.random(in: 1...3)
                let isCompleted = Bool.random()
                
                return StudyTask(
                    id: UUID(),
                    subject: subject,
                    description: "\(subject) \(taskType)",
                    startTime: Calendar.current.date(bySettingHour: Int.random(in: 9...18), minute: 0, second: 0, of: date)!,
                    duration: duration,
                    isCompleted: isCompleted
                )
            }.sorted { $0.startTime < $1.startTime }
            
            return StudyDay(date: date, tasks: tasks)
        }
    }
}

// Models used by the Study Plan
struct StudyDay: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var tasks: [StudyTask]
    
    var totalHours: Double {
        tasks.reduce(0) { $0 + $1.duration }
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
}

struct StudyTask: Identifiable {
    var id: UUID
    var subject: String
    var description: String
    var startTime: Date
    var duration: Double // in hours
    var isCompleted: Bool
    
    var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: Int(duration * 60), to: startTime)!
    }
}
