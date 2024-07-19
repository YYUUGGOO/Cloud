import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var viewModel: TimerViewModel!
    var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize the view model with a 25-minute duration
        viewModel = TimerViewModel(duration: 25)
        
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = ""
            button.action = #selector(togglePopover(_:))
            //print("Status item button created") // Debug log
        } else {
            //print("Failed to create status item button") // Debug log
        }

        // Create the popover
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: ContentView(viewModel: viewModel))
        popover.behavior = .transient

        // Observe the remaining time to update the status bar title
        viewModel.$remainingTime
            .receive(on: RunLoop.main)
            .sink { [weak self] remainingTime in
                self?.updateStatusBarTitle()
            }
            .store(in: &cancellables)
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    func updateStatusBarTitle() {
        if let button = statusItem.button {
            let minutes = viewModel.remainingTime / 60
            let seconds = viewModel.remainingTime % 60
            let title = String(format: "%02d:%02d", minutes, seconds)
            
            // Create an attributed string with monospace font
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            
            button.attributedTitle = attributedTitle
            //print("Updated status bar title to \(button.title)") // Debug log
        }
    }
}
