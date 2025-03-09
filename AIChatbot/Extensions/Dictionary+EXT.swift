//
//  Dictionary+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/9/25.
//

import SwiftUI

extension Dictionary where Key == String, Value == Any {
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self.map({ (key: $0, value: $1) }).sortedByKeyPath(keyPath: \.key)
    }
}
