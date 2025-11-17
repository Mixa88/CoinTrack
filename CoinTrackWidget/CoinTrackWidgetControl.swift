//
//  CoinTrackWidgetControl.swift
//  CoinTrackWidget
//
//  Created by Михайло Тихонов on 11.11.2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct CoinTrackWidgetControl: ControlWidget {
    static let kind: String = "Mixa.CoinTrack.CoinTrackWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                
                .init("widget.control.start_timer"),
                isOn: value.isRunning,
                action: StartTimerIntent(value.name)
            ) { isRunning in
                Label(
                   
                    isRunning ? .init("widget.control.on") : .init("widget.control.off"),
                    systemImage: "timer"
                )
            }
        }
        
        .displayName(.init("widget.control.timer_name"))
        .description(.init("widget.control.timer_description"))
    }
}

extension CoinTrackWidgetControl {
    struct Value {
        var isRunning: Bool
        var name: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            CoinTrackWidgetControl.Value(isRunning: false, name: configuration.timerName)
        }

        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = true // Check if the timer is running
            return CoinTrackWidgetControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

struct TimerConfiguration: ControlConfigurationIntent {
    
    static let title: LocalizedStringResource = .init("widget.control.config.title")

    
    @Parameter(title: .init("widget.control.config.param_name"), default: "Timer")
    var timerName: String
}

struct StartTimerIntent: SetValueIntent {
    
    static let title: LocalizedStringResource = .init("widget.control.intent.start_timer.title")

    
    @Parameter(title: .init("widget.control.intent.param_name"))
    var name: String

    
    @Parameter(title: .init("widget.control.intent.param_running"))
    var value: Bool

    init() {}

    init(_ name: String) {
        self.name = name
    }

    func perform() async throws -> some IntentResult {
        // Start the timer…
        return .result()
    }
}
