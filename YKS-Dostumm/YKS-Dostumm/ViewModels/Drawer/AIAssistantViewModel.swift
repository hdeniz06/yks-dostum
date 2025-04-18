import Foundation
import Combine

class AIAssistantViewModel: BaseViewModelImpl {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isTyping: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let geminiService = GeminiService()
    
    override init() {
        super.init()
        loadInitialMessages()
    }
    
    private func loadInitialMessages() {
        // Add welcome message from the assistant
        let welcomeMessage = ChatMessage(
            id: UUID(),
            sender: .assistant,
            content: "Merhaba! Ben YKS Asistanın. Sana YKS hazırlık sürecinde yardımcı olmak için buradayım. Ders çalışma teknikleri, konu anlatımı, soru çözümü veya motivasyon konularında sorularını yanıtlayabilirim. Nasıl yardımcı olabilirim?",
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(
            id: UUID(),
            sender: .user,
            content: inputText,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Clear input
        let userInput = inputText
        inputText = ""
        
        // Set AI thinking state
        isTyping = true
        
        // Format the prompt with system instructions
        let formattedPrompt = formatPromptWithSystemInstructions(userInput)
        
        // Call Gemini API
        geminiService.generateResponse(prompt: formattedPrompt)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error generating response: \(error.localizedDescription)")
                    self?.handleAPIError()
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // Add AI response
                let assistantMessage = ChatMessage(
                    id: UUID(),
                    sender: .assistant,
                    content: response,
                    timestamp: Date()
                )
                self.messages.append(assistantMessage)
                self.isTyping = false
            })
            .store(in: &cancellables)
    }
    
    // Fallback method in case the API fails
    private func handleAPIError() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let errorMessage = ChatMessage(
                id: UUID(),
                sender: .assistant,
                content: "Üzgünüm, şu anda yanıt oluşturamıyorum. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.",
                timestamp: Date()
            )
            self.messages.append(errorMessage)
            self.isTyping = false
        }
    }
    
    // Format the user prompt with system instructions
    private func formatPromptWithSystemInstructions(_ userPrompt: String) -> String {
        return """
        Sen YKS sınavına hazırlanan Türk öğrencilere yardımcı olan bir eğitim asistanısın. 
        Adın "YKS Asistanı". Türkçe yanıt ver.
        
        Şu konularda yardımcı olabilirsin:
        - YKS sınavı hakkında bilgi (TYT ve AYT)
        - Ders çalışma teknikleri ve verimli çalışma yöntemleri
        - Spesifik dersler hakkında bilgi ve ipuçları (Matematik, Fizik, Kimya, Biyoloji, Türkçe, Tarih, Coğrafya, vb.)
        - Motivasyon ve stres yönetimi
        - Sınav stratejileri
        
        Yanıtların kısa, öz ve anlaşılır olmalı. Öğrencilere yardımcı olacak pratik tavsiyeler ver.
        Öğrencinin sorusu: \(userPrompt)
        """
    }
}

// Models used by the AI Assistant
enum MessageSender {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    var id: UUID
    var sender: MessageSender
    var content: String
    var timestamp: Date
}
