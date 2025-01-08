//
//  timerView.swift
//  Timer
//
//

import SwiftUI

struct timerView: View {
    @ObservedObject var viewModel: TimerViewModel
    var body: some View {
        Text(viewModel.timeString(from: viewModel.remainingTime))
            .font(.system(size:50, design: .monospaced))
            .frame(width: 200, height: 100)
    }
        
}

#Preview {
    timerView(viewModel: TimerViewModel(duration: 25))
}
