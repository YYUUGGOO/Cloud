import SwiftUI
import LaunchAtLogin

struct TimerSettingsView: View {
    @AppStorage("standardTimer") private var standardTimer = 25
    @AppStorage("shortBreak") private var shortBreak = 5
    @AppStorage("longBreak") private var longBreak = 10
    @AppStorage("useMouseControls") private var useMouseControls = false
    @AppStorage("zenMode") private var zenMode = false
    @State private var selectedTab = SettingsTab.general

    var body: some View {
        VStack(spacing: 0) {
            header

            Picker("Settings section", selection: $selectedTab) {
                Label("General", systemImage: "gearshape")
                    .tag(SettingsTab.general)

                Label(
                    "Presets",
                    systemImage: "clock.arrow.circlepath"
                )
                .tag(SettingsTab.presets)

                Label("About", systemImage: "info.circle")
                    .tag(SettingsTab.about)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Divider()

            switch selectedTab {
            case .general:
                ScrollView {
                    generalSection
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .padding(20)
                }

            case .presets:
                ScrollView {
                    presetsSection
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .padding(20)
                }

            case .about:
                ScrollView {
                    aboutSection
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                        .padding(20)
                }
            }
        }
        .frame(
            minWidth: 520,
            idealWidth: 560,
            minHeight: 500,
            idealHeight: 560
        )
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: "timer")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.tint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Timer Settings")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Customize your presets and timer behavior")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17)
    }

    // MARK: - General

    private var generalSection: some View {
        SettingsSection(
            title: "General",
            systemImage: "gearshape"
        ) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "power")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Launch at Login")
                            .font(.body)

                        Text("Start the timer automatically after signing in.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    LaunchAtLogin.Toggle()
                        .labelsHidden()
                        .help("Automatically launch the app when you log in.")
                }
                .padding(14)

                Divider()
                    .padding(.leading, 50)

                HStack(spacing: 12) {
                    Image(systemName: "computermouse")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Timer Controls")
                            .font(.body)

                        Text("Choose how you start, pause, and reset the timer. \"Mouse\" enables to controll the timer with mouseclicks. Single click to start and pause, tripple click to reset the timer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Picker("Timer Controls", selection: $useMouseControls) {
                        Text("Buttons").tag(false)
                        Text("Mouse").tag(true)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    .help("Mouse mode: click once to start or pause, and triple-click to reset.")
                }
                .padding(14)

                Divider()
                    .padding(.leading, 50)

                HStack(spacing: 12) {
                    Image(systemName: "leaf")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zen Mode")
                            .font(.body)

                        Text("Hide duration and presets after the timer starts.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Toggle("Zen Mode", isOn: $zenMode)
                        .labelsHidden()
                        .help("Hide setup controls while a timer is active.")
                }
                .padding(14)
            }
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.primary.opacity(0.08))
            }
        }
    }

    // MARK: - Presets

    private var presetsSection: some View {
        SettingsSection(
            title: "Timer Presets",
            systemImage: "clock.arrow.circlepath"
        ) {
            HStack(alignment: .top, spacing: 14) {
                CircularPresetCard(
                    title: "Focus",
                    subtitle: "Deep work",
                    systemImage: "brain.head.profile",
                    tint: .accentColor,
                    value: $standardTimer,
                    range: 1...60
                )

                CircularPresetCard(
                    title: "Short Break",
                    subtitle: "Quick rest",
                    systemImage: "cup.and.saucer.fill",
                    tint: .green,
                    value: $shortBreak,
                    range: 1...30
                )

                CircularPresetCard(
                    title: "Long Break",
                    subtitle: "Recharge",
                    systemImage: "bed.double.fill",
                    tint: .indigo,
                    value: $longBreak,
                    range: 1...60
                )
            }

            Text("Drag a dial or double-click its number to enter a duration.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 2)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        SettingsSection(
            title: "About Cloud",
            systemImage: "info.circle"
        ) {
            VStack(spacing: 18) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 82)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text("Cloud")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(versionDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Text(
                    "A free, minimal Pomodoro timer for macOS that lives in the menu bar. Cloud includes custom presets, focused timer controls, and a detachable timer window—without ads or data collection."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

                HStack(spacing: 8) {
                    Label("Open Source", systemImage: "curlybraces")
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text("GNU GPLv3")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Link(
                    destination: URL(
                        string: "https://github.com/YYUUGGOO/Cloud"
                    )!
                ) {
                    Label(
                        "View Source on GitHub",
                        systemImage: "arrow.up.right.square"
                    )
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .background {
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(Color(nsColor: .controlBackgroundColor))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .strokeBorder(.primary.opacity(0.08))
            }
        }
    }

    private var versionDescription: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String
            ?? "Unknown"
        let build = info?["CFBundleVersion"] as? String
            ?? "Unknown"

        return "Version \(version) (Build \(build))"
    }
}

private enum SettingsTab: Hashable {
    case general
    case presets
    case about
}

// MARK: - Preset Card

private struct CircularPresetCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    @Binding var value: Int

    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            CircularTimeInput(
                value: $value,
                range: range,
                tint: tint
            )
            .frame(width: 120, height: 120)

            HStack(spacing: 12) {
                DialButton(
                    systemImage: "minus",
                    disabled: value <= range.lowerBound
                ) {
                    changeValue(by: -1)
                }

                Text("\(value) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(minWidth: 44)

                DialButton(
                    systemImage: "plus",
                    disabled: value >= range.upperBound
                ) {
                    changeValue(by: 1)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.primary.opacity(0.08))
        }
    }

    private func changeValue(by amount: Int) {
        value = min(
            range.upperBound,
            max(range.lowerBound, value + amount)
        )
    }
}

// MARK: - Circular Time Input

private struct CircularTimeInput: View {
    @Binding var value: Int

    let range: ClosedRange<Int>
    let tint: Color

    @State private var isDragging = false
    @State private var isEditing = false
    @State private var inputText = ""

    @FocusState private var inputIsFocused: Bool

    private let lineWidth: CGFloat = 9
    private let dialInset: CGFloat = 8

    private var progress: Double {
        let span = range.upperBound - range.lowerBound

        guard span > 0 else {
            return 0
        }

        return Double(value - range.lowerBound) / Double(span)
    }

    private var maximumInputLength: Int {
        String(range.upperBound).count
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let dialSize = CGSize(width: size, height: size)
            let radius = size / 2 - dialInset - lineWidth / 2
            let angle = Angle.degrees(progress * 360 - 90)

            ZStack {
                dialSurface(
                    size: size,
                    radius: radius,
                    angle: angle
                )
                .contentShape(Circle())
                .gesture(dragGesture(in: dialSize))

                centerEditor
            }
            .frame(width: size, height: size)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Timer duration")
            .accessibilityValue("\(value) minutes")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    changeValue(by: 1)

                case .decrement:
                    changeValue(by: -1)

                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: Dial appearance

    private func dialSurface(
        size: CGFloat,
        radius: CGFloat,
        angle: Angle
    ) -> some View {
        ZStack {
            tickMarks(size: size)

            Circle()
                .stroke(
                    Color.primary.opacity(0.08),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .padding(dialInset)

            Circle()
                .trim(
                    from: 0,
                    to: max(progress, 0.001)
                )
                .stroke(
                    AngularGradient(
                        colors: [
                            tint.opacity(0.45),
                            tint
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .padding(dialInset)
                .animation(
                    isDragging ? nil : .snappy(duration: 0.2),
                    value: value
                )

            knob(
                radius: radius,
                angle: angle
            )
        }
    }

    private func tickMarks(size: CGFloat) -> some View {
        let tickRadius = size / 2 - 1

        return ZStack {
            ForEach(0..<24, id: \.self) { index in
                Capsule()
                    .fill(
                        index % 6 == 0
                            ? Color.primary.opacity(0.25)
                            : Color.primary.opacity(0.09)
                    )
                    .frame(
                        width: index % 6 == 0 ? 2 : 1,
                        height: index % 6 == 0 ? 5 : 3
                    )
                    .offset(y: -tickRadius + 3)
                    .rotationEffect(.degrees(Double(index) * 15))
            }
        }
    }

    private func knob(
        radius: CGFloat,
        angle: Angle
    ) -> some View {
        let radians = angle.radians
        let x = cos(radians) * radius
        let y = sin(radians) * radius

        return Circle()
            .fill(Color(nsColor: .windowBackgroundColor))
            .frame(width: 17, height: 17)
            .overlay {
                Circle()
                    .stroke(tint, lineWidth: 4)
            }
            .shadow(
                color: .black.opacity(0.18),
                radius: 4,
                y: 2
            )
            .offset(x: x, y: y)
            .animation(
                isDragging ? nil : .snappy(duration: 0.2),
                value: value
            )
    }

    // MARK: Center editor

    private var centerEditor: some View {
        VStack(spacing: -1) {
            if isEditing {
                TextField("", text: $inputText)
                    .textFieldStyle(.plain)
                    .font(
                        .system(
                            size: 28,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .frame(width: 58)
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
            } else {
                Text("\(value)")
                    .font(
                        .system(
                            size: 28,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .contentTransition(
                        .numericText(value: Double(value))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        beginEditing()
                    }
                    .help("Double-click to enter a duration")
            }

            Text("MIN")
                .font(
                    .system(
                        size: 9,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .tracking(1.2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 70, height: 62)
        .background {
            Circle()
                .fill(
                    isEditing
                        ? Color(nsColor: .controlBackgroundColor)
                        : Color.clear
                )
        }
    }

    // MARK: Text input

    private func beginEditing() {
        inputText = String(value)
        isEditing = true

        DispatchQueue.main.async {
            inputIsFocused = true
        }
    }

    private func sanitizeInput(_ newValue: String) {
        let asciiDigits = newValue.filter {
            "0123456789".contains($0)
        }

        let limitedDigits = String(
            asciiDigits.prefix(maximumInputLength)
        )

        if limitedDigits != newValue {
            inputText = limitedDigits
        }
    }

    private func commitInput() {
        guard
            !inputText.isEmpty,
            let enteredValue = Int(inputText)
        else {
            cancelInput()
            return
        }

        value = min(
            range.upperBound,
            max(range.lowerBound, enteredValue)
        )

        inputText = String(value)
        isEditing = false
        inputIsFocused = false
    }

    private func cancelInput() {
        inputText = String(value)
        isEditing = false
        inputIsFocused = false
    }

    // MARK: Dial interaction

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 3)
            .onChanged { gesture in
                guard !isEditing else {
                    return
                }

                isDragging = true

                updateValue(
                    from: gesture.location,
                    in: size
                )
            }
            .onEnded { gesture in
                guard !isEditing else {
                    return
                }

                updateValue(
                    from: gesture.location,
                    in: size
                )

                isDragging = false
            }
    }

    private func updateValue(
        from location: CGPoint,
        in size: CGSize
    ) {
        let center = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        let deltaX = location.x - center.x
        let deltaY = location.y - center.y

        var degrees = atan2(deltaY, deltaX) * 180 / .pi
        degrees += 90

        if degrees < 0 {
            degrees += 360
        }

        let rawProgress = degrees / 360
        let span = range.upperBound - range.lowerBound

        let calculatedValue =
            Double(range.lowerBound)
            + rawProgress * Double(span)

        value = min(
            range.upperBound,
            max(range.lowerBound, Int(calculatedValue.rounded()))
        )
    }

    private func changeValue(by amount: Int) {
        value = min(
            range.upperBound,
            max(range.lowerBound, value + amount)
        )
    }
}

// MARK: - Supporting Views

private struct DialButton: View {
    let systemImage: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .bold))
                .frame(width: 22, height: 22)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .background {
            Circle()
                .fill(
                    Color.primary.opacity(
                        disabled ? 0.035 : 0.07
                    )
                )
        }
        .foregroundStyle(
            disabled ? .tertiary : .primary
        )
        .disabled(disabled)
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            content
        }
    }
}

// MARK: - Preview

#Preview {
    TimerSettingsView()
}
