//
//  Date+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

extension Date {
    func adding(seconds: Double = 0, minutes: Double = 0, hours: Double = 0, days: Double = 0, weeks: Double = 0, months: Double = 0) -> Date {
        let totalSeconds = (seconds) +
                           (minutes * 60) +
                           (hours * 3600) +
                           (days * 86400) +
                           (weeks * 604800) +
                           (months * 2_592_000) // Approx. 30 days per month
        return self.addingTimeInterval(totalSeconds)
    }
}
