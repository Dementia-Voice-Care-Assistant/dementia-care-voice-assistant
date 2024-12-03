import Foundation

enum APIError: Error {
    case invalidURL
}

struct APIRequest: Codable {
    let messages: [[String: String]]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool
}

class APIClient: NSObject, URLSessionDataDelegate {
    static let shared = APIClient()

    private var accumulatedData = Data()
    private var streamData: ((String) -> Void)?
    private var completed: ((Result<String, Error>) -> Void)?
    
// MARK: - Send Prompt
    func sendPrompt(_ prompt: String, streamData: @escaping (String) -> Void, completed: @escaping (Result<String, Error>) -> Void) {
        self.streamData = streamData
        self.completed = completed

        let baseURL = ""

        guard let url = URL(string: "\(baseURL)/v1/chat/completions") else {
            completed(.failure(APIError.invalidURL))
            return
        }

        let apiRequest = APIRequest(
            messages: [["role": "user", "content": prompt]],
            temperature: 0.7,
            maxTokens: 1000000,
            stream: true
        )

        let sessionConfig = URLSessionConfiguration.default
        // Assigning self as the delegate and using main queue for delegate callbacks
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(apiRequest)
            request.httpBody = jsonData
        } catch {
            completed(.failure(error))
            return
        }
        let task = session.dataTask(with: request)
        task.resume()
    }

    // MARK: - URL Session
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let chunk = String(data: data, encoding: .utf8)
        let trimmedChunk = chunk?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "data: ", with: "")

        if trimmedChunk == "[DONE]" {
            return
        }

        if let jsonData = trimmedChunk?.data(using: .utf8) {
            do {
                if let jsonChunk = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                   let choices = jsonChunk["choices"] as? [[String: Any]],
                   let delta = choices.first?["delta"] as? [String: Any],
                   let content = delta["content"] as? String {

                    DispatchQueue.main.async {
                        self.streamData?(content)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    // MARK: - URL Session for Final Stream
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completed?(.failure(error))
        } else {
            completed?(.success(""))
        }

        accumulatedData = Data()
        streamData = nil
        completed = nil
    }
}
