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

@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> where T.RawValue == String {
    let key: String
    let startingValue: T
    
    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: T {
        get {
            if let savedString = UserDefaults.standard.string(forKey: key), let savedValue = T(rawValue: savedString) {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue.rawValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
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
