import Foundation
import Combine
import AVFoundation

class TimerViewModel: ObservableObject {
    @Published var remainingTime: Int
    @Published var timerDuration: Double
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    init(duration: Double) {
        self.remainingTime = Int(duration * 60)
        self.timerDuration = duration
        prepareAlarmSound()
    }
    func toggleTimer(){
        isRunning.toggle()
        print(isRunning)
        if isRunning == true {
            startTimer()
        } else {
            pauseTimer()
        }
    }
    
    func pauseTimer(){
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            // Directly restore the timer without adjusting `timerDuration`
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.resetTimer()
                    self.isRunning.toggle()
                    self.timer?.invalidate()
                    self.playAlarmSound()
                }
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.resetTimer()
                self.isRunning.toggle()
                self.timer?.invalidate()
                self.playAlarmSound()
            }
        }
    }

    func resetTimer() {
        isRunning = false
        timer?.invalidate()
        updateRemainingTime()
    }

    func setPresetTimer(minutes: Int) {
        timer?.invalidate()
        timerDuration = Double(minutes)
        updateRemainingTime()
    }

    func updateRemainingTime() {
        remainingTime = Int(timerDuration) * 60
    }

    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func prepareAlarmSound() {
        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
    }

    func playAlarmSound() {
        audioPlayer?.play()
    }
    

}
