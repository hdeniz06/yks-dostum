import Foundation
import Combine

class GeminiService {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"
    
    init() {
        // Get API key from environment variables
        if let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
            self.apiKey = apiKey
        } else {
            // Fallback to the hardcoded key if environment variable is not available
            // Note: In a production app, you should handle this more securely
            self.apiKey = "AIzaSyDSf0oCqhLL5A-Z32HrNu1N9JUIkXze66k"
            print("Warning: Using hardcoded API key. Consider setting up environment variables properly.")
        }
    }
    
    func generateResponse(prompt: String) -> AnyPublisher<String, Error> {
        // Create the URL with API key
        guard var urlComponents = URLComponents(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Add API key as a query parameter
        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        guard let url = urlComponents.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Create the request body
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 800
            ],
            "safetySettings": [
                [
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_NONE"
                ],
                [
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_NONE"
                ],
                [
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_NONE"
                ],
                [
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_NONE"
                ]
            ]
        ]
        
        // Convert the request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"])).eraseToAnyPublisher()
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        request.httpBody = jsonData
        
        print("Sending request to: \(url.absoluteString)")
        
        // Send the request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid HTTP response")
                    throw URLError(.badServerResponse)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let statusCode = httpResponse.statusCode
                    let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                    print("API Error: Status \(statusCode), Response: \(responseString)")
                    
                    // Log more details for debugging
                    print("Request URL: \(httpResponse.url?.absoluteString ?? "unknown")")
                    print("Request Headers: \(httpResponse.allHeaderFields)")
                    
                    throw NSError(domain: NSURLErrorDomain, 
                                 code: statusCode, 
                                 userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(statusCode)"])
                }
                
                print("Successful API response with status: \(httpResponse.statusCode)")
                return data
            }
            .decode(type: GeminiResponse.self, decoder: JSONDecoder())
            .map { response -> String in
                // Extract the text from the response
                if let content = response.candidates?.first?.content,
                   let text = content.parts?.first?.text {
                    return text
                } else {
                    return "Üzgünüm, bir cevap oluşturamadım. Lütfen tekrar deneyin."
                }
            }
            .catch { error -> AnyPublisher<String, Error> in
                print("Error in Gemini API request: \(error.localizedDescription)")
                return Just("Üzgünüm, bir hata oluştu: \(error.localizedDescription)")
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // This method is now unused as we're sending the prompt directly
    // We'll use the system message in the ViewModel instead
    private func formatPrompt(prompt: String) -> String {
        return prompt
    }
}

// MARK: - Response Models
struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let promptFeedback: PromptFeedback?
}

struct Candidate: Codable {
    let content: Content?
    let finishReason: String?
    let index: Int?
    let safetyRatings: [SafetyRating]?
}

struct Content: Codable {
    let parts: [Part]?
    let role: String?
}

struct Part: Codable {
    let text: String?
}

struct SafetyRating: Codable {
    let category: String?
    let probability: String?
}

struct PromptFeedback: Codable {
    let safetyRatings: [SafetyRating]?
}
