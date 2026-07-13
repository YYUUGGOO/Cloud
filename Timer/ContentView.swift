import SwiftUI
import AppKit

private var detachedTimerWindowController: NSWindowController?

struct ContentView: View {
    @ObservedObject var viewModel: TimerViewModel

    @AppStorage("standardTimer") private var standardTimer = 25
    @AppStorage("shortBreak") private var shortBreak = 5
    @AppStorage("longBreak") private var longBreak = 10
    @AppStorage("useMouseControls") private var useMouseControls = false
    @AppStorage("zenMode") private var zenMode = false

    private let popoverWidth: CGFloat = 360

    var body: some View {
        ZStack {
            background

            VStack(spacing: 16) {
                timerHeader

                if shouldShowSetupControls {
                    durationControl
                }

                primaryControls

                if shouldShowSetupControls {
                    presetControls
                }

                footerControls
            }
            .padding(18)
            .animation(
                .snappy(duration: 0.25),
                value: shouldShowSetupControls
            )
        }
        .frame(width: popoverWidth)
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: shouldShowSetupControls) { _, _ in
            guard let delegate = NSApp.delegate as? AppDelegate else {
                return
            }

            delegate.animatePopoverToFitContent()
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.10),
                    Color.clear,
                    Color.primary.opacity(0.025)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Timer header

    private var timerHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Label(timerStateTitle, systemImage: timerStateIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(viewModel.timerDuration)) MIN")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            timerDisplay
        }
        .padding(18)
        .modifier(
            GlassPanelModifier(
                cornerRadius: 26,
                interactive: false
            )
        )
    }

    @ViewBuilder
    private var timerDisplay: some View {
        if useMouseControls {
            MouseCommandSurface(
                onSingleClick: {
                    viewModel.toggleTimer()
                },
                onTripleClick: {
                    viewModel.resetTimer()
                }
            ) {
                timerText
            }
        } else {
            timerText
        }
    }

    private var timerText: some View {
        Text(viewModel.timeString(from: viewModel.remainingTime))
            .font(
                .system(
                    size: 54,
                    weight: .medium,
                    design: .rounded
                )
            )
            .monospacedDigit()
            .contentTransition(.numericText())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .accessibilityLabel("Remaining time")
            .accessibilityValue(
                viewModel.timeString(
                    from: viewModel.remainingTime
                )
            )
    }

    // MARK: - Duration

    private var durationControl: some View {
        VStack(spacing: 10) {
            HStack {
                Label("Duration", systemImage: "timer")
                    .font(.system(size: 13, weight: .medium))

                Spacer()

                DurationValueEditor(
                    value: $viewModel.timerDuration,
                    range: 1...60
                )
            }

            Slider(
                value: $viewModel.timerDuration,
                in: 1...60,
                step: 1
            ) {
                Text("Timer duration")
            } minimumValueLabel: {
                Text("1")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text("60")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .tint(.accentColor)
            .onChange(of: viewModel.timerDuration) { _, _ in
                guard
                    viewModel.timerState == .stopped ||
                    viewModel.timerState == .paused
                else {
                    return
                }

                viewModel.updateRemainingTime()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .modifier(
            GlassPanelModifier(
                cornerRadius: 20,
                interactive: true
            )
        )
    }

    // MARK: - Primary controls

    @ViewBuilder
    private var primaryControls: some View {
        if !useMouseControls {
            if #available(macOS 26.0, *) {
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        Button(action: viewModel.toggleTimer) {
                            Label(
                                primaryActionTitle,
                                systemImage: primaryButtonIcon
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                        }
                        .buttonStyle(.glassProminent)
                        .keyboardShortcut(.space, modifiers: [])

                        Button(action: viewModel.resetTimer) {
                            Label(
                                "Reset",
                                systemImage: "arrow.counterclockwise"
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                        }
                        .buttonStyle(.glass)
                    }
                }
            } else {
                HStack(spacing: 10) {
                    Button(action: viewModel.toggleTimer) {
                        Label(
                            primaryActionTitle,
                            systemImage: primaryButtonIcon
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.space, modifiers: [])

                    Button(action: viewModel.resetTimer) {
                        Label(
                            "Reset",
                            systemImage: "arrow.counterclockwise"
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    // MARK: - Presets

    private var presetControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Presets", systemImage: "clock.arrow.circlepath")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 9) {
                PresetButton(
                    title: "Focus",
                    minutes: standardTimer,
                    systemImage: "brain.head.profile",
                    isSelected: selectedPreset == standardTimer
                ) {
                    applyPreset(standardTimer)
                }

                PresetButton(
                    title: "Short",
                    minutes: shortBreak,
                    systemImage: "cup.and.saucer.fill",
                    isSelected: selectedPreset == shortBreak
                ) {
                    applyPreset(shortBreak)
                }

                PresetButton(
                    title: "Long",
                    minutes: longBreak,
                    systemImage: "sparkles",
                    isSelected: selectedPreset == longBreak
                ) {
                    applyPreset(longBreak)
                }
            }
        }
    }

    // MARK: - Footer

    private var footerControls: some View {
        HStack(spacing: 8) {
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .help("Quit Timer")
            .modifier(SecondaryGlassButtonModifier())

            Spacer()

            Button {
                openTimerWindow()
            } label: {
                Label("Detach", systemImage: "macwindow")
            }
            .help("Open the timer in a separate window")
            .modifier(SecondaryGlassButtonModifier())

            if #available(macOS 14.0, *) {
                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }
                .help("Open Timer Settings")
                .modifier(SecondaryGlassButtonModifier())
            }
        }
        .padding(.top, 2)
    }

    // MARK: - Derived state

    private var shouldShowSetupControls: Bool {
        !zenMode || viewModel.timerState != .running
    }

    private var selectedPreset: Int? {
        let duration = Int(viewModel.timerDuration.rounded())

        if duration == standardTimer {
            return standardTimer
        }

        if duration == shortBreak {
            return shortBreak
        }

        if duration == longBreak {
            return longBreak
        }

        return nil
    }

    private var timerStateTitle: String {
        switch viewModel.timerState {
        case .running:
            return "Timer Running"

        case .paused:
            return "Timer Paused"

        case .stopped:
            return "Ready to Focus"
        }
    }

    private var timerStateIcon: String {
        switch viewModel.timerState {
        case .running:
            return "circle.fill"

        case .paused:
            return "pause.circle.fill"

        case .stopped:
            return "circle.dotted"
        }
    }

    private var primaryButtonIcon: String {
        switch viewModel.timerState {
        case .running:
            return "pause.fill"

        case .paused:
            return "play.fill"

        case .stopped:
            return "play.fill"
        }
    }

    private var primaryActionTitle: String {
        switch viewModel.timerState {
        case .running:
            return "Pause"

        case .paused:
            return "Resume"

        case .stopped:
            return "Start"
        }
    }

    // MARK: - Actions

    private func applyPreset(_ minutes: Int) {
        withAnimation(.snappy(duration: 0.25)) {
            viewModel.setPresetTimer(minutes: minutes)
        }
    }

    // MARK: - Detached window

    private func openTimerWindow() {
        closePopover()

        NSApp.activate(ignoringOtherApps: true)

        if let controller = detachedTimerWindowController,
           let existingWindow = controller.window {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }

        let windowSize = NSSize(
            width: 240,
            height: 240
        )

        let hostingController = NSHostingController(
            rootView: timerView(viewModel: viewModel)
        )

        let window = NSWindow(
            contentRect: NSRect(
                origin: .zero,
                size: windowSize
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )

        window.title = "Timer"
        window.center()
        window.setFrameAutosaveName("TimerWindow")
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.collectionBehavior = [
            .moveToActiveSpace,
            .fullScreenAuxiliary
        ]
        let minimumContentSize = timerView.minimumContentSize
        window.contentMinSize = minimumContentSize
        window.minSize = window.frameRect(
            forContentRect: NSRect(
                origin: .zero,
                size: minimumContentSize
            )
        ).size
        window.contentViewController = hostingController

        let controller = NSWindowController(window: window)
        detachedTimerWindowController = controller

        controller.showWindow(nil)
        window.makeKeyAndOrderFront(nil)
    }

    private func closePopover() {
        guard
            let delegate = NSApp.delegate as? AppDelegate,
            let popover = delegate.popover,
            popover.isShown
        else {
            return
        }

        popover.performClose(nil)
    }
}

private struct DurationValueEditor: View {
    @Binding var value: Double

    let range: ClosedRange<Int>

    @State private var isEditing = false
    @State private var inputText = ""
    @FocusState private var inputIsFocused: Bool

    var body: some View {
        Group {
            if isEditing {
                HStack(spacing: 4) {
                    TextField("", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .frame(width: 46)
                        .focused($inputIsFocused)
                        .onChange(of: inputText) { _, newValue in
                            sanitizeInput(newValue)
                        }
                        .onSubmit {
                            commitInput()
                        }
                        .onExitCommand {
                            cancelInput()
                        }
                        .onChange(of: inputIsFocused) { _, focused in
                            if !focused && isEditing {
                                commitInput()
                            }
                        }

                    Text("minutes")
                }
            } else {
                Text("\(Int(value)) minutes")
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        beginEditing()
                    }
                    .help("Double-click to enter a duration")
            }
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.secondary)
        .monospacedDigit()
        .accessibilityLabel("Timer duration")
        .accessibilityValue("\(Int(value)) minutes")
    }

    private func beginEditing() {
        inputText = String(Int(value))
        isEditing = true

        DispatchQueue.main.async {
            inputIsFocused = true
        }
    }

    private func sanitizeInput(_ newValue: String) {
        let digits = newValue.filter { "0123456789".contains($0) }
        let maximumLength = String(range.upperBound).count
        let sanitized = String(digits.prefix(maximumLength))

        if sanitized != newValue {
            inputText = sanitized
        }
    }

    private func commitInput() {
        guard let enteredValue = Int(inputText) else {
            cancelInput()
            return
        }

        value = Double(
            min(
                range.upperBound,
                max(range.lowerBound, enteredValue)
            )
        )
        isEditing = false
        inputIsFocused = false
    }

    private func cancelInput() {
        inputText = String(Int(value))
        isEditing = false
        inputIsFocused = false
    }
}

private struct MouseCommandSurface<Content: View>: View {
    let onSingleClick: () -> Void
    let onTripleClick: () -> Void
    let content: Content

    init(
        onSingleClick: @escaping () -> Void,
        onTripleClick: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onSingleClick = onSingleClick
        self.onTripleClick = onTripleClick
        self.content = content()
    }

    var body: some View {
        content
            .overlay {
                MouseClickRepresentable(
                    onSingleClick: onSingleClick,
                    onTripleClick: onTripleClick
                )
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Timer controls")
            .accessibilityHint(
                "Click once to start, pause, or resume the timer. Triple-click to reset it."
            )
    }
}

private struct MouseClickRepresentable: NSViewRepresentable {
    let onSingleClick: () -> Void
    let onTripleClick: () -> Void

    func makeNSView(context: Context) -> MouseClickNSView {
        let view = MouseClickNSView()
        view.onSingleClick = onSingleClick
        view.onTripleClick = onTripleClick
        return view
    }

    func updateNSView(
        _ nsView: MouseClickNSView,
        context: Context
    ) {
        nsView.onSingleClick = onSingleClick
        nsView.onTripleClick = onTripleClick
    }
}

private final class MouseClickNSView: NSView {
    var onSingleClick: (() -> Void)?
    var onTripleClick: (() -> Void)?

    private var pendingSingleClick: DispatchWorkItem?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        pendingSingleClick?.cancel()

        if event.clickCount == 3 {
            pendingSingleClick = nil
            onTripleClick?()
            return
        }

        guard event.clickCount == 1 || event.clickCount == 2 else {
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.onSingleClick?()
        }
        pendingSingleClick = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + NSEvent.doubleClickInterval,
            execute: workItem
        )
    }

    override func acceptsFirstMouse(
        for event: NSEvent?
    ) -> Bool {
        true
    }
}

// MARK: - Preset button

private struct PresetButton: View {
    let title: String
    let minutes: Int
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Group {
            if #available(macOS 26.0, *) {
                if isSelected {
                    Button(action: action) {
                        buttonLabel
                    }
                    .buttonStyle(GlassProminentButtonStyle())
                } else {
                    Button(action: action) {
                        buttonLabel
                    }
                    .buttonStyle(GlassButtonStyle())
                }
            } else {
                if isSelected {
                    Button(action: action) {
                        buttonLabel
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: action) {
                        buttonLabel
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .accessibilityLabel("\(title), \(minutes) minutes")
    }

    private var buttonLabel: some View {
        VStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))

            Text("\(minutes)")
                .font(
                    .system(
                        size: 17,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .monospacedDigit()

            Text(title)
                .font(.caption2)
                .foregroundStyle(
                    isSelected ? .primary : .secondary
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 62)
        .contentShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }
}
// MARK: - Glass panel modifier

private struct GlassPanelModifier: ViewModifier {
    let cornerRadius: CGFloat
    let interactive: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            if interactive {
                content
                    .glassEffect(
                        .regular.interactive(),
                        in: RoundedRectangle(
                            cornerRadius: cornerRadius,
                            style: .continuous
                        )
                    )
            } else {
                content
                    .glassEffect(
                        .regular,
                        in: RoundedRectangle(
                            cornerRadius: cornerRadius,
                            style: .continuous
                        )
                    )
            }
        } else {
            content
                .background {
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .strokeBorder(
                        Color.primary.opacity(0.08)
                    )
                }
        }
    }
}

// MARK: - Secondary button modifier

private struct SecondaryGlassButtonModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
        } else {
            content
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView(
        viewModel: TimerViewModel(duration: 25)
    )
    .preferredColorScheme(.dark)
}
