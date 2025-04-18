import SwiftUI
import UIKit

struct AIAssistantView: View {
    @ObservedObject var viewModel: AIAssistantViewModel
    @FocusState private var isInputFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    // Function to dismiss keyboard
    private func dismissKeyboard() {
        isInputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        // Setup keyboard observers
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return keyboardFrame.height
                }
                return 0
            }
        
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }
            
        VStack(spacing: 0) {
            // Chat Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    // Add tap gesture to dismiss keyboard when tapping on the scroll view
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissKeyboard()
                        }
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isTyping {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                
                                Text("YKS Asistanı yazıyor...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 8)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isTyping) { _ in
                    withAnimation {
                        scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Input Bar
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 15) {
                    ZStack {
                        TextField("Bir soru sor...", text: $viewModel.inputText)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .focused($isInputFocused)
                            .submitLabel(.send)
                            .autocapitalization(.sentences)
                            .disableAutocorrection(false)
                            .onSubmit {
                                if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isTyping {
                                    viewModel.sendMessage()
                                }
                            }
                    }
                    .frame(minHeight: 44)
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTyping)
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
                .padding(.bottom, keyboardHeight > 0 ? 10 : 0)
                .background(Color(UIColor.systemBackground))
                .onTapGesture {
                    isInputFocused = true
                }
            }
            // Proper keyboard spacing with SafeArea consideration
            .padding(.bottom, keyboardHeight > 0 ? max(keyboardHeight - 15, 0) : 0)
        }
        .onReceive(keyboardWillShow) { height in
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = height
            }
        }
        .onReceive(keyboardWillHide) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = 0
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.sender == .assistant {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 5) {
                Text(message.content)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.sender == .user ? Color.blue : Color(UIColor.secondarySystemBackground))
                    )
                    .foregroundColor(message.sender == .user ? .white : .primary)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.sender == .user {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
        .padding(.horizontal, 10)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AIAssistantView(viewModel: AIAssistantViewModel())
}
