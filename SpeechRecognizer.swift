import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = "" // Holds the recognized text
    @Published var isRecording = false // Track recording state for UI updates

    private var audioEngine = AVAudioEngine() // Handles audio input
    private var speechRecognizer = SFSpeechRecognizer() // Speech recognizer instance
    private var request = SFSpeechAudioBufferRecognitionRequest() // Handles audio data for recognition
    private var recognitionTask: SFSpeechRecognitionTask?

// MARK: - Request Authorization
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized.")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized.")
                default:
                    break
                }
            }
        }
    }

// MARK: - Start Recording
    func startRecording() {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            print("Speech recognition not authorized. Requesting authorization.")
            requestAuthorization()
            return
        }

        recognizedText = ""
        request = SFSpeechAudioBufferRecognitionRequest()
        isRecording = true

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer) // Append audio buffer for recognition
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine could not start: \(error.localizedDescription)")
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                self.stopRecording()
            }
        }
    }
// MARK: - Stop Recording
    func stopRecording(completion: ((String) -> Void)? = nil) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false

        // Return the final recognized text
        completion?(recognizedText)
    }
}
