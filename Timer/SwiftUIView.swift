import SwiftUI

struct TimerView: View {
    @State private var timeRemaining = 272 // Initial time in seconds (4 minutes and 32 seconds)
    @State private var isPaused = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(formatTime(timeRemaining))
                    .font(.headline)
                    .padding(4)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(5)
            }
            .padding(.horizontal)
            
            // Slider to set the time
            Slider(value: Binding(
                get: {
                    Double(timeRemaining)
                },
                set: { newValue in
                    timeRemaining = Int(newValue)
                }
            ), in: 0...300, step: 1)
            .padding(.horizontal)
            
            HStack {
                Button(action: cancel) {
                    Text("cancel")
                }
                Spacer()
                Button(action: restart) {
                    Text("restart")
                }
                Spacer()
                Menu {
                    Button(action: {}) {
                        Text("Option 1")
                    }
                    Button(action: {}) {
                        Text("Option 2")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            .padding(.horizontal)
            
            Button(action: togglePause) {
                Text(isPaused ? "resume" : "pause")
            }
            
            Text(formatTime(timeRemaining))
                .font(.largeTitle)
                .padding()
        }
        .onAppear(perform: startTimer)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 && !isPaused {
                timeRemaining -= 1
            }
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timeRemaining = 0
    }
    
    func restart() {
        timer?.invalidate()
        timeRemaining = 272 // Reset to initial value
        isPaused = false
        startTimer()
    }
    
    func togglePause() {
        isPaused.toggle()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
