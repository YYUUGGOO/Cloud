import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var viewModel: TimerViewModel
    @AppStorage("standardTimer") private var standardTimer = 25
    @AppStorage("shortBreak") private var shortBreak = 5
    @AppStorage("longBreak") private var longBreak = 10

    var body: some View {
        VStack {
            Text(viewModel.timeString(from: viewModel.remainingTime))
                .font(.system(.largeTitle, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            Slider(value: $viewModel.timerDuration, in: 1...60, step: 1)
                .padding(.horizontal, 20)
                .onReceive(viewModel.$timerDuration) { _ in
                    viewModel.updateRemainingTime()
                }

            HStack {
                Button(action: viewModel.toggleTimer) {
                    Text(buttonText(for: viewModel.timerState))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: viewModel.resetTimer) {
                    Text("Reset")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)

            HStack {
                Button(action: { viewModel.setPresetTimer(minutes: standardTimer) }) {
                    Text("\(self.standardTimer) Min")
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { viewModel.setPresetTimer(minutes: shortBreak) }) {
                    Text("\(self.shortBreak) Min")
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { viewModel.setPresetTimer(minutes: longBreak) }) {
                    Text("\(self.longBreak) Min")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
            .padding(.vertical)

            HStack {
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 20)

                Spacer()

                Button("Detach Timer") {
                    openTimerWindow()
                }
                .buttonStyle(PlainButtonStyle())

                Button("Settings") {
                    openSettings()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
        }
        .frame(width: 300, height: 200)
    }

    private func buttonText(for state: TimerState) -> String {
        switch state {
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .stopped:
            return "Start"
        }
    }

    func openTimerWindow() {
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)

        let windowWidth: CGFloat = 200
        let windowHeight: CGFloat = 200

        let windowX = screenRect.midX - (windowWidth / 2)
        let windowY = screenRect.midY - (windowHeight / 2)

        let newWindow = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        newWindow.center()
        newWindow.setFrameAutosaveName("TimerWindow")
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating
        newWindow.contentView = NSHostingView(rootView: timerView(viewModel: viewModel))
        newWindow.makeKeyAndOrderFront(nil)
    }

    func openSettings() {
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 300
        let windowX = screenRect.midX - (windowWidth / 2)
        let windowY = screenRect.midY - (windowHeight / 2)

        let newWindow = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        newWindow.center()
        newWindow.setFrameAutosaveName("SettingsWindow")
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating
        newWindow.contentView = NSHostingView(rootView: settingsView(standardTimer: $standardTimer, shortBreak: $shortBreak, longBreak: $longBreak))
        newWindow.makeKeyAndOrderFront(nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: TimerViewModel(duration: 25))
    }
}
