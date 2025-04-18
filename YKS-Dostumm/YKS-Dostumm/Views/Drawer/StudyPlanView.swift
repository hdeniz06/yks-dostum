import SwiftUI

struct StudyPlanView: View {
    @ObservedObject var viewModel: StudyPlanViewModel
    @State private var showingAddTask = false
    @State private var selectedDay: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekly Calendar
            WeeklyCalendarView(
                selectedWeek: viewModel.selectedWeek,
                onPreviousWeek: viewModel.moveToPreviousWeek,
                onNextWeek: viewModel.moveToNextWeek,
                onSelectDay: { date in
                    selectedDay = date
                }
            )
            
            // Study Plan Content
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.studyPlan.indices, id: \.self) { dayIndex in
                        let studyDay = viewModel.studyPlan[dayIndex]
                        
                        DayPlanView(
                            studyDay: studyDay,
                            onToggleTask: { taskIndex in
                                viewModel.toggleTaskCompletion(dayIndex: dayIndex, taskIndex: taskIndex)
                            },
                            onAddTask: {
                                selectedDay = studyDay.date
                                showingAddTask = true
                            }
                        )
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
        .sheet(isPresented: $showingAddTask) {
            if let selectedDay = selectedDay {
                AddTaskView(date: selectedDay, onAdd: { task in
                    viewModel.addStudyTask(date: selectedDay, task: task)
                    showingAddTask = false
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    selectedDay = Date()
                    showingAddTask = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct WeeklyCalendarView: View {
    let selectedWeek: [Date]
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    let onSelectDay: (Date) -> Void
    
    @State private var selectedDayIndex: Int = Calendar.current.component(.weekday, from: Date()) - 1
    
    var body: some View {
        VStack(spacing: 10) {
            // Month and Year
            HStack {
                Button(action: onPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if let firstDay = selectedWeek.first, let lastDay = selectedWeek.last {
                    Text("\(formatDate(firstDay)) - \(formatDate(lastDay))")
                        .font(.headline)
                }
                
                Spacer()
                
                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            // Days of the week
            HStack(spacing: 0) {
                ForEach(selectedWeek.indices, id: \.self) { index in
                    let date = selectedWeek[index]
                    let isSelected = index == selectedDayIndex
                    let isToday = Calendar.current.isDateInToday(date)
                    
                    Button(action: {
                        selectedDayIndex = index
                        onSelectDay(date)
                    }) {
                        VStack(spacing: 8) {
                            // Day name (Mon, Tue, etc.)
                            Text(dayName(from: date))
                                .font(.caption)
                                .foregroundColor(isSelected ? .white : .secondary)
                            
                            // Day number
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color.blue : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 5)
            .background(Color(UIColor.secondarySystemBackground))
        }
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            // Select today if it's in the current week
            if let todayIndex = selectedWeek.firstIndex(where: { Calendar.current.isDateInToday($0) }) {
                selectedDayIndex = todayIndex
                onSelectDay(selectedWeek[todayIndex])
            } else {
                // Otherwise select the first day of the week
                selectedDayIndex = 0
                onSelectDay(selectedWeek[0])
            }
        }
    }
    
    private func dayName(from date: Date) -> String {
        let formatter = Self.dayNameFormatter
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = Self.dateFormatter
        return formatter.string(from: date)
    }
    
    private static let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}

struct DayPlanView: View {
    let studyDay: StudyDay
    let onToggleTask: (Int) -> Void
    let onAddTask: () -> Void
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter
    }()
    
    private func formatDate(_ date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Day header
            HStack {
                Text(formatDate(studyDay.date))
                    .font(.headline)
                
                Spacer()
                
                Text("\(studyDay.completedTasksCount)/\(studyDay.tasks.count) Tamamlandı")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.1f saat", studyDay.totalHours))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            // Tasks
            if studyDay.tasks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 30))
                            .foregroundColor(.secondary)
                        Text("Bu gün için görev bulunmuyor")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button(action: onAddTask) {
                            Text("Görev Ekle")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(studyDay.tasks.indices, id: \.self) { index in
                    let task = studyDay.tasks[index]
                    
                    TaskItemView(
                        task: task,
                        onToggle: {
                            onToggleTask(index)
                        }
                    )
                    
                    if index < studyDay.tasks.count - 1 {
                        Divider()
                    }
                }
                
                Button(action: onAddTask) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Yeni Görev Ekle")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
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

struct TaskItemView: View {
    let task: StudyTask
    let onToggle: () -> Void
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time column
            VStack(alignment: .center, spacing: 5) {
                Text(Self.timeFormatter.string(from: task.startTime))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(Self.timeFormatter.string(from: task.endTime))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 2, height: 30)
            }
            .frame(width: 50)
            
            // Task details
            VStack(alignment: .leading, spacing: 5) {
                Text(task.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                HStack {
                    Text(task.subject)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    
                    Text(String(format: "%.1f saat", task.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Completion button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 5)
    }
}

struct AddTaskView: View {
    let date: Date
    let onAdd: (StudyTask) -> Void
    
    @State private var subject: String = ""
    @State private var description: String = ""
    @State private var startTime: Date
    @State private var duration: Double = 1.0
    
    @Environment(\.presentationMode) var presentationMode
    
    init(date: Date, onAdd: @escaping (StudyTask) -> Void) {
        self.date = date
        self.onAdd = onAdd
        
        // Set default start time to 9 AM on the selected date
        let calendar = Calendar.current
        let defaultStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date) ?? date
        _startTime = State(initialValue: defaultStartTime)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Görev Detayları")) {
                    TextField("Ders", text: $subject)
                    TextField("Açıklama", text: $description)
                }
                
                Section(header: Text("Zaman")) {
                    DatePicker("Başlangıç Saati", selection: $startTime, displayedComponents: .hourAndMinute)
                    
                    VStack(alignment: .leading) {
                        Text("Süre: \(String(format: "%.1f saat", duration))")
                        Slider(value: $duration, in: 0.5...4.0, step: 0.5)
                    }
                }
            }
            .navigationTitle("Yeni Görev")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    let newTask = StudyTask(
                        id: UUID(),
                        subject: subject,
                        description: description.isEmpty ? "\(subject) Çalışması" : description,
                        startTime: startTime,
                        duration: duration,
                        isCompleted: false
                    )
                    onAdd(newTask)
                }
                .disabled(subject.isEmpty)
            )
        }
    }
}

#Preview {
    StudyPlanView(viewModel: StudyPlanViewModel())
}
