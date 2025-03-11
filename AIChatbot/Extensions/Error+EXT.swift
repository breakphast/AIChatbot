//
//  Error+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/11/25.
//

import SwiftUI

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
