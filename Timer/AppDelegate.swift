import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var viewModel: TimerViewModel!
    var timerHostingController: NSHostingController<ContentView>!
    private var popoverResizeTimer: Timer?
    var cancellables: Set<AnyCancellable> = []
    var settingsWindowController: NSWindowController?
    var didMakeRegularForSettings = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Prevent app from showing in Dock and displaying windows
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize the timer with the saved Focus preset.
        let defaults = UserDefaults.standard
        let focusDuration = defaults.object(forKey: "standardTimer") == nil
            ? 25
            : defaults.double(forKey: "standardTimer")
        viewModel = TimerViewModel(duration: focusDuration)
        
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
        timerHostingController = NSHostingController(
            rootView: ContentView(viewModel: viewModel)
        )
        timerHostingController.sizingOptions = []

        popover = NSPopover()
        popover.animates = true
        popover.contentViewController = timerHostingController
        popover.contentSize = timerHostingController.sizeThatFits(
            in: NSSize(width: 360, height: 10_000)
        )
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
                stopPopoverResizeAnimation()
                popover.performClose(sender)
            } else {
                popover.contentSize = timerHostingController.sizeThatFits(
                    in: NSSize(width: 360, height: 10_000)
                )
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

    func animatePopoverToFitContent() {
        guard
            popover.isShown,
            let timerHostingController
        else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard
                let self,
                self.popover.isShown
            else {
                return
            }

            let targetSize = timerHostingController.sizeThatFits(
                in: NSSize(width: 360, height: 10_000)
            )

            guard targetSize != self.popover.contentSize else {
                self.stopPopoverResizeAnimation()
                return
            }

            self.popoverResizeTimer?.invalidate()
            self.popover.animates = false

            let startingSize = self.popover.contentSize
            let startTime = Date.timeIntervalSinceReferenceDate
            let duration = 0.42

            let resizeTimer = Timer(
                timeInterval: 1.0 / 60.0,
                repeats: true
            ) { [weak self] timer in
                guard
                    let self,
                    self.popover.isShown
                else {
                    timer.invalidate()
                    self?.popover.animates = true
                    return
                }

                let elapsed = Date.timeIntervalSinceReferenceDate - startTime
                let progress = min(max(elapsed / duration, 0), 1)
                let easedProgress = progress * progress * (3 - 2 * progress)

                self.popover.contentSize = NSSize(
                    width: startingSize.width
                        + (targetSize.width - startingSize.width)
                        * easedProgress,
                    height: startingSize.height
                        + (targetSize.height - startingSize.height)
                        * easedProgress
                )

                if progress >= 1 {
                    timer.invalidate()
                    self.popover.contentSize = targetSize
                    self.popover.animates = true
                    self.popoverResizeTimer = nil
                }
            }

            self.popoverResizeTimer = resizeTimer
            RunLoop.main.add(resizeTimer, forMode: .common)
        }
    }

    private func stopPopoverResizeAnimation() {
        popoverResizeTimer?.invalidate()
        popoverResizeTimer = nil
        popover?.animates = true
    }

    func showSettings() {
        // Close the popover so the window isn't blocked and to avoid transient focus issues
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        }

        // If we already have a Settings window, just bring it to front
        if let controller = settingsWindowController, let window = controller.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // For menu bar apps, temporarily switch to regular so windows can appear reliably
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
            didMakeRegularForSettings = true
        }

        NSApp.activate(ignoringOtherApps: true)

        // Present SettingsView in a retained window controller
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let windowWidth: CGFloat = 420
        let windowHeight: CGFloat = 360
        let windowX = screenRect.midX - (windowWidth / 2)
        let windowY = screenRect.midY - (windowHeight / 2)

        let hosting = NSHostingController(rootView: TimerSettingsView())
        let window = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("SettingsWindowFallback")
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.moveToActiveSpace]
        window.level = .floating
        window.contentViewController = hosting
        window.delegate = self

        let controller = NSWindowController(window: window)
        self.settingsWindowController = controller
        controller.showWindow(nil)
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindowController?.window {
            settingsWindowController = nil
            if didMakeRegularForSettings {
                NSApp.setActivationPolicy(.accessory)
                didMakeRegularForSettings = false
            }
        }
    }
}
