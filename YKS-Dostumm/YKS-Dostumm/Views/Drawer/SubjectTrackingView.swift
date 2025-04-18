import SwiftUI

struct SubjectTrackingView: View {
    @ObservedObject var viewModel: SubjectTrackingViewModel
    @State private var expandedSubjects: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            VStack(spacing: 10) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Konu veya ders ara", text: $viewModel.searchText)
                        .font(.system(size: 16))
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                
                // Exam Type Selector
                HStack {
                    ForEach(ExamType.allCases, id: \.self) { examType in
                        Button(action: {
                            viewModel.selectedExamType = examType
                        }) {
                            Text(examType.rawValue)
                                .font(.system(size: 15, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.selectedExamType == examType ? Color.blue : Color.gray.opacity(0.2))
                                )
                                .foregroundColor(viewModel.selectedExamType == examType ? .white : .primary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // Subject List
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.filteredSubjects) { subject in
                        SubjectCardView(
                            subject: subject,
                            isExpanded: expandedSubjects.contains(subject.id),
                            onToggleExpand: {
                                toggleExpand(subject.id)
                            },
                            onUpdateStatus: { topicId, status in
                                viewModel.updateSubjectStatus(subjectId: subject.id, topicId: topicId, status: status)
                            }
                        )
                    }
                    
                    if viewModel.filteredSubjects.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("Sonuç bulunamadı")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if !viewModel.searchText.isEmpty {
                                Text("Arama kriterlerinizi değiştirmeyi deneyin")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
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
    }
    
    private func toggleExpand(_ subjectId: UUID) {
        if expandedSubjects.contains(subjectId) {
            expandedSubjects.remove(subjectId)
        } else {
            expandedSubjects.insert(subjectId)
        }
    }
}

struct SubjectCardView: View {
    let subject: Subject
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onUpdateStatus: (UUID, TopicStatus) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Subject Header
            Button(action: onToggleExpand) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(subject.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(subject.topics.count) konu")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Completion percentage
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(String(format: "%.0f%%", subject.completionPercentage))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 6)
                                    .opacity(0.2)
                                    .foregroundColor(.gray)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .frame(width: min(CGFloat(subject.completionPercentage) * geometry.size.width / 100, geometry.size.width), height: 6)
                                    .foregroundColor(.blue)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(width: 100, height: 6)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .padding(.leading, 5)
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Topics List (when expanded)
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                    
                    ForEach(subject.topics) { topic in
                        TopicRowView(
                            topic: topic,
                            onUpdateStatus: { status in
                                onUpdateStatus(topic.id, status)
                            }
                        )
                        
                        if topic.id != subject.topics.last?.id {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground).opacity(0.5))
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TopicRowView: View {
    let topic: Topic
    let onUpdateStatus: (TopicStatus) -> Void
    @State private var showingStatusPicker = false
    
    var body: some View {
        HStack {
            Text(topic.name)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                showingStatusPicker = true
            }) {
                HStack {
                    Circle()
                        .fill(Color(topic.status.color))
                        .frame(width: 10, height: 10)
                    
                    Text(topic.status.rawValue)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .actionSheet(isPresented: $showingStatusPicker) {
                ActionSheet(
                    title: Text("Durum Seç"),
                    buttons: TopicStatus.allCases.map { status in
                        .default(Text(status.rawValue)) {
                            onUpdateStatus(status)
                        }
                    } + [.cancel()]
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SubjectTrackingView(viewModel: SubjectTrackingViewModel())
}
