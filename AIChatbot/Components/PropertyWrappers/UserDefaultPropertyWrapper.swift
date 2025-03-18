//
//  UserDefaultPropertyWrapper.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

@propertyWrapper
struct UserDefault {
    let key: String
    let startingValue: Bool
    
    init(key: String, startingValue: Bool) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: Bool {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? Bool {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

protocol UserDefaultsCompatible { }
extension Bool: UserDefaultsCompatible { }
extension Int: UserDefaultsCompatible { }
extension Float: UserDefaultsCompatible { }
extension Double: UserDefaultsCompatible { }
extension String: UserDefaultsCompatible { }
extension URL: UserDefaultsCompatible { }
